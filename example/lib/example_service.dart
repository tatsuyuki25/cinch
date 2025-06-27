import 'package:cinch/cinch.dart' as gg;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_service.cinch.dart';
part 'example_service.g.dart';
part 'example_service.freezed.dart';

@gg.ApiService('https://test.com/api')
class ExampleService extends _$ExampleService {
  @gg.Get('json/area-yb2.json')
  Future<List<Example>> getArea({@gg.Query('type') String? type}) {
    return _$getArea('2');
  }

  @gg.Get('json/area-yb2.json')
  Future<Global<Example>> getArea2({@gg.Query('type') String? type}) {
    return _$getArea2('2');
  }

  @gg.Get('json/area-yb2.json')
  Future<Global<List<Example>>> getArea3({@gg.Query('type') String? type}) {
    return _$getArea3('2');
  }

  @gg.Get('json/area-yb2.json')
  Future<Global<List<String>>> getArea4({@gg.Query('type') String? type}) {
    return _$getArea4('2');
  }
}

class Example {
  Example.fromJson(dynamic json) : value = json['value'];
  final String value;
}

@Freezed(genericArgumentFactories: true)
sealed class Global<T> with _$Global<T> {
  const factory Global({required T data}) = _Global;

  factory Global.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$GlobalFromJson(json, fromJsonT);
}