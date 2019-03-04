
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

/// 路徑格式化
class Path {
  final String value;

  const Path(this.value);
}


class _FromUrlEncoded {
  const _FromUrlEncoded();
}

/// application/x-www-form-urlencoded
const _FromUrlEncoded fromUrlEncoded = _FromUrlEncoded();

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
