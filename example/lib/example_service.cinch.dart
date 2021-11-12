// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$ExampleService extends Service {
  _$ExampleService(
      {Duration connectTimeout = const Duration(seconds: 5),
      Duration receiveTimeout = const Duration(seconds: 10)})
      : super('https://test.com/api',
            connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
  Future<List<Example>> _$getArea(String? type) {
    return request(<dynamic>[
      const Get('json/area-yb2.json')
    ], [
      Pair<Query, String?>(const Query('type'), type)
    ]).then((dynamic response) => List<Example>.from(
        response.data.map((json) => Example.fromJson(json))));
  }
}
