# cinch_gen

[![Pub](https://img.shields.io/pub/v/cinch_gen.svg?style=flat-square)](https://pub.dartlang.org/packages/cinch_gen)

A cinch gen.
See [main pub](https://pub.dartlang.org/packages/cinch)

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
  cinch: ^6.0.0

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
