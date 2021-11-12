
import 'package:cinch/cinch.dart';

part 'example_service.cinch.dart';

@ApiService('https://test.com/api')
class ExampleService extends _$ExampleService {
  @Get('json/area-yb2.json')
  Future<List<Example>> getArea({@Query('type') String? type}) {
    return _$getArea('2');
  }
}

class Example {
  Example.fromJson(dynamic json): value = json['value'];
  final String value;
}