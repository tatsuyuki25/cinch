import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'cinch_annotations.dart';
import 'utils.dart';

/// 藉由build_runner實現
///
/// Http request service
abstract class Service {
  /// dio 實體
  /// Header預設 content-encoding: gzip
  /// [ResponseType] 預設 [ResponseType.json]
  Dio _dio;

  /// URL
  final String baseUrl;

  /// 連線逾時
  final Duration connectTimeout;

  /// 讀取逾時
  final Duration receiveTimeout;

  /// dio interceptors
  Interceptors get interceptors => _dio.interceptors;

  /// dio httpClientAdapter
  HttpClientAdapter get httpClientAdapter => _dio.httpClientAdapter;

  /// [baseUrl] URL
  ///
  /// [connectTimeout] 連線逾時，預設5秒
  ///
  /// [receiveTimeout] 讀取逾時，預設10秒
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

  /// 更改Url
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// 傳送API
  ///
  /// [config] function的標籤
  ///
  /// [params] function的參數及參數標籤
  ///
  /// Return [Future]
  Future request(List<dynamic> config, List<Pair> params) async {
    Http method = _parseHttpMethod(config);
    var options = _getOptions(config);
    var parseData = _parseParam(method, config, params);
    var path = parseData.first;
    var query = parseData.second;
    var data = parseData.third;

    if (method is Post) {
      return _dio.post(path,
          options: options,
          data: _hasMultipart(config) ? FormData.from(data) : data,
          queryParameters: query);
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

  /// 是否為application/x-www-form-urlencoded
  bool _hasFormUrlEncoded(List<dynamic> config) {
    return config.any((c) => c == formUrlEncoded);
  }

  /// 是否為`Mulitpart`
  bool _hasMultipart(List<dynamic> config) {
    return config.any((c) => c == multipart);
  }

  /// 根據[config]產生 dio [Options]
  ///
  /// [config] function的標籤
  ///
  /// Return [Options]
  Options _getOptions(List<dynamic> config) {
    return Options(
        contentType: _hasFormUrlEncoded(config)
            ? ContentType.parse("application/x-www-form-urlencoded")
            : null);
  }

  /// 根據[config] 解析http method
  ///
  /// Return [Http]
  Http _parseHttpMethod(List<dynamic> config) {
    Iterable<Http> http = config.where((c) => c is Http).whereType<Http>();
    if (http.length > 1) {
      throw Exception('Http method 設定超過一次');
    }
    if (http.length == 0) {
      throw Exception('請設定Http method');
    }
    return http.first;
  }

  /// 驗證`method`的`meta`是否正確設置
  void _verifedConfig(List<dynamic> config, List<Pair> params) {
    var hasField = params.any((p) => p.first is Field);
    var hasFormUrlEncoded = _hasFormUrlEncoded(config);
    var hasPart = params.any((p) => p.first is Part || p.first == partMap);
    var hasMultipart = _hasMultipart(config);
    if (hasField && hasPart) {
      throw Exception('Field跟Part一個API只能則一設置');
    }
    if (hasFormUrlEncoded && hasMultipart) {
      throw Exception('FormUrlEncoded跟Multipart一個API只能則一設置');
    }
    if (hasField && !hasFormUrlEncoded) {
      throw Exception('Field必須設定FormUrlEncoded');
    }
    if (hasPart && !hasMultipart) {
      throw Exception('Part必須設定multipart');
    }
  }

  /// 解析 path, query string, post data
  ///
  /// Return [Tirple] first: path, second: query string, third: post data
  Tirple<String, Map<String, dynamic>, Map<String, dynamic>> _parseParam(
      Http method, List<dynamic> config, List<Pair> params) {
    _verifedConfig(config, params);
    String path = method.path;
    var query = <String, dynamic>{};
    var data = <String, dynamic>{};

    params.forEach((pair) {
      path = _parsePath(path, pair);
      _parseQuery(query, pair);
      _parseFormData(data, pair);
    });
    return Tirple(path, query, data);
  }

  /// 解析 [pair] path
  /// [path] 路徑
  ///
  /// Return path
  String _parsePath(String path, Pair pair) {
    var metadata = pair.first;
    if (metadata is Path) {
      if (pair.second is! String) {
        throw Exception("Path的內容必須為String");
      }
      var exp = RegExp("{${metadata.value}}");
      if (!exp.hasMatch(path)) {
        throw Exception("必須設置{${metadata.value}}");
      }
      path = path.replaceAll(exp, pair.second);
    }
    return path;
  }

  /// 解析 [pair] query string
  ///
  /// [query] query string 集合
  void _parseQuery(Map<String, dynamic> query, Pair pair) {
    var metadata = pair.first;
    if (metadata is Query) {
      query[pair.first.value] = pair.second;
    }
  }

  /// 解析 [pair] field
  ///
  /// [query] field 集合
  void _parseFormData(Map<String, dynamic> form, Pair pair) {
    var metadata = pair.first;
    if (metadata is Field || metadata is Part) {
      form[pair.first.value] = _getData(pair.second);
    } else if (metadata == partMap) {
      form.addAll(pair.second);
    }
  }

  /// 解析 field資料格式
  ///
  /// Return 解析完的資料
  dynamic _getData(dynamic data) {
    if (data is num ||
        data is String ||
        data is bool ||
        data is UploadFileInfo) {
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
