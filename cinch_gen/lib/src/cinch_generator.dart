import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:cinch/cinch.dart';
import 'package:dio/dio.dart';
import 'package:source_gen/source_gen.dart';

import 'source_write.dart';

/// 動態產生程式碼
class CinchGenerator extends GeneratorForAnnotation<ApiService> {
  /// 程式碼
  final _write = Write();

  /// 檢查[Http]type
  final _httpChecker = const TypeChecker.fromRuntime(Http);

  /// 檢查[Response] type
  final _dioChecker = const TypeChecker.fromRuntime(Response);

  String? _prefix;

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      if (element.methods.isEmpty) {
        return null;
      }
      _write.clear();
      _checkPrefix(element);
      _write.write("""
    class _\$${element.name} extends ${_getPrefix()}Service {
      _\$${element.name}({Duration connectTimeout = const Duration(seconds: 5), 
      Duration receiveTimeout = const Duration(seconds: 10)}):
      super('${_getField(annotation.objectValue, 'url')?.toStringValue()}', 
      connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
    """);
      _parseMethod(element);
      _write.write('}');
      return _write.toString();
    }
    throw InvalidGenerationSourceError(
        '無法轉換 ${element.name}, 請確定${element.name} 為 `class`');
  }

  void _checkPrefix(ClassElement element) {
    _prefix = null;
    final imports = element.library.imports;
    for (var i = 0; i < imports.length; i++) {
      final name = imports[i].toString().replaceAll(r'import ', '');
      if (name == 'cinch') {
        final p = imports[i].prefix;
        if (p != null) {
          _prefix = p.name;
        }
        break;
      }
    }
  }

  /// 取得Prefix
  String _getPrefix() {
    return _prefix != null ? '$_prefix.' : '';
  }

  /// 檢查[object]是否為null
  bool _isNull(DartObject? object) => object == null || object.isNull;

  /// 從[object]本身或父類中取得[field]欄位資料
  ///
  /// Return object
  DartObject? _getField(DartObject? object, String field) {
    if (_isNull(object) || object == null) {
      return null;
    }
    final fieldValue = object.getField(field);
    if (!_isNull(fieldValue)) {
      return fieldValue!;
    }
    return _getField(object.getField('(super)'), field);
  }

  /// 從[element] 解析是否為 cinch method
  ///
  /// 只解析return type 為[Future]的method
  void _parseMethod(ClassElement element) {
    final methods =
        element.methods.where((m) => m.returnType.isDartAsyncFuture);
    if (methods.isEmpty) {
      return;
    }
    for (var m in methods) {
      if (!_hasCinchAnnotation(m)) {
        log.warning('Method ${m.name} 沒有標記Http method');
        continue;
      }
      final genericType = _getGenericTypes(m.returnType).first;
      if (genericType.isDynamic || _dioChecker.isExactlyType(genericType)) {
        _writeDynamic(m);
        continue;
      }
      _writeNormal(m, genericType);
    }
  }

  /// 取得type中的泛型參數
  ///
  /// Return 泛型集合
  Iterable<DartType> _getGenericTypes(DartType type) {
    return type is ParameterizedType ? type.typeArguments : const [];
  }

  /// [type]是否為泛型
  bool _hasGenerics(DartType type) {
    final element = type.element;
    if (element is ClassElement) {
      return element.typeParameters.isNotEmpty;
    }
    return false;
  }

  /// 取得嵌套泛型的type 字串
  List<String> _getNestedGenerics(DartType type) {
    final nested = <String>[];
    for (var t in _getGenericTypes(type)) {
      if (_hasGenerics(t)) {
        nested.add('${t.element?.displayName}');
        nested.addAll(_getNestedGenerics(t));
      } else {
        nested.add('${t.nonStarString()}');
      }
    }
    return nested;
  }

  /// [type]是否為嵌套泛型
  bool _hasNestedGeneric(DartType type) {
    if (_hasGenerics(type)) {
      final types = _getGenericTypes(type);
      return types.any((t) => _hasGenerics(t));
    }
    return false;
  }

  /// [element]是否有標annotation
  bool _hasCinchAnnotation(MethodElement element) {
    final metadata = element.metadata.where((m) {
      final type = m.computeConstantValue()?.type;
      if (type != null) {
        return _httpChecker.isSuperTypeOf(type);
      }
      return false;
    });
    if (metadata.length > 1) {
      throw InvalidGenerationSourceError('Http method只能設定一個');
    }
    return metadata.length == 1;
  }

  /// 寫入無須轉換的程式碼
  void _writeDynamic(MethodElement element) {
    final config = _getAnnotations(element);
    final parameters = _getParameters(element);
    _write.write('Future<Response> ');
    _writeMethod(element);
    _write.write('{');
    _write.write('return request(<dynamic>$config, $parameters);');
    _write.write('}');
  }

  /// 根據[returnType] 轉換資料
  void _writeNormal(MethodElement element, DartType returnType) {
    final config = _getAnnotations(element);
    final parameters = _getParameters(element);
    _write.write('${element.returnType.nonStarString()} ');
    _writeMethod(element);
    _write.write('{');
    _write.write('return request(<dynamic>$config, $parameters)');
    if (_hasNestedGeneric(returnType)) {
      _write.write('.then((dynamic response) => ${returnType.nonStarString()}.'
          'fromNestedGenericJson(response.data, ${_getNestedGenerics(returnType)}));');
    } else if (returnType.isDartCoreList) {
      _writeListReturn(returnType);
    } else {
      _write.write(
          '.then((dynamic response) => ${returnType.nonStarString()}.fromJson(response.data));');
    }
    _write.write('}');
  }

  /// 寫入method 開頭
  void _writeMethod(MethodElement element) {
    _write.write('_\$${element.name}(');
    _write.write(element.parameters
        .where((p) => p.metadata.length == 1)
        .map((p) => '${p.type.nonStarString()} ${p.name}')
        .join(','));
    _write.write(')');
  }

  void _writeListReturn(DartType returnType) {
    final genericType = _getGenericTypes(returnType);
    if (genericType.isNotEmpty) {
      final clazz = genericType.first.element;
      if (clazz != null && clazz is ClassElement) {
        log.warning('class getNamedConstructor: ${clazz.getNamedConstructor('fromJson')}');
        final type = genericType.first.nonStarString();
        if (clazz.getNamedConstructor('fromJson') != null) {          
          _write.write(
              '.then((dynamic response) => ${returnType.nonStarString()}.from(response.data.map((json)=> $type.fromJson(json))));');
          return;
        } else {
          _write.write(
              '.then((dynamic response) => ${returnType.nonStarString()}.from(response.data));');
          return;
        }
      }
    }
    _write.write(
        '.then((dynamic response) => ${returnType.nonStarString()}.fromJson(response.data));');
  }

  /// 取得標籤
  List<String> _getAnnotations(MethodElement element) {
    return element.metadata.map((m) {
      if (m.element is ConstructorElement) {
        return 'const ${m.toSource().substring(1)}';
      }
      return m.toSource().substring(1);
    }).toList();
  }

  /// 取得參數資料
  List<String> _getParameters(MethodElement element) {
    final parameters = element.parameters.where((p) => p.metadata.length == 1);
    return parameters.map((p) {
      final element = p.metadata[0].element;
      String firstType;
      String firstValue;
      if (element is ConstructorElement) {
        firstType = element.enclosingElement.name;
        firstValue = 'const ${p.metadata[0].toSource().substring(1)}';
      } else {
        firstType = 'dynamic';
        firstValue = p.metadata[0].toSource().substring(1);
      }
      return '${_getPrefix()}Pair<$firstType,'
          '${p.type.nonStarString()}>($firstValue, ${p.name})';
    }).toList();
  }
}

extension DartTypeExt on DartType {
  String nonStarString() {
    return toString().replaceAll('*', '');
  }
}
