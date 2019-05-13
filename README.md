# cinch

![VERSION](https://img.shields.io/badge/Version-1.0.5-blue.svg)

## Usage

```yaml
dependencies:
  cinch:
    hosted:
      name: cinch
      url: http://172.16.65.36:8080
    version: ^1.0.6
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
  @fromUrlEncoded
  @Post('api/test')
  Future<WebGlobalJson<Login>> test(@Field('t1') String t1) async {
    return _$test(t1);
  }
```

## Path

```dart
  @fromUrlEncoded
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
