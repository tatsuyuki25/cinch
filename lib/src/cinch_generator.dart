import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dio/dio.dart';
import 'package:source_gen/source_gen.dart';

import 'cinch_annotations.dart';
import 'source_write.dart';

class CinchGenerator extends GeneratorForAnnotation<ApiService> {
  var _write = Write();
  var _httpChecker = TypeChecker.fromRuntime(Http);
  var _listChecker = TypeChecker.fromRuntime(List);
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

  bool _isNull(DartObject object) => object == null || object.isNull;

  DartObject _getField(DartObject object, String field) {
    if (_isNull(object)) return null;
    var fieldValue = object.getField(field);
    if (!_isNull(fieldValue)) {
      return fieldValue;
    }
    return _getField(object.getField('(super)'), field);
  }

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

  Iterable<DartType> _getGenericTypes(DartType type) {
    return type is ParameterizedType ? type.typeArguments : const [];
  }

  bool _hasGenerics(DartType type) {
    final element = type.element;
    if (element is ClassElement) {
      return element.typeParameters.isNotEmpty;
    }
    return false;
  }

  List<String> _getNestedGenerics(DartType type) {
    var nested = <String>[];
    _getGenericTypes(type).forEach((t) {
      nested.add('$t');
      if (_hasGenerics(t)) {
        nested.addAll(_getNestedGenerics(t));
      }
    });
    return nested;
  }

  bool _hasNestedGeneric(DartType type) {
    if (_hasGenerics(type)) {
      var types = _getGenericTypes(type);
      return types.any((t) {
        if (_hasGenerics(t)) {
          return _getGenericTypes(t).any((it) => _hasGenerics(it));
        }
        return false;
      });
    }
    return false;
  }

  bool _hasCinchAnnotation(MethodElement element) {
    var metadata = element.metadata.where(
        (m) => _httpChecker.isSuperTypeOf(m.computeConstantValue().type));
    if (metadata.length > 1) {
      throw InvalidGenerationSourceError('Http method只能設定一個');
    }
    return metadata.length == 1;
  }

  void _writeDynamic(MethodElement element) {
    var config = _getAnnotations(element);
    var parameters = _getParameters(element);
    _write.write('Future<Response> ');
    _writeMethod(element);
    _write.write('{');
    _write.write('return request(${config}, ${parameters});');
    _write.write('}');
  }

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

  void _writeMethod(MethodElement element) {
    _write.write('_\$${element.name}(');
    _write.write(element.parameters
        .where((p) => p.metadata.length == 1)
        .map((p) => '${p.type} ${p.name}')
        .join(','));
    _write.write(')');
  }

  List<String> _getAnnotations(MethodElement element) {
    return element.metadata.map((m) => m.toSource().substring(1)).toList();
  }

  List<String> _getParameters(MethodElement element) {
    var parameters = element.parameters.where((p) => p.metadata.length == 1);
    return parameters
        .map((p) =>
            'Pair(${p.metadata[0].toSource().substring(1)}, ${p.name})')
        .toList();
  }
}
