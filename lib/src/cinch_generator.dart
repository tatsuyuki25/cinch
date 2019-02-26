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
      _\$${classElement.name}(String baseUrl, Duration connectTimeout, Duration receiveTimeout):
      super(baseUrl, connectTimeout, receiveTimeout);
    """;

    source += "}";
    return source;
  }
}
