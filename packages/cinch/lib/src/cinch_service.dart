import 'package:dio/dio.dart';

import 'cinch_annotations.dart';
import 'utils.dart';

/// Implemented via build_runner
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
  /// By default, adds the header `content-encoding: gzip`
  ///
  /// [ResponseType] is set to [ResponseType.json] by default
  late Dio dio;

  /// URL
  final String baseUrl;

  /// Connection timeout
  final Duration connectTimeout;

  /// Receive timeout
  final Duration receiveTimeout;

  /// Send timeout
  final Duration sendTimeout;

  /// `validateStatus` defines whether the request is successful for a given
  /// HTTP response status code. If `validateStatus` returns `true`,
  /// the request will be perceived as successful; otherwise, it will be considered failed.
  final ValidateStatus? validateStatus;

  /// Dio interceptors
  Interceptors get interceptors => dio.interceptors;

  /// Dio httpClientAdapter
  HttpClientAdapter get httpClientAdapter => dio.httpClientAdapter;
  set httpClientAdapter(HttpClientAdapter adapter) =>
      dio.httpClientAdapter = adapter;

  /// Dio transformer
  Transformer get transformer => dio.transformer;
  set transformer(Transformer transformer) => dio.transformer = transformer;

  @override
  String get url => '';

  /// Change the base URL
  void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  /// Get the initial URL
  String _getInitialUrl() {
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    } else if (url.isNotEmpty) {
      return url;
    }
    throw Exception('URL not set!');
  }

  /// Send an API request
  ///
  /// [config] Function's metadata
  ///
  /// [params] Function's parameters and their metadata
  ///
  /// Returns [Future]
  Future<Response<dynamic>> request(
      List<dynamic> config, List<(dynamic, dynamic)> params) async {
    final method = _parseHttpMethod(config);
    final parseData = _parseParam(method, config, params);
    final path = parseData.$1;
    final headers = parseData.$2;
    final query = parseData.$3;
    final data = parseData.$4;
    final body = parseData.$5;

    final options = _getOptions(config, method, headers);

    if (method is Post) {
      // ignore: implicit_dynamic_method
      return dio.post<dynamic>(path,
          options: options,
          data: _hasMultipart(config) ? FormData.fromMap(data) : body ?? data,
          queryParameters: query);
    } else if (method is Get) {
      // ignore: implicit_dynamic_method
      return dio.get<dynamic>(path, options: options, queryParameters: query);
    } else if (method is Put) {
      // ignore: implicit_dynamic_method
      return dio.put<dynamic>(path,
          options: options, data: body ?? data, queryParameters: query);
    } else if (method is Delete) {
      // ignore: implicit_dynamic_method
      return dio.delete<dynamic>(path,
          options: options, data: body ?? data, queryParameters: query);
    }
    throw Exception('Unsupported HTTP Method: $method');
  }

  /// Checks if the content type is application/x-www-form-urlencoded
  bool _hasFormUrlEncoded(List<dynamic> config) {
    return config.any((dynamic c) => c == formUrlEncoded);
  }

  /// Checks if the content type is `Multipart`
  bool _hasMultipart(List<dynamic> config) {
    return config.any((dynamic c) => c == multipart);
  }

  /// Generates dio [Options] based on [config]
  ///
  /// Returns [Options]
  Options _getOptions(
      List<dynamic> config, Http method, Map<String, dynamic> headers) {
    ValidateStatus? validateStatus;
    if (method.validateStatus.isNotEmpty) {
      validateStatus = (status) => method.validateStatus.contains(status);
    }
    return Options(
      contentType: _hasFormUrlEncoded(config)
          ? Headers.formUrlEncodedContentType
          : Headers.jsonContentType,
      headers: headers,
      validateStatus: validateStatus,
    );
  }

  /// Parses the HTTP method from [config]
  ///
  /// Returns [Http]
  Http _parseHttpMethod(List<dynamic> config) {
    final http = config.whereType<Http>();
    if (http.length > 1) {
      throw Exception('Only one HTTP method can be set.');
    }
    if (http.isEmpty) {
      throw Exception('HTTP method must be set.');
    }
    return http.first;
  }

  /// Validates if the `method` metadata is correctly set
  void _verifiedConfig(List<dynamic> config, List<(dynamic, dynamic)> params) {
    final hasField = params.any((p) => p.$1 is Field);
    final hasFormUrlEncoded = _hasFormUrlEncoded(config);
    final hasPart = params.any((p) => p.$1 is Part || p.$2 == partMap);
    final hasMultipart = _hasMultipart(config);
    if (hasField && hasPart) {
      throw Exception('Only one of them can be set between Field and Part.');
    }
    if (hasFormUrlEncoded && hasMultipart) {
      throw Exception(
          'Only one of them can be set between FormUrlEncoded and Multipart.');
    }
    if (hasPart && !hasMultipart) {
      throw Exception('Part must be set as multipart.');
    }
  }

  /// Parses path, query string, and post data
  ///
  /// Returns path, headers, query string, post data
  (
    String,
    Map<String, dynamic>,
    Map<String, dynamic>,
    Map<String, dynamic>,
    dynamic
  ) _parseParam(
      Http method, List<dynamic> config, List<(dynamic, dynamic)> params) {
    _verifiedConfig(config, params);
    var path = method.path;
    final query = <String, dynamic>{};
    final data = <String, dynamic>{};
    final headers = <String, dynamic>{};
    dynamic body;

    for (var pair in params) {
      path = _parsePath(path, pair);
      _parseQuery(query, pair);
      _parseFormData(data, pair);
      _parseHeader(headers, pair);
      if (data.isEmpty) {
        body = _parseBody(data, pair);
      }
    }
    return (path, headers, query, data, body);
  }

  /// Parses [pair] path
  /// [path] Path
  ///
  /// Returns path
  String _parsePath(String path, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Path) {
      if (pair.$2 is! String) {
        throw Exception('Path must be a String');
      }
      final exp = RegExp('{${metadata.value}}');
      if (!exp.hasMatch(path)) {
        throw Exception('Must set {${metadata.value}}');
      }
      path = path.replaceAll(exp, pair.$2);
    }
    return path;
  }

  void _parseHeader(Map<String, dynamic> headers, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Header) {
      headers[metadata.value] = pair.$2;
    }
  }

  /// Parses [pair] query string
  ///
  /// [query] Query string collection
  void _parseQuery(Map<String, dynamic> query, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Query) {
      final dynamic first = pair.$1.value;
      final dynamic second = pair.$2;
      if (second == null && !metadata.keepNull) {
        return;
      }
      if (first is String && first.endsWith('[]') && second is List) {
        final listKey = first.substring(0, first.lastIndexOf('['));
        for (int i = 0; i < second.length; i++) {
          query['$listKey[$i]'] = _getData(second[i]);
        }
      } else {
        query[pair.$1.value] = pair.$2;
      }
    }
  }

  /// Parses [pair] field
  ///
  /// [query] Field collection
  void _parseFormData(Map<String, dynamic> form, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Field || metadata is Part) {
      final dynamic first = pair.$1.value;
      final dynamic second = pair.$2;
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
      form.addAll(pair.$2);
    }
  }

  dynamic _parseBody(dynamic data, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Body) {
      return _getData(pair.$2);
    }
  }

  /// Parses field data format
  ///
  /// Returns the parsed data
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
