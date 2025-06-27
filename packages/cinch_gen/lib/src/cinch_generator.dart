import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:cinch/cinch.dart';
import 'package:source_gen/source_gen.dart';
import 'source_write.dart';

/// 動態產生程式碼
class CinchGenerator extends GeneratorForAnnotation<ApiService> {
  /// 程式碼
  final _write = Write();

  /// 檢查[Http]type
  final _httpChecker = const TypeChecker.fromRuntime(Http);

  /// 檢查[Parameter]type
  final _parameterChecker = const TypeChecker.fromRuntime(Parameter);

  /// 檢查[Response] type
  final _dioChecker = const TypeChecker.fromRuntime(Response);

  /// 檢查[MultipartFile] type
  final _multipartFileChecker = const TypeChecker.fromRuntime(MultipartFile);

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
      Duration receiveTimeout = const Duration(seconds: 10),
      Duration sendTimeout = const Duration(seconds: 10),
      ${_getPrefix()}ValidateStatus? validateStatus}):
      super('${_getField(annotation.objectValue, 'url')?.toStringValue()}', 
      connectTimeout: connectTimeout, receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout, validateStatus: validateStatus);
    """);
      _parseMethod(element);
      _write.write('}');
      return _write.toString();
    }
    throw InvalidGenerationSourceError(
        'transform fail ${element.name}, please check ${element.name} is `class`');
  }

  void _checkPrefix(ClassElement element) {
    _prefix = null;
    final compilationUnit = element.library.definingCompilationUnit;
    final imports = compilationUnit.libraryImports;
    for (var i = 0; i < imports.length; i++) {
      final name = imports[i].importedLibrary?.name;
      if (name == 'cinch') {
        final p = imports[i].prefix;
        if (p != null) {
          _prefix = p.element.name;
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
        log.warning('Method ${m.name} not tag Http method');
        continue;
      }
      final genericType = _getGenericTypes(m.returnType).first;
      if (genericType is DynamicType ||
          _dioChecker.isExactlyType(genericType)) {
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
      throw InvalidGenerationSourceError('Http method only set one time.');
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
    final fromJsonExpression =
        _buildFromJsonExpression('response.data', returnType);
    _write.write('.then((dynamic response) => $fromJsonExpression);');
    _write.write('}');
  }

  /// [type]是否為基礎類別
  bool _isPrimitiveType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isDartCoreNum ||
        type is DynamicType;
  }

  /// 建立fromJson的表達式
  String _buildFromJsonExpression(String jsonDataAccessor, DartType type) {
    final typeString = type.nonStarString();
    if (_isPrimitiveType(type)) {
      return '$jsonDataAccessor as $typeString';
    }

    if (!_hasGenerics(type)) {
      return '$typeString.fromJson($jsonDataAccessor)';
    }

    final genericTypes = _getGenericTypes(type).toList();
    if (type.isDartCoreList) {
      final innerType = genericTypes.first;
      final innerFromJson = _buildFromJsonExpression('j', innerType);
      return '$typeString.from(($jsonDataAccessor as List).map((j) => $innerFromJson))';
    }

    final factories = genericTypes.map(_buildFromJsonFactory).join(', ');
    return '$typeString.fromJson($jsonDataAccessor, $factories)';
  }

  /// 建立fromJson的工廠方法
  String _buildFromJsonFactory(DartType type) {
    final typeString = type.nonStarString();
    if (_isPrimitiveType(type)) {
      return '(json) => json as $typeString';
    }

    if (!_hasGenerics(type)) {
      return '$typeString.fromJson';
    }

    final genericTypes = _getGenericTypes(type).toList();
    if (type.isDartCoreList) {
      final innerType = genericTypes.first;
      final innerFromJson = _buildFromJsonExpression('j', innerType);
      return '(json) => $typeString.from((json as List).map((j) => $innerFromJson))';
    }

    final factories = genericTypes.map(_buildFromJsonFactory).join(', ');
    return '(json) => $typeString.fromJson(json, $factories)';
  }

  /// 寫入method 開頭
  void _writeMethod(MethodElement element) {
    _write.write('_\$${element.name}(');
    _write.write(
        element.parameters.where((p) => p.metadata.length == 1).where((p) {
      final type = p.metadata[0].computeConstantValue()?.type;
      if (type != null) {
        return _parameterChecker.isSuperTypeOf(type);
      }
      return false;
    }).map((p) {
      String prefix = '';
      if (_multipartFileChecker.isExactlyType(p.type)) {
        prefix = _getPrefix();
      }
      return '$prefix${p.type.nonStarString()} ${p.name}';
    }).join(','));
    _write.write(')');
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
    final parameters =
        element.parameters.where((p) => p.metadata.length == 1).where((p) {
      final type = p.metadata[0].computeConstantValue()?.type;
      if (type != null) {
        return _parameterChecker.isSuperTypeOf(type);
      }
      return false;
    });
    return parameters.map((p) {
      final element = p.metadata[0].element;
      String firstValue;
      if (element is ConstructorElement) {
        firstValue = 'const ${p.metadata[0].toSource().substring(1)}';
      } else {
        firstValue = p.metadata[0].toSource().substring(1);
      }
      return '($firstValue, ${p.name})';
    }).toList();
  }
}

extension DartTypeExt on DartType {
  String nonStarString() {
    return toString().replaceAll('*', '');
  }
}
