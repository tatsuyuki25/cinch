import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'cinch_annotations.dart';
import 'utils.dart';

typedef Future<Options> MetadataInterceptor(
    Options options, List<dynamic> metadata);
typedef Map<String, dynamic> DataInterceptor(List<dynamic> metadata);

abstract class BaseService {
  @protected
  Service service;
}
class Test extends Service {
  Test(String baseUrl) : super(baseUrl);

}
class Service {
  Dio _dio;

  final String baseUrl;

  final Duration connectTimeout;

  final Duration receiveTimeout;

  Interceptors get interceptors => _dio.interceptors;

  Service(this.baseUrl,
      {this.connectTimeout = const Duration(seconds: 5),
      this.receiveTimeout = const Duration(seconds: 10)}) {
    _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout.inMilliseconds,
        receiveTimeout: receiveTimeout.inMilliseconds,
        headers: {HttpHeaders.contentEncodingHeader: 'gzip'},
        responseType: ResponseType.json));
  }

  Future request(List<dynamic> config, List<Pair> params) async {
    Http method = _parseHttpMethod(config);
    var options = _getOptions(config);
    var parseData =_parseParam(method, config, params);
    var path = parseData.first;
    var query = parseData.second;
    var data = parseData.third;
  
    if (method is Post) {
      return _dio.post(path,
          options: options, data: data, queryParameters: query);
    } else if (method is Get) {
      return _dio.get(path, options: options, queryParameters: query);
    } else if (method is Put) {
      return _dio.put(path,
          options: options, data: data, queryParameters: query);
    } else if (method is Delete) {
      return _dio.delete(path,
          options: options, data: data, queryParameters: query);
    }
    throw Exception('沒有支援的HTTP Method');
  }

  Options _getOptions(List<dynamic> config) {
    return Options(
        contentType: config.any((c) => c == fromUrlEncoded)
            ? ContentType.parse("application/x-www-form-urlencoded")
            : ContentType.text);
  }

  Http _parseHttpMethod(List<dynamic> config) {
    List<Http> http = config.where((c) => c is Http);
    if (http.length > 1) {
      throw Exception('Http method 設定超過一次');
    }
    if (http.length == 0) {
      throw Exception('請設定Http method');
    }
    return http[0];
  }

  Tirple<String, Map<String, dynamic>, Map<String, dynamic>> _parseParam(
      Http method, List<dynamic> config, List<Pair> params) {
    if (params.any((p) => p.first is Field) &&
        !config.any((c) => c == fromUrlEncoded)) {
      throw Exception('Field必須設定FromUrlEncoded');
    }
    String path = method.path;
    var query = <String, dynamic>{};
    var data = <String, dynamic>{};

    params.forEach((pair) {
      path = _parsePath(path, pair);
      _parseQuery(query, pair);
      _parseField(data, pair);
    });
    return Tirple(path, query, data);
  }

  String _parsePath(String path, Pair pair) {
    var metadata = pair.first;
    if (metadata is Path) {
      if (pair.second is! String) {
        throw Exception("Path的內容必須為String");
      }
      var exp = RegExp("{${metadata.value}}");
      if (!exp.hasMatch(pair.second)) {
        throw Exception("必須設置{${metadata.value}}");
      }
      path = path.replaceAll(exp, pair.second);
    }
    return path;
  }

  void _parseQuery(Map<String, dynamic> query, Pair pair) {
    var metadata = pair.first;
    if (metadata is Query) {
      query[pair.first.value] = pair.second;
    }
  }

  void _parseField(Map<String, dynamic> field, Pair pair) {
    var metadata = pair.first;
    if (metadata is Field) {
      field[pair.first.value] = _getData(pair.second);
    }
  }

  dynamic _getData(dynamic data) {
    if (data is num) {
      return data;
    } else if (data is String) {
      return data;
    } else if (data is bool) {
      return data;
    } else if (data == null) {
      return null;
    } else if (data is List) {
      return data.map((e) => e == null ? null : _getData(e)).toList();
    } else {
      return data.toJson();
    }
  }
}
