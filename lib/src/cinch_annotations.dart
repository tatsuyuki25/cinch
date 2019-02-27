import 'package:dio/dio.dart';

class ApiService {
  final String url;
  const ApiService(this.url);
}

class Query {
  final String value;

  const Query(this.value);
}

class Field {
  final String value;

  const Field(this.value);
}

class Path {
  final String value;

  const Path(this.value);
}

class _FromUrlEncoded {
  const _FromUrlEncoded();
}

const _FromUrlEncoded fromUrlEncoded = _FromUrlEncoded();

class Http {
  final String path;
  const Http(this.path);
}

class Post extends Http {
  const Post(String path) : super(path);
}

class Get extends Http {
  const Get(String path) : super(path);
}

class Put extends Http {
  const Put(String path) : super(path);
}

class Delete extends Http {
  const Delete(String path) : super(path);
}
