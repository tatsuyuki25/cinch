// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_service.dart';

// **************************************************************************
// CinchGenerator
// **************************************************************************

class _$TestService extends Service {
  _$TestService(
      {Duration connectTimeout = const Duration(seconds: 5),
      Duration receiveTimeout = const Duration(seconds: 10)})
      : super('http://localhost:8080/',
            connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
  Future<Response> _$upload(UploadFileInfo file) {
    return request([Post('upload'), multipart], [Pair(Part('file'), file)])
        .then((response) => Response.fromJson(response.data));
  }

  Future<Response> _$multiUpload(int flag, Map<String, UploadFileInfo> file) {
    return request([
      Post('multiUpload'),
      multipart
    ], [
      Pair(Part('flag'), flag),
      Pair(partMap, file)
    ]).then((response) => Response.fromJson(response.data));
  }
}
