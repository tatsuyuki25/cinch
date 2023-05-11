import 'package:cinch/cinch.dart';

part 'example2_service.cinch.dart';

class OtherAnnotation {
  const OtherAnnotation(this.value);

  final String value;
}

@ApiService('https://test.com/api')
class Example2Service extends _$Example2Service {
  @Get('json/area-yb2.json')
  Future<List<Example>> getArea(@OtherAnnotation('GG') int test,
      {@Query('type') String? type, int? type2}) {
    return _$getArea('2');
  }

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

class Example {
  Example.fromJson(dynamic json) : value = json['value'];
  final String value;
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
