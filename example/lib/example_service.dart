
import 'package:cinch/cinch.dart' as gg;

part 'example_service.cinch.dart';

@gg.ApiService('https://test.com/api')
class ExampleService extends _$ExampleService {
  @gg.Get('json/area-yb2.json')
  Future<List<Example>> getArea({@gg.Query('type') String? type}) {
    return _$getArea('2');
  }
}

class Example {
  Example.fromJson(dynamic json): value = json['value'];
  final String value;
}