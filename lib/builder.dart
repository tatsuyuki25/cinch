library cinch.builder;

import 'package:build/build.dart';
import 'src/cinch_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder cinch(BuilderOptions options) {
  return PartBuilder([CinchGenerator()], '.cinch.dart');
}
