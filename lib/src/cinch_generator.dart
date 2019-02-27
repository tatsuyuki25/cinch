import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'cinch_annotations.dart';

class CinchGenerator extends GeneratorForAnnotation<ApiService> {
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
    var source = """
    class _\$${classElement.name} extends Service {
      _\$${classElement.name}({Duration connectTimeout = const Duration(seconds: 5), 
      Duration receiveTimeout = const Duration(seconds: 10)}):
      super('${annotation.objectValue.getField('url').toStringValue()}', 
      connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
    """;
    source += _parseMethod(classElement, source);
    source += "}";
    return source;
  }

  String _parseMethod(ClassElement element, String source) {
    var methods = element.methods.where((m) => m.returnType.isDartAsyncFuture);
    source += "var isEmpty = ${methods.isEmpty};";
    if (methods.isEmpty) {
      return source;
    }
    methods.forEach((m) {
      var genericType = _getGenericTypes(m.returnType).first;
      source += "var b = '${genericType.toString()}';";
      if (genericType.isDynamic) {
        source = _writeDynamic(m, source);
        return source;
      }
    });
  }

  Iterable<DartType> _getGenericTypes(DartType type) {
    return type is ParameterizedType ? type.typeArguments : const [];
  }

  String _writeDynamic(MethodElement element, String source) {
    source += "var a = '${element.source.toString()}';";
    return source;
  }
}
