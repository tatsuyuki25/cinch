# cinch

[![Pub](https://img.shields.io/pub/v/cinch.svg?style=flat-square)](https://pub.dartlang.org/packages/cinch)

## Usage

```yaml
dependencies:
  cinch: ^1.3.8
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

或

```dart
import 'package:cinch/cinch.dart';
part 'test.cinch.dart';

class Web with ApiUrlMixin {
  @override
  String get url => 'https://test.com/';
  
}

@ApiService.emptyUrl()
class TestApi extends _$TestApi with Web {
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
  Future<Response> upload(@Part('file') MultipartFile file) {
    return _$upload(file);
  }
}

void test() {
  service.upload(MultipartFile.fromFileSync('/path/file.txt', filename: '上傳名稱.txt'));
  service.upload(MultipartFile.fromBytes(bytes, filename: '上傳名稱.txt'));
}
```

- 如果有多欄位需要上傳， 可以搭配 `partMap` 使用

```dart
@ApiService('http://localhost:8080/')
class TestService extends _$TestService {
  @Post('multiUpload')
  @multipart
  Future<Response> multiUpload(@Part('flag') int flag,
  @partMap Map<String, MultipartFile> file) {
    return _$multiUpload(flag, file);
  }
}

void test() {
  service.multiUpload(88, {
    "file0": MultipartFile.fromFileSync(
        '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test0.docx'),
    "file1": MultipartFile.fromFileSync(
        '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test1.docx')
  });
  
  /// 也能使用`dart`新功能，在block中直接迴圈使用
  service.multiUpload(99, {
    for (var i = 0; i < 5; i++)
      "file$i": MultipartFile.fromFileSync(
          '/Users/liaojianxun/Downloads/Resume.docx', filename: 'test$i.docx'),
  });
}
```

## License

```license
MIT License

Copyright (c) 2020 tatsuyuki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
