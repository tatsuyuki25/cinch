/// API標籤
class ApiService {
  const ApiService(this.url);

  /// 空的url
  const ApiService.emptyUrl() : this('');

  /// 不檢查url
  const ApiService.uncheckUrl() : this('InitialUrl不檢查');
  final String url;
}

/// Http Query
class Query {
  const Query(this.value);
  final String value;
}

/// Http Field 搭配 fromUrlEncoded使用
class Field {
  const Field(this.value);
  final String value;
}

/// Multipart 資料
class Part {
  const Part(this.value);
  final String value;
}

/// Multipart 資料 [Map]形式
class _PartMap {
  const _PartMap();
}

/// Multipart 資料 [Map]形式
const _PartMap partMap = _PartMap();

/// 路徑格式化
class Path {
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
