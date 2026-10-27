// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'example2_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$Example2Service extends Service {
  _$Example2Service({
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
      <dynamic>[const Get('json/area-yb2.json')],
      [(const Query('type'), type)],
    ).then(
      (dynamic response) => List<Example>.from(
        (response.data as List).map((j) => Example.fromJson(j)),
      ),
    );
  }

  Future<Response> _$upload(MultipartFile file) {
    return request(
      <dynamic>[const Post('upload'), multipart],
      [(const Part('file'), file)],
    ).then((dynamic response) => Response.fromJson(response.data));
  }

  Future<Response> _$multiUpload(int flag, Map<String, MultipartFile> file) {
    return request(
      <dynamic>[const Post('multiUpload'), multipart],
      [(const Part('flag'), flag), (partMap, file)],
    ).then((dynamic response) => Response.fromJson(response.data));
  }
}
