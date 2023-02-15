import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'cinch_annotations.dart';
import 'utils.dart';

/// 藉由build_runner實現
///
/// Http request service
abstract class Service implements ApiUrlMixin {
  /// [baseUrl] URL
  ///
  /// [connectTimeout] default 5 seconds.
  ///
  /// [receiveTimeout] default 10 seconds.
  ///
  /// [sendTimeout] default 10 seconds.
  Service(this.baseUrl,
      {this.connectTimeout = const Duration(seconds: 5),
      this.receiveTimeout = const Duration(seconds: 10),
      this.sendTimeout = const Duration(seconds: 10),
      this.validateStatus}) {
    dio = Dio(BaseOptions(
        baseUrl: _getInitialUrl(),
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        validateStatus: validateStatus,
        headers: <String, dynamic>{Headers.contentEncodingHeader: 'gzip'},
        responseType: ResponseType.json));
  }

  /// The dio object
  ///
  /// By default add header `content-encoding: gzip`
  ///
  /// [ResponseType] default set [ResponseType.json]
  @visibleForTesting
  late Dio dio;

  /// URL
  final String baseUrl;

  /// connect timeout
  final Duration connectTimeout;

  /// receive timeout
  final Duration receiveTimeout;

  /// send timeout
  final Duration sendTimeout;

  /// `validateStatus` defines whether the request is successful for a given
  /// HTTP response status code. If `validateStatus` returns `true` ,
  /// the request will be perceived as successful; otherwise, considered as failed.
  final ValidateStatus? validateStatus;

  /// dio interceptors
  Interceptors get interceptors => dio.interceptors;

  /// dio httpClientAdapter
  HttpClientAdapter get httpClientAdapter => dio.httpClientAdapter;
  set httpClientAdapter(HttpClientAdapter adapter) =>
      dio.httpClientAdapter = adapter;

  /// dio transformer
  Transformer get transformer => dio.transformer;
  set transformer(Transformer transformer) => dio.transformer = transformer;

  @override
  String get url => '';

  /// 更改Url
  void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  /// 取得初始Url
  String _getInitialUrl() {
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    } else if (url.isNotEmpty) {
      return url;
    }
    throw Exception('Url not set!');
  }

  /// 傳送API
  ///
  /// [config] function的標籤
  ///
  /// [params] function的參數及參數標籤
  ///
  /// Return [Future]
  Future<Response<dynamic>> request(
      List<dynamic> config, List<Pair> params) async {
    final method = _parseHttpMethod(config);
    final options = _getOptions(config);
    final parseData = _parseParam(method, config, params);
    final path = parseData.first;
    final query = parseData.second;
    final data = parseData.third;

    if (method is Post) {
      // ignore: implicit_dynamic_method
      return dio.post<dynamic>(path,
          options: options,
          data: _hasMultipart(config) ? FormData.fromMap(data) : data,
          queryParameters: query);
    } else if (method is Get) {
      // ignore: implicit_dynamic_method
      return dio.get<dynamic>(path, options: options, queryParameters: query);
    } else if (method is Put) {
      // ignore: implicit_dynamic_method
      return dio.put<dynamic>(path,
          options: options, data: data, queryParameters: query);
    } else if (method is Delete) {
      // ignore: implicit_dynamic_method
      return dio.delete<dynamic>(path,
          options: options, data: data, queryParameters: query);
    }
    throw Exception('Unsupported HTTP Method: $method');
  }

  /// 是否為application/x-www-form-urlencoded
  bool _hasFormUrlEncoded(List<dynamic> config) {
    return config.any((dynamic c) => c == formUrlEncoded);
  }

  /// 是否為`Multipart`
  bool _hasMultipart(List<dynamic> config) {
    return config.any((dynamic c) => c == multipart);
  }

  /// 根據[config]產生 dio [Options]
  ///
  /// [config] function的標籤
  ///
  /// Return [Options]
  Options _getOptions(List<dynamic> config) {
    return Options(
        contentType: _hasFormUrlEncoded(config)
            ? Headers.formUrlEncodedContentType
            : null);
  }

  /// 根據[config] 解析http method
  ///
  /// Return [Http]
  Http _parseHttpMethod(List<dynamic> config) {
    final http = config.whereType<Http>();
    if (http.length > 1) {
      throw Exception('Only one http method can be set.');
    }
    if (http.isEmpty) {
      throw Exception('Http method must be set.');
    }
    return http.first;
  }

  /// 驗證`method`的`meta`是否正確設置
  void _verifiedConfig(List<dynamic> config, List<Pair> params) {
    final hasField = params.any((p) => p.first is Field);
    final hasFormUrlEncoded = _hasFormUrlEncoded(config);
    final hasPart = params.any((p) => p.first is Part || p.first == partMap);
    final hasMultipart = _hasMultipart(config);
    if (hasField && hasPart) {
      throw Exception('Only one of them can be set between Field and Part.');
    }
    if (hasFormUrlEncoded && hasMultipart) {
      throw Exception(
          'Only one of them can be set between FormUrlEncoded and Multipart.');
    }
    if (hasPart && !hasMultipart) {
      throw Exception('Part must be set multipart');
    }
  }

  /// 解析 path, query string, post data
  ///
  /// Return [Triple] first: path, second: query string, third: post data
  Triple<String, Map<String, dynamic>, Map<String, dynamic>> _parseParam(
      Http method, List<dynamic> config, List<Pair> params) {
    _verifiedConfig(config, params);
    var path = method.path;
    final query = <String, dynamic>{};
    final data = <String, dynamic>{};

    for (var pair in params) {
      path = _parsePath(path, pair);
      _parseQuery(query, pair);
      _parseFormData(data, pair);
    }
    return Triple(path, query, data);
  }

  /// 解析 [pair] path
  /// [path] 路徑
  ///
  /// Return path
  String _parsePath(String path, Pair pair) {
    final dynamic metadata = pair.first;
    if (metadata is Path) {
      if (pair.second is! String) {
        throw Exception('Path must be String');
      }
      final exp = RegExp('{${metadata.value}}');
      if (!exp.hasMatch(path)) {
        throw Exception('must be set {${metadata.value}}');
      }
      path = path.replaceAll(exp, pair.second);
    }
    return path;
  }

  /// 解析 [pair] query string
  ///
  /// [query] query string 集合
  void _parseQuery(Map<String, dynamic> query, Pair pair) {
    final dynamic metadata = pair.first;
    if (metadata is Query) {
      final dynamic first = pair.first.value;
      final dynamic second = pair.second;
      if (second == null && !metadata.keepNull) {
        return;
      }
      if (first is String && first.endsWith('[]') && second is List) {
        final listKey = first.substring(0, first.lastIndexOf('['));
        for (int i = 0; i < second.length; i++) {
          query['$listKey[$i]'] = _getData(second[i]);
        }
      } else {
        query[pair.first.value] = pair.second;
      }
    }
  }

  /// 解析 [pair] field
  ///
  /// [query] field 集合
  void _parseFormData(Map<String, dynamic> form, Pair pair) {
    final dynamic metadata = pair.first;
    if (metadata is Field || metadata is Part) {
      final dynamic first = pair.first.value;
      final dynamic second = pair.second;
      if (second == null && !metadata.keepNull) {
        return;
      }
      if (first is String && first.endsWith('[]') && second is List) {
        final listKey = first.substring(0, first.lastIndexOf('['));
        for (int i = 0; i < second.length; i++) {
          form['$listKey[$i]'] = _getData(second[i]);
        }
      } else {
        form[first] = _getData(second);
      }
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
        data is MultipartFile) {
      return data;
    } else if (data == null) {
      return null;
    } else if (data is List) {
      return data
          .map<dynamic>((dynamic e) => e == null ? null : _getData(e))
          .toList();
    } else {
      return data.toJson();
    }
  }
}
