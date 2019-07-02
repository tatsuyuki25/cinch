@TestOn('vm')
import 'package:cinch/src/cinch_generator.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen_test/source_gen_test.dart';
import 'package:test/test.dart';

Future<void> main() async {
  initializeBuildLogTracking();
  final reader = await initializeLibraryReaderForDirectory(
      p.join('test', 'src'), 'part_input.dart');
  testAnnotatedElements(reader, CinchGenerator(),
      expectedAnnotatedTests: ['TestService']);
}
