import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'cinch_annotations.dart';

class CinchGenerator extends GeneratorForAnnotation<ApiService> {

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('無法轉換 ${element.name}, 請確定${element.name} 為 `class`');
    }
    final classElement = element as ClassElement;
    
    return ["var a = 'test';", "var b = 'GGGGG';"];
  }
}