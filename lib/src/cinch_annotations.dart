
/// API標籤 
class ApiService {
  final String url;
  const ApiService(this.url);
}

/// Http Query
class Query {
  final String value;

  const Query(this.value);
}

/// Http Field 搭配 fromUrlEncoded使用
class Field {
  final String value;

  const Field(this.value);
}

/// Multipart 資料
class Part {
  final String value;

  const Part(this.value);
}

/// Multipart 資料 [Map]形式
class _PartMap {
  const _PartMap();
}

/// Multipart 資料 [Map]形式
const _PartMap partMap = _PartMap();

/// 路徑格式化
class Path {
  final String value;

  const Path(this.value);
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
  final String path;
  const Http(this.path);
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