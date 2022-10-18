// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example2_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$Example2Service extends Service {
  _$Example2Service(
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

  Future<Response> _$upload(MultipartFile file) {
    return request(<dynamic>[
      const Post('upload'),
      multipart
    ], [
      Pair<Part, MultipartFile>(const Part('file'), file)
    ]).then((dynamic response) => Response.fromJson(response.data));
  }

  Future<Response> _$multiUpload(int flag, Map<String, MultipartFile> file) {
    return request(<dynamic>[
      const Post('multiUpload'),
      multipart
    ], [
      Pair<Part, int>(const Part('flag'), flag),
      Pair<dynamic, Map<String, MultipartFile>>(partMap, file)
    ]).then((dynamic response) => Response.fromJson(response.data));
  }

  Future<Global<List<String>>> _$generic() {
    return request(<dynamic>[const Post('generic')], []).then(
        (dynamic response) => Global<List<String>>.fromNestedGenericJson(
            response.data, [List, String]));
  }
}
