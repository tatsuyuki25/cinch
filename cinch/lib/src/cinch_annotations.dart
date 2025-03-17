import 'package:cinch/cinch.dart';

/// API標籤
class ApiService {
  const ApiService(this.url);

  /// 空的url
  const ApiService.emptyUrl() : this('');

  /// 不檢查url
  const ApiService.uncheckUrl() : this('InitialUrl不檢查');
  final String url;
}

class Parameter {
  const Parameter();
}

class Body extends Parameter {
  const Body();
}

/// Http Query
class Query extends Parameter {
  const Query(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// Http Field 搭配 fromUrlEncoded使用
class Field extends Parameter {
  const Field(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// Multipart 資料
class Part extends Parameter {
  const Part(this.value, {this.keepNull = false});
  final String value;
  final bool keepNull;
}

/// Multipart 資料 [Map]形式
class _PartMap extends Parameter {
  const _PartMap();
}

/// Multipart 資料 [Map]形式
const _PartMap partMap = _PartMap();

/// 路徑格式化
class Path extends Parameter {
  const Path(this.value);
  final String value;
}

/// Http Header
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

  /// http path.
  final String path;

  /// `validateStatus` defines whether the request is successful for a given
  /// HTTP response status code.
  ///
  /// If set this, [Service.validateStatus] will be ignored.
  final List<int> validateStatus;
}

/// Http Post
class Post extends Http {
  const Post(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// Http Get
class Get extends Http {
  const Get(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// Http Put
class Put extends Http {
  const Put(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// Http Delete
class Delete extends Http {
  const Delete(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}
