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
  const Http(this.path);
  final String path;
}

/// Http Post
class Post extends Http {
  const Post(String path) : super(path);
}

/// Http Get
class Get extends Http {
  const Get(String path) : super(path);
}

/// Http Put
class Put extends Http {
  const Put(String path) : super(path);
}

/// Http Delete
class Delete extends Http {
  const Delete(String path) : super(path);
}
