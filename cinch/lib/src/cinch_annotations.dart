import 'package:cinch/cinch.dart';

/// API Service
class ApiService {
  const ApiService(this.url);

  /// Empty URL
  const ApiService.emptyUrl() : this('');

  /// Do not check URL
  const ApiService.uncheckUrl() : this('InitialUrl does not check');
  final String url;
}

class Parameter {
  const Parameter();
}

/// HTTP Body
class Body extends Parameter {
  const Body();
}

/// HTTP Query
class Query extends Parameter {
  const Query(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// HTTP Field used with fromUrlEncoded
class Field extends Parameter {
  const Field(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// Multipart data
class Part extends Parameter {
  const Part(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// Multipart data in [Map] format
class _PartMap extends Parameter {
  const _PartMap();
}

/// Multipart data in [Map] format
const _PartMap partMap = _PartMap();

/// Path formatting
class Path extends Parameter {
  const Path(this.value);
  final String value;
}

/// HTTP Header
class Header extends Parameter {
  const Header(this.value);
  final String value;
}

class _FormUrlEncoded {
  const _FormUrlEncoded();
}

/// application/x-www-form-urlencoded
const _FormUrlEncoded formUrlEncoded = _FormUrlEncoded();

class _Multipart {
  const _Multipart();
}

/// multipart/form-data
const _Multipart multipart = _Multipart();

class Http {
  const Http(this.path, {this.validateStatus = const []});

  /// HTTP path.
  final String path;

  /// `validateStatus` defines whether the request is successful for a given
  /// HTTP response status code.
  ///
  /// If set, [Service.validateStatus] will be ignored.
  final List<int> validateStatus;
}

/// HTTP Post
class Post extends Http {
  const Post(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// HTTP Get
class Get extends Http {
  const Get(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// HTTP Put
class Put extends Http {
  const Put(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// HTTP Delete
class Delete extends Http {
  const Delete(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}
