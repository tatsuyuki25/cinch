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

## Quick Start

### Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  cinch: ^5.0.2

dev_dependencies:
  cinch_gen: ^5.0.0
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

## Migration Guide

### From 3.X.X to 4.0.0

After updating your dependencies, run the code generator:

```bash
dart run build_runner build
```

## Supported HTTP Methods

Cinch supports all major HTTP methods:

- **GET** - Retrieve data
- **POST** - Create new resources
- **PUT** - Update existing resources
- **DELETE** - Remove resources

## Advanced Features

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

#### Service-Level Validation

```dart
@ApiService('https://api.example.com/')
class CustomApi extends _$CustomApi {
  // Accept only 404 as valid response
  CustomApi() : super(validateStatus: (status) => status == 404);

  @Get('maybe-missing')
  Future<Response> checkResource() async {
    return _$checkResource();
  }
}
```

#### Method-Level Validation

Method-level validation overrides service-level validation:

```dart
@ApiService('https://api.example.com/')
class CustomApi extends _$CustomApi {
  CustomApi() : super(validateStatus: (status) => status == 404);

  // This method will only accept 403 as valid, ignoring the service-level validation
  @Get('restricted')
  @Get('api/restricted', validateStatus: [403, 200])
  Future<Response> getRestricted() async {
    return _$getRestricted();
  }
}
```

### Custom Headers

Add custom headers to your requests:

```dart
import 'dart:io';

@ApiService('https://api.example.com/')
class SecureApi extends _$SecureApi {
  @Get('protected-resource')
  Future<Response> getProtectedResource(
    @Header(HttpHeaders.authorizationHeader) String bearerToken,
    @Header('X-API-Version') String apiVersion,
  ) async {
    return _$getProtectedResource(bearerToken, apiVersion);
  }
}

// Usage
void secureApiExample() {
  final api = SecureApi();
  api.getProtectedResource('Bearer your-token-here', '2.0');
}
```

### Request Body

Send complex objects as JSON request body:

```dart
@ApiService('https://api.example.com/')
class DataApi extends _$DataApi {
  @Post('users')
  Future<Response> createUser(@Body() CreateUserRequest userData) async {
    return _$createUser(userData);
  }
}

class CreateUserRequest {
  final String name;
  final String email;
  final int age;
  final List<String> interests;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.age,
    required this.interests,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'age': age,
        'interests': interests,
      };
}

// Usage
void createUserExample() {
  final api = DataApi();
  
  api.createUser(CreateUserRequest(
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    interests: ['programming', 'reading'],
  ));
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
