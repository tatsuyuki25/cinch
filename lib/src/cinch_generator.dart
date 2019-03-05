import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dio/dio.dart';
import 'package:source_gen/source_gen.dart';

import 'cinch_annotations.dart';
import 'source_write.dart';

/// 動態產生程式碼
class CinchGenerator extends GeneratorForAnnotation<ApiService> {

  /// 程式碼
  var _write = Write();

  /// 檢查[Http]type
  var _httpChecker = TypeChecker.fromRuntime(Http);
  /// 檢查[Response] type
  var _dioChecker = TypeChecker.fromRuntime(Response);

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '無法轉換 ${element.name}, 請確定${element.name} 為 `class`');
    }

    final classElement = element as ClassElement;
    if (classElement.methods.length <= 0) {
      return null;
    }
    _write.clear();
    var test = classElement.library;
    _write.write('var t3 = "${test.imports[0].prefix}";');
    _write.write('var t2 = "${test.prefixes[0].name}";');
    _write.write('var t1 = "${test.prefixes[0].librarySource.fullName}";');
    _write.write('var t4 = "${test.imports[0].prefixOffset}";');
    _write.write('var t5 = "${test.prefixes[0].library.displayName}";');
    _write.write("""
    class _\$${classElement.name} extends Service {
      _\$${classElement.name}({Duration connectTimeout = const Duration(seconds: 5), 
      Duration receiveTimeout = const Duration(seconds: 10)}):
      super('${_getField(annotation.objectValue, 'url').toStringValue()}', 
      connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
    """);
    _parseMethod(classElement);
    _write.write('}');
    return _write.toString();
  }

  /// 檢查[object]是否為null
  bool _isNull(DartObject object) => object == null || object.isNull;

  /// 從[object]本身或父類中取得[field]欄位資料
  /// 
  /// Return object
  DartObject _getField(DartObject object, String field) {
    if (_isNull(object)) return null;
    var fieldValue = object.getField(field);
    if (!_isNull(fieldValue)) {
      return fieldValue;
    }
    return _getField(object.getField('(super)'), field);
  }

  /// 從[element] 解析是否為 cinch method
  /// 
  /// 只解析return type 為[Future]的method
  void _parseMethod(ClassElement element) {
    var methods = element.methods.where((m) => m.returnType.isDartAsyncFuture);
    if (methods.isEmpty) {
      return;
    }
    for (var m in methods) {
      if (!_hasCinchAnnotation(m)) {
        log.warning('Method ${m.name} 沒有標記Http method');
        continue;
      }
      var genericType = _getGenericTypes(m.returnType).first;
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
    var nested = <String>[];
    _getGenericTypes(type).forEach((t) {
      if (_hasGenerics(t)) {
        nested.add('${t.name}');
        nested.addAll(_getNestedGenerics(t));
      } else {
        nested.add('$t');
      }
    });
    return nested;
  }

  /// [type]是否為嵌套泛型
  bool _hasNestedGeneric(DartType type) {
    if (_hasGenerics(type)) {
      var types = _getGenericTypes(type);
      return types.any((t) => _hasGenerics(t));
    }
    return false;
  }

  /// [element]是否有標annotation
  bool _hasCinchAnnotation(MethodElement element) {
    var metadata = element.metadata.where(
        (m) => _httpChecker.isSuperTypeOf(m.computeConstantValue().type));
    if (metadata.length > 1) {
      throw InvalidGenerationSourceError('Http method只能設定一個');
    }
    return metadata.length == 1;
  }

  /// 寫入無須轉換的程式碼
  void _writeDynamic(MethodElement element) {
    var config = _getAnnotations(element);
    var parameters = _getParameters(element);
    _write.write('Future<Response> ');
    _writeMethod(element);
    _write.write('{');
    _write.write('return request(${config}, ${parameters});');
    _write.write('}');
  }

  /// 根據[returnType] 轉換資料
  void _writeNormal(MethodElement element, DartType returnType) {
    var config = _getAnnotations(element);
    var parameters = _getParameters(element);
    _write.write('${element.returnType} ');
    _writeMethod(element);
    _write.write('{');
    _write.write('return request($config, $parameters)');
    if (_hasNestedGeneric(returnType)) {
      _write.write(
          '.then((response) => ${returnType}.'
          'fromNestedGenericJson(response.data, ${_getNestedGenerics(returnType)}));');
    } else {
      _write
          .write('.then((response) => ${returnType}.fromJson(response.data));');
    }
    _write.write('}');
  }

  /// 寫入method 開頭
  void _writeMethod(MethodElement element) {
    _write.write('_\$${element.name}(');
    _write.write(element.parameters
        .where((p) => p.metadata.length == 1)
        .map((p) => '${p.type} ${p.name}')
        .join(','));
    _write.write(')');
  }

  /// 取得標籤
  List<String> _getAnnotations(MethodElement element) {
    return element.metadata.map((m) => m.toSource().substring(1)).toList();
  }
  
  /// 取得參數資料
  List<String> _getParameters(MethodElement element) {
    var parameters = element.parameters.where((p) => p.metadata.length == 1);
    return parameters
        .map((p) =>
            'Pair(${p.metadata[0].toSource().substring(1)}, ${p.name})')
        .toList();
  }
}
