// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'example_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$ExampleService extends gg.Service {
  _$ExampleService({
    // ignore: unused_element_parameter
    super.connectTimeout,
    // ignore: unused_element_parameter
    super.receiveTimeout,
    // ignore: unused_element_parameter
    super.sendTimeout,
    // ignore: unused_element_parameter
    super.validateStatus,
  }) : super('https://test.com/api');
  Future<List<Example>> _$getArea(String? type) {
    return request(
      <dynamic>[const gg.Get('json/area-yb2.json')],
      [(const gg.Query('type'), type)],
    ).then(
      (dynamic response) => List<Example>.from(
        (response.data as List).map((j) => Example.fromJson(j)),
      ),
    );
  }

  Future<Global<Example>> _$getArea2(String? type) {
    return request(
      <dynamic>[const gg.Get('json/area-yb2.json')],
      [(const gg.Query('type'), type)],
    ).then(
      (dynamic response) =>
          Global<Example>.fromJson(response.data, Example.fromJson),
    );
  }

  Future<Global<List<Example>>> _$getArea3(String? type) {
    return request(
      <dynamic>[const gg.Get('json/area-yb2.json')],
      [(const gg.Query('type'), type)],
    ).then(
      (dynamic response) => Global<List<Example>>.fromJson(
        response.data,
        (json) =>
            List<Example>.from((json as List).map((j) => Example.fromJson(j))),
      ),
    );
  }

  Future<Global<List<String>>> _$getArea4(String? type) {
    return request(
      <dynamic>[const gg.Get('json/area-yb2.json')],
      [(const gg.Query('type'), type)],
    ).then(
      (dynamic response) => Global<List<String>>.fromJson(
        response.data,
        (json) => List<String>.from((json as List).map((j) => j as String)),
      ),
    );
  }
}
