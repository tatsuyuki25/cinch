// ignore_for_file: empty_constructor_bodies, avoid_unused_constructor_parameters

import 'package:cinch/cinch.dart';

part 'test_service.cinch.dart';

@ApiService('http://localhost:8080/')
class TestService extends _$TestService {
  @Post('upload')
  @multipart
  Future<Response> upload(@Part('file') MultipartFile file) {
    return _$upload(file);
  }

  @Post('multiUpload')
  @multipart
  Future<Response> multiUpload(
      @Part('flag') int flag, @partMap Map<String, MultipartFile> file) {
    return _$multiUpload(flag, file);
  }

  @Post('generic')
  Future<Global<List<String>>> generic() => _$generic();
}

class Response {
  Response.fromJson(Map<String, dynamic> json)
      : retCode = json['retCode'],
        errMsg = json['errMsg'];

  final int retCode;

  final String errMsg;

  @override
  String toString() {
    return 'retCode: $retCode, errMsg: $errMsg';
  }
}

class Global<T> {
  Global.fromNestedGenericJson(Map<String, dynamic> json, List<Type> types) {}
  T? data;
}
