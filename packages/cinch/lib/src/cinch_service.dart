import 'package:dio/dio.dart';

import 'cinch_annotations.dart';
import 'utils.dart';

/// A service class that is implemented via build_runner code generation.
///
/// This abstract class provides HTTP request functionality and serves as a base
/// for generated service classes.
abstract class Service implements ApiUrlMixin {
  /// Creates a new service instance with the specified base URL and timeout configurations.
  ///
  /// [baseUrl] The base URL for all HTTP requests.
  ///
  /// [connectTimeout] The timeout duration for establishing connections (default: 5 seconds).
  ///
  /// [receiveTimeout] The timeout duration for receiving responses (default: 10 seconds).
  ///
  /// [sendTimeout] The timeout duration for sending requests (default: 10 seconds).
  ///
  /// [validateStatus] Optional custom status code validation function.
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

  /// The Dio HTTP client instance used for making requests.
  ///
  /// This instance is pre-configured with gzip compression support via the
  /// `content-encoding: gzip` header and has its response type set to JSON by default.
  late Dio dio;

  /// The base URL for all HTTP requests made by this service.
  final String baseUrl;

  /// The maximum duration allowed for establishing a connection to the server.
  final Duration connectTimeout;

  /// The maximum duration allowed for receiving a response from the server.
  final Duration receiveTimeout;

  /// The maximum duration allowed for sending a request to the server.
  final Duration sendTimeout;

  /// A custom function that defines whether an HTTP response status code
  /// should be considered successful. If this function returns `true`,
  /// the request will be perceived as successful; otherwise, it will be
  /// considered failed.
  final ValidateStatus? validateStatus;

  /// Gets the list of Dio interceptors that can be used to modify requests
  /// and responses globally.
  Interceptors get interceptors => dio.interceptors;

  /// Gets or sets the HTTP client adapter used by Dio for making actual
  /// HTTP requests.
  HttpClientAdapter get httpClientAdapter => dio.httpClientAdapter;
  set httpClientAdapter(HttpClientAdapter adapter) =>
      dio.httpClientAdapter = adapter;

  /// Gets or sets the transformer used by Dio for converting request and
  /// response data.
  Transformer get transformer => dio.transformer;
  set transformer(Transformer transformer) => dio.transformer = transformer;

  @override
  String get url => '';

  /// Updates the base URL for all subsequent HTTP requests.
  ///
  /// [url] The new base URL to use.
  void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  /// Determines the initial URL to use for HTTP requests.
  ///
  /// Returns the [baseUrl] if it's not empty, otherwise returns the [url]
  /// from the ApiUrlMixin. Throws an exception if neither is set.
  String _getInitialUrl() {
    if (baseUrl.isNotEmpty) {
      return baseUrl;
    } else if (url.isNotEmpty) {
      return url;
    }
    throw Exception('URL not set!');
  }

  /// Sends an HTTP request based on the provided configuration and parameters.
  ///
  /// [config] A list containing the function's metadata including HTTP method,
  /// content type, and other configuration options.
  ///
  /// [params] A list of tuples containing the function's parameters and their
  /// associated metadata (e.g., Path, Query, Field, etc.).
  ///
  /// Returns a [Future] that resolves to a Dio [Response] containing the
  /// server's response data.
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

  /// Checks whether the configuration specifies `application/x-www-form-urlencoded`
  /// as the content type.
  ///
  /// [config] The configuration list to check.
  ///
  /// Returns `true` if form URL encoding is specified, `false` otherwise.
  bool _hasFormUrlEncoded(List<dynamic> config) {
    return config.any((dynamic c) => c == formUrlEncoded);
  }

  /// Checks whether the configuration specifies `multipart/form-data`
  /// as the content type.
  ///
  /// [config] The configuration list to check.
  ///
  /// Returns `true` if multipart encoding is specified, `false` otherwise.
  bool _hasMultipart(List<dynamic> config) {
    return config.any((dynamic c) => c == multipart);
  }

  /// Creates Dio request options based on the provided configuration.
  ///
  /// [config] The configuration list containing content type and other options.
  /// [method] The HTTP method containing validation status codes.
  /// [headers] Additional headers to include in the request.
  ///
  /// Returns a configured [Options] object for the Dio request.
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

  /// Extracts and validates the HTTP method from the configuration list.
  ///
  /// [config] The configuration list that should contain exactly one HTTP method.
  ///
  /// Returns the [Http] method found in the configuration.
  ///
  /// Throws an [Exception] if no HTTP method is found or if multiple methods are specified.
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

  /// Validates that the configuration and parameters are consistent and correct.
  ///
  /// This method ensures that:
  /// - Field and Part annotations are not used together
  /// - FormUrlEncoded and Multipart annotations are not used together
  /// - Part annotations are only used with Multipart content type
  ///
  /// [config] The configuration list to validate.
  /// [params] The parameter list to validate.
  ///
  /// Throws an [Exception] if any validation rules are violated.
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

  /// Parses the method configuration and parameters to extract request components.
  ///
  /// This method processes the HTTP method, configuration, and parameters to build
  /// the final request URL path, headers, query parameters, and request body data.
  ///
  /// [method] The HTTP method configuration.
  /// [config] The request configuration list.
  /// [params] The parameter list with their metadata.
  ///
  /// Returns a tuple containing:
  /// - String: The processed URL path
  /// - Map&lt;String, dynamic&gt;: Request headers
  /// - Map&lt;String, dynamic&gt;: Query parameters
  /// - Map&lt;String, dynamic&gt;: Form/multipart data
  /// - dynamic: Raw request body (for non-form requests)
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

  /// Processes path parameters and replaces placeholders in the URL path.
  ///
  /// [path] The URL path template containing placeholders like `{id}`.
  /// [pair] A tuple containing parameter metadata and its value.
  ///
  /// Returns the processed path with placeholders replaced by actual values.
  ///
  /// Throws an [Exception] if the path parameter is not a String or if the
  /// placeholder is not found in the path template.
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

  /// Processes header parameters and adds them to the headers map.
  ///
  /// [headers] The map to store processed headers.
  /// [pair] A tuple containing parameter metadata and its value.
  void _parseHeader(Map<String, dynamic> headers, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Header) {
      headers[metadata.value] = pair.$2;
    }
  }

  /// Processes query parameters and adds them to the query parameters map.
  ///
  /// This method handles both simple query parameters and array parameters
  /// (indicated by the `[]` suffix). It respects the `keepNull` setting
  /// to determine whether null values should be included.
  ///
  /// [query] The map to store processed query parameters.
  /// [pair] A tuple containing parameter metadata and its value.
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

  /// Processes form data parameters for both regular forms and multipart forms.
  ///
  /// This method handles Field, Part, and PartMap annotations. It processes
  /// array parameters (indicated by the `[]` suffix) and respects the
  /// `keepNull` setting for optional parameters.
  ///
  /// [form] The map to store processed form data.
  /// [pair] A tuple containing parameter metadata and its value.
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

  /// Processes body parameters for requests that send raw data.
  ///
  /// [data] The current data map (unused in this context).
  /// [pair] A tuple containing parameter metadata and its value.
  ///
  /// Returns the processed body data if the parameter is annotated with @Body,
  /// otherwise returns null.
  dynamic _parseBody(dynamic data, (dynamic, dynamic) pair) {
    final dynamic metadata = pair.$1;
    if (metadata is Body) {
      return _getData(pair.$2);
    }
  }

  /// Converts data to an appropriate format for HTTP transmission.
  ///
  /// This method handles various data types and converts complex objects
  /// to JSON format when necessary. It preserves primitive types, multipart
  /// files, and null values as-is.
  ///
  /// [data] The data to be processed.
  ///
  /// Returns the processed data in a format suitable for HTTP transmission.
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
