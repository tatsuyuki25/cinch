library cinch_gen.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/cinch_generator.dart';

/// 指定使用 [PartBuilder]
Builder cinch(BuilderOptions options) {
  return PartBuilder([CinchGenerator()], '.cinch.dart');
}
