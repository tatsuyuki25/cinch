# Cinch

[![Pub](https://img.shields.io/pub/v/cinch.svg?style=flat-square)](https://pub.dartlang.org/packages/cinch)

A powerful HTTP client library for Dart/Flutter that uses code generation to create type-safe API clients with minimal boilerplate code.

## Features

- 🚀 **Code Generation**: Automatically generates HTTP client code using build_runner
- 🔧 **Type Safety**: Full type safety with compile-time validation
- 📝 **Multiple Content Types**: Support for JSON, form data, and multipart uploads
- 🛡️ **Custom Validation**: Flexible HTTP status code validation
- 🌐 **Dynamic URLs**: Multiple ways to configure base URLs
- 📊 **Rich Annotations**: Comprehensive set of annotations for different use cases

---

## 🚀 Migration Guide to v6.0.0

Version 6.0.0 introduces a significant **breaking change** in how generic types are deserialized. The new implementation aligns with the `genericArgumentFactories` pattern used by `freezed` and `json_serializable`, removing the old `fromNestedGenericJson` method.

### What You Need to Do

If you use custom generic classes for your API responses (e.g., `BaseResponse<T>`), you **must** update them to be compatible with the new generator.

**1. Update Your Generic Model:**

Modify your generic class to include a `fromJson` factory that accepts a `T Function(Object?) fromJsonT` argument. This function is responsible for deserializing the nested generic type `T`.

**Before (Old Way):**

```dart
// This approach is no longer supported.
class BaseResponse<T> {
  final T data;
  BaseResponse(this.data);

  factory BaseResponse.fromNestedGenericJson(Map<String, dynamic> json, List<Type> types) {
    // ... old logic ...
  }
}
```

**After (New Way with `freezed`):**

We strongly recommend using `freezed` to generate your data classes. It handles the `genericArgumentFactories` pattern automatically.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response.freezed.dart';
part 'base_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class BaseResponse<T> with _$BaseResponse<T> {
  const factory BaseResponse({
    required T data,
    // Add other fields like message, code, etc.
  }) = _BaseResponse;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$BaseResponseFromJson(json, fromJsonT);
}
```

**2. Update Your `pubspec.yaml`:**

Make sure your dependencies are updated to the latest version.

```yaml
dependencies:
  cinch: ^6.0.1

dev_dependencies:
  cinch_gen: ^6.0.0
  build_runner: ^2.0.0
  # Add freezed and json_serializable if you use them
  freezed: <latest_version>
  json_serializable: <latest_version>
```

**3. Regenerate Your Code:**

After updating your models and dependencies, run the build runner to regenerate the Cinch client code.

```bash
dart run build_runner build --delete-conflicting-outputs
```

By following these steps, your project will be aligned with the new, more robust deserialization mechanism.

---

## Quick Start

### Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  cinch: ^6.0.0

dev_dependencies:
  cinch_gen: ^6.0.0
  build_runner: ^2.0.0
```

### Basic Usage

1. **Create your API service** (`test.dart`):

    ```dart
    import 'package:cinch/cinch.dart';
    part 'test.cinch.dart';

    @ApiService('https://api.example.com/')
    class TestApi extends _$TestApi {
      TestApi() : super();

      @Get('users/{id}')
      Future<Response> getUser(@Path('id') String userId) async {
        return _$getUser(userId);
      }

      @Get('users')
      Future<Response> getUsers(@Query('page') int page) async {
        return _$getUsers(page);
      }
    }
    ```

2. **Generate the code**:

    Run the following command in your terminal:

    ```bash
    dart run build_runner build
    ```

3. **Use your API**:

    ```dart
    final api = TestApi();
    final response = await api.getUser('123');
    final users = await api.getUsers(1);
    ```

## Supported HTTP Methods

Cinch supports all major HTTP methods:

- **GET** - Retrieve data
- **POST** - Create new resources
- **PUT** - Update existing resources
- **DELETE** - Remove resources

## Key Features

### Form URL Encoded Requests

For `application/x-www-form-urlencoded` content type:

```dart
@ApiService('https://api.example.com/')
class AuthApi extends _$AuthApi {
  @formUrlEncoded
  @Post('auth/login')
  Future<Response<LoginResponse>> login(
    @Field('username') String username,
    @Field('password') String password,
  ) async {
    return _$login(username, password);
  }
}
```

### Path Parameters

Use path parameters for dynamic URLs:

```dart
@ApiService('https://api.example.com/')
class UserApi extends _$UserApi {
  @Get('users/{userId}/posts/{postId}')
  Future<Response> getUserPost(
    @Path('userId') String userId,
    @Path('postId') String postId,
  ) async {
    return _$getUserPost(userId, postId);
  }
}
```

### Dynamic URL Configuration

#### Method 1: Custom ApiService Class

```dart
import 'package:cinch/cinch.dart';
part 'api.cinch.dart';

class ProductionApi extends ApiService {
  const ProductionApi() : super("https://api.production.com/");
}

@ProductionApi()
class UserApi extends _$UserApi {
  UserApi() : super();
  
  @Get('users')
  Future<Response> getUsers() async {
    return _$getUsers();
  }
}
```

#### Method 2: ApiUrlMixin

```dart
import 'package:cinch/cinch.dart';
part 'api.cinch.dart';

class ApiConfig with ApiUrlMixin {
  @override
  String get url => 'https://api.example.com/';
}

@ApiService.emptyUrl()
class UserApi extends _$UserApi with ApiConfig {
  UserApi() : super();
  
  @Get('users')
  Future<Response> getUsers() async {
    return _$getUsers();
  }
}
```

### File Upload (Multipart)

#### Single File Upload

```dart
@ApiService('https://api.example.com/')
class FileApi extends _$FileApi {
  @Post('upload')
  @multipart
  Future<Response> uploadFile(@Part('file') MultipartFile file) {
    return _$uploadFile(file);
  }
}

// Usage
void uploadExample() {
  final api = FileApi();
  
  // From file path
  api.uploadFile(MultipartFile.fromFileSync(
    '/path/to/file.txt', 
    filename: 'document.txt'
  ));
  
  // From bytes
  api.uploadFile(MultipartFile.fromBytes(
    bytes, 
    filename: 'document.txt'
  ));
}
```

#### Multiple File Upload with PartMap

```dart
@ApiService('https://api.example.com/')
class FileApi extends _$FileApi {
  @Post('multi-upload')
  @multipart
  Future<Response> multiUpload(
    @Part('description') String description,
    @partMap Map<String, MultipartFile> files,
  ) {
    return _$multiUpload(description, files);
  }
}

// Usage
void multiUploadExample() {
  final api = FileApi();
  
  api.multiUpload('My files', {
    "file1": MultipartFile.fromFileSync('/path/file1.txt', filename: 'doc1.txt'),
    "file2": MultipartFile.fromFileSync('/path/file2.txt', filename: 'doc2.txt'),
  });
  
  // Dynamic file list
  api.multiUpload('Batch upload', {
    for (var i = 0; i < 5; i++)
      "file$i": MultipartFile.fromFileSync(
        '/path/file$i.txt', 
        filename: 'document$i.txt'
      ),
  });
}
```

### Custom Status Code Validation

Control which HTTP status codes should be considered successful:

```dart
@ApiService('https://api.example.com/')
class CustomApi extends _$CustomApi {
  // Service-level validation
  CustomApi() : super(validateStatus: (status) => status == 404);

  // Method-level validation (overrides service-level)
  @Get('restricted', validateStatus: [403, 200])
  Future<Response> getRestricted() async {
    return _$getRestricted();
  }
}
```

## Best Practices

1. **Organize your APIs**: Group related endpoints into separate service classes
2. **Use meaningful names**: Make your method and parameter names descriptive
3. **Handle errors**: Always wrap API calls in try-catch blocks
4. **Type safety**: Define response models for better type safety
5. **Documentation**: Add comments to your API methods for better maintainability

## Error Handling

```dart
try {
  final response = await api.getUser('123');
  // Handle successful response
} on DioException catch (e) {
  // Handle Dio-specific errors
  if (e.response?.statusCode == 404) {
    print('User not found');
  } else {
    print('API Error: ${e.message}');
  }
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

## Documentation

For complete documentation and advanced features, visit the [package documentation](packages/cinch/README.md).

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
