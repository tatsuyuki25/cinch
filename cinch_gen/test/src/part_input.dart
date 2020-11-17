import 'package:cinch/cinch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
class _$TestService extends Service {
  _$TestService(
      {Duration connectTimeout = const Duration(seconds: 5),
      Duration receiveTimeout = const Duration(seconds: 10)})
      : super('http://localhost:8080/',
            connectTimeout: connectTimeout, receiveTimeout: receiveTimeout);
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
}
''')
@ApiService('http://localhost:8080/')
class TestService {
  @Post('upload')
  @multipart
  Future<Response> upload(@Part('file') MultipartFile file) async {
    return null;
  }

  @Post('multiUpload')
  @multipart
  Future<Response> multiUpload(
      @Part('flag') int flag, @partMap Map<String, MultipartFile> file) async {
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
