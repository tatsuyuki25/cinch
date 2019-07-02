import 'package:cinch/cinch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
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
''')
@ApiService('http://localhost:8080/')
class TestService{
  @Post('upload')
  @multipart
  Future<Response> upload(@Part('file') UploadFileInfo file) async {
    return null;
  }

  @Post('multiUpload')
  @multipart
  Future<Response> multiUpload(@Part('flag') int flag,
  @partMap Map<String, UploadFileInfo> file) async {
    return null;
  }
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
