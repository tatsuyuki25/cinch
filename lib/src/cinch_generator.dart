import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'cinch_annotations.dart';
import 'source_write.dart';

class CinchGenerator extends GeneratorForAnnotation<ApiService> {
  Write _write = Write();

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
      super('${annotation.objectValue.getField('url').toStringValue()}', 
      connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
    """);
    _parseMethod(classElement);
    _write.write('}');
    return _write.toString();
  }

  void _parseMethod(ClassElement element) {
    var methods = element.methods.where((m) => m.returnType.isDartAsyncFuture);
    if (methods.isEmpty) {
      return;
    }
    for (var m in methods) {
      if (!hasCinchAnnotation(m)) {
        log.warning('Method ${m.name} 沒有標記Http method');
        continue;
      }
      var genericType = _getGenericTypes(m.returnType).first;
      if (genericType.isDynamic) {
        _writeDynamic(m);
        continue;
      }
    }
  }

  Iterable<DartType> _getGenericTypes(DartType type) {
    return type is ParameterizedType ? type.typeArguments : const [];
  }

  bool hasCinchAnnotation(MethodElement element) {
    return element.metadata.any((a) => a.runtimeType is Http);
  }

  void _writeDynamic(MethodElement element) {
    var http = getHttpMethod(element);
    _write.write("var source = '${http.toSource()}';");
  }

  ElementAnnotation getHttpMethod(MethodElement element) {
    var metadata = element.metadata.where((m) => m.runtimeType is Http);
    if (metadata.length > 1) {
      throw InvalidGenerationSourceError('Http method只能設定一個');
    }
    return metadata.first;
  }
}
