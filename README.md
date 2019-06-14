# cinch

![VERSION](https://img.shields.io/badge/Version-1.1.1-blue.svg)

## Usage

```yaml
dependencies:
  cinch:
    hosted:
      name: cinch
      url: http://172.16.65.36:8080
    version: ^1.1.1
```

## Example

- `test.dart`

```dart
    import 'package:cinch/cinch.dart';
    part 'test.cinch.dart';
    @ApiService('https://test.com/')
    class TestApi extends _$TestApi {
      TestApi() : super();

      @Get('api/test1')
      Future<Response> test(@Query('t1') int t1) async {
        return _$test(t1);
      }
    }
    ```

- terminal 執行 `flutter packages pub run build_runner build`

## 支援的Http Method

- POST
- GET
- PUT
- DELETE

## application/x-www-form-urlencoded

```dart
  @formUrlEncoded
  @Post('api/test')
  Future<WebGlobalJson<Login>> test(@Field('t1') String t1) async {
    return _$test(t1);
  }
```

## Path

```dart
  @formUrlEncoded
  @Post('api/test/{path}')
  Future<WebGlobalJson<Login>> test(@Path('path') String path) async {
    return _$test(path);
  }
```

## 指定特定URL

```dart
import 'package:cinch/cinch.dart';
part 'test.cinch.dart';

class Web extends ApiService {
  const Web() : super("https://test.com/");
}

@Web()
class TestApi extends _$TestApi {
  TestApi() : super();
  @Get('api/test1')
  Future<Response> test(@Query('t1') int t1) async {
    return _$test(t1);
  }
}
```

## 上傳檔案 Multipart

```dart
@ApiService('http://localhost:8080/')
class TestService extends _$TestService {
  @Post('upload')
  @multipart
  Future<Response> upload(@Part('file') UploadFileInfo file) {
    return _$upload(file);
  }
}

void test() {
  service.upload(UploadFileInfo(File('/path/file.txt'), '上傳名稱.txt'));
  service.upload(UploadFileInfo.fromBytes(bytes, '上傳名稱.txt'));
}
```

- 如果有多欄位需要上傳， 可以搭配 `partMap` 使用

```dart
@ApiService('http://localhost:8080/')
class TestService extends _$TestService {
  @Post('multiUpload')
  @multipart
  Future<Response> multiUpload(@Part('flag') int flag,
  @partMap Map<String, UploadFileInfo> file) {
    return _$multiUpload(flag, file);
  }
}

void test() {
  service.multiUpload(88, {
    "file0": UploadFileInfo(
        File('/Users/liaojianxun/Downloads/Resume.docx'), 'test0.docx'),
    "file1": UploadFileInfo(
        File('/Users/liaojianxun/Downloads/Resume.docx'), 'test1.docx')
  });
  
  /// 也能使用`dart`新功能，在block中直接迴圈使用
  service.multiUpload(99, {
    for (var i = 0; i < 5; i++)
      "file$i": UploadFileInfo(
          File('/Users/liaojianxun/Downloads/Resume.docx'), 'test$i.docx'),
  });
}
```
