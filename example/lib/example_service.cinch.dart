// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$ExampleService extends gg.Service {
  _$ExampleService(
      {Duration connectTimeout = const Duration(seconds: 5),
      Duration receiveTimeout = const Duration(seconds: 10),
      Duration sendTimeout = const Duration(seconds: 10),
      gg.ValidateStatus? validateStatus})
      : super('https://test.com/api',
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            validateStatus: validateStatus);
  Future<List<Example>> _$getArea(String? type) {
    return request(<dynamic>[
      const gg.Get('json/area-yb2.json')
    ], [
      (const gg.Query('type'), type)
    ]).then((dynamic response) => List<Example>.from(
        response.data.map((json) => Example.fromJson(json))));
  }
}
