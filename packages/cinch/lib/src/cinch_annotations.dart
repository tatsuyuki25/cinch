/// An annotation that marks a class as an API service and specifies its base URL.
///
/// This annotation is used by the code generator to create HTTP service implementations.
/// The generated service will use the specified URL as the base URL for all API endpoints.
class ApiService {
  /// Creates an API service annotation with the specified base URL.
  ///
  /// [url] The base URL for all API endpoints in this service.
  const ApiService(this.url);

  /// Creates an API service annotation with an empty URL.
  ///
  /// This constructor is useful when the base URL will be provided at runtime
  /// or through other configuration mechanisms.
  const ApiService.emptyUrl() : this('');

  /// Creates an API service annotation that bypasses URL validation.
  ///
  /// This constructor should be used when URL validation is not desired
  /// during the code generation process.
  const ApiService.uncheckUrl() : this('InitialUrl does not check');

  /// The base URL for all API endpoints in this service.
  final String url;
}

/// Base class for all HTTP request parameter annotations.
///
/// This class serves as the foundation for all parameter-related annotations
/// such as Query, Field, Path, etc.
class Parameter {
  /// Creates a base parameter annotation.
  const Parameter();
}

/// An annotation that marks a parameter as the HTTP request body.
///
/// The annotated parameter will be serialized and sent as the request body.
/// This is typically used for POST, PUT, and PATCH requests that need to
/// send complex data structures.
class Body extends Parameter {
  /// Creates a body parameter annotation.
  const Body();
}

/// An annotation that marks a parameter as an HTTP query parameter.
///
/// Query parameters are appended to the URL and are typically used for
/// filtering, pagination, or other request modifications.
class Query extends Parameter {
  /// Creates a query parameter annotation.
  ///
  /// [value] The name of the query parameter as it will appear in the URL.
  /// [keepNull] Whether to include this parameter in the request when its value is null.
  /// Defaults to false, meaning null values will be omitted from the request.
  const Query(this.value, {this.keepNull = false});

  /// The name of the query parameter as it will appear in the URL.
  final String value;

  /// Whether to include this parameter in the request when its value is null.
  final bool keepNull;
}

/// An annotation that marks a parameter as an HTTP form field.
///
/// This annotation is used with `application/x-www-form-urlencoded` content type.
/// Form fields are encoded as key-value pairs in the request body.
class Field extends Parameter {
  /// Creates a form field parameter annotation.
  ///
  /// [value] The name of the form field.
  /// [keepNull] Whether to include this field in the request when its value is null.
  /// Defaults to false, meaning null values will be omitted from the request.
  const Field(this.value, {this.keepNull = false});

  /// The name of the form field.
  final String value;

  /// Whether to include this field in the request when its value is null.
  final bool keepNull;
}

/// An annotation that marks a parameter as a multipart form data part.
///
/// This annotation is used with `multipart/form-data` content type,
/// which is commonly used for file uploads and complex form submissions.
class Part extends Parameter {
  /// Creates a multipart form data part annotation.
  ///
  /// [value] The name of the multipart part.
  /// [keepNull] Whether to include this part in the request when its value is null.
  /// Defaults to false, meaning null values will be omitted from the request.
  const Part(this.value, {this.keepNull = false});

  /// The name of the multipart part.
  final String value;

  /// Whether to include this part in the request when its value is null.
  final bool keepNull;
}

/// An internal annotation class for multipart data in Map format.
///
/// This class is used to handle collections of multipart data that are
/// provided as a Map rather than individual parameters.
class _PartMap extends Parameter {
  /// Creates a part map annotation.
  const _PartMap();
}

/// A constant instance for annotating Map-based multipart data parameters.
///
/// Use this annotation when you want to pass multiple multipart fields
/// as a single Map parameter instead of individual annotated parameters.
const _PartMap partMap = _PartMap();

/// An annotation that marks a parameter as a path variable.
///
/// Path variables are used to replace placeholders in the URL path.
/// For example, if your endpoint is `/users/{id}`, you would use
/// `@Path('id')` to mark the parameter that provides the user ID.
class Path extends Parameter {
  /// Creates a path parameter annotation.
  ///
  /// [value] The name of the path variable placeholder (without braces).
  const Path(this.value);

  /// The name of the path variable placeholder.
  final String value;
}

/// An annotation that marks a parameter as an HTTP header.
///
/// The annotated parameter's value will be added to the request headers.
class Header extends Parameter {
  /// Creates a header parameter annotation.
  ///
  /// [value] The name of the HTTP header.
  const Header(this.value);

  /// The name of the HTTP header.
  final String value;
}

/// An internal class for marking form URL encoded requests.
///
/// This class is used internally to indicate that the request should use
/// `application/x-www-form-urlencoded` content type.
class _FormUrlEncoded {
  /// Creates a form URL encoded marker.
  const _FormUrlEncoded();
}

/// A constant annotation for marking requests as form URL encoded.
///
/// Use this annotation on service methods that should send data as
/// `application/x-www-form-urlencoded`. This is typically used with
/// simple form submissions.
const _FormUrlEncoded formUrlEncoded = _FormUrlEncoded();

/// An internal class for marking multipart requests.
///
/// This class is used internally to indicate that the request should use
/// `multipart/form-data` content type.
class _Multipart {
  /// Creates a multipart marker.
  const _Multipart();
}

/// A constant annotation for marking requests as multipart.
///
/// Use this annotation on service methods that should send data as
/// `multipart/form-data`. This is commonly used for file uploads
/// and complex form submissions.
const _Multipart multipart = _Multipart();

/// Base class for all HTTP method annotations.
///
/// This class provides common functionality for HTTP method annotations
/// such as GET, POST, PUT, and DELETE.
class Http {
  /// Creates an HTTP method annotation.
  ///
  /// [path] The endpoint path for this HTTP request. This can include
  /// path variable placeholders using curly braces (e.g., `/users/{id}`).
  /// [validateStatus] A list of HTTP status codes that should be considered
  /// successful for this request. If empty, the default validation logic applies.
  const Http(this.path, {this.validateStatus = const []});

  /// The endpoint path for this HTTP request.
  ///
  /// This path will be appended to the service's base URL to form the complete
  /// request URL. It can include path variable placeholders using curly braces.
  final String path;

  /// A list of HTTP status codes that should be considered successful.
  ///
  /// If this list is not empty, only the specified status codes will be
  /// considered successful responses. This overrides the service-level
  /// `validateStatus` function for this specific endpoint.
  ///
  /// If empty, the default validation logic or the service-level validation
  /// function will be used.
  final List<int> validateStatus;
}

/// An annotation for HTTP POST requests.
///
/// POST requests are typically used for creating new resources or
/// submitting data that causes side effects on the server.
class Post extends Http {
  /// Creates a POST request annotation.
  ///
  /// [path] The endpoint path for this POST request.
  /// [validateStatus] A list of HTTP status codes that should be considered
  /// successful for this request. Defaults to an empty list.
  const Post(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// An annotation for HTTP GET requests.
///
/// GET requests are used for retrieving data from the server without
/// causing any side effects. They should be idempotent and safe.
class Get extends Http {
  /// Creates a GET request annotation.
  ///
  /// [path] The endpoint path for this GET request.
  /// [validateStatus] A list of HTTP status codes that should be considered
  /// successful for this request. Defaults to an empty list.
  const Get(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// An annotation for HTTP PUT requests.
///
/// PUT requests are typically used for updating existing resources or
/// creating resources with a specific identifier.
class Put extends Http {
  /// Creates a PUT request annotation.
  ///
  /// [path] The endpoint path for this PUT request.
  /// [validateStatus] A list of HTTP status codes that should be considered
  /// successful for this request. Defaults to an empty list.
  const Put(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}

/// An annotation for HTTP DELETE requests.
///
/// DELETE requests are used for removing resources from the server.
class Delete extends Http {
  /// Creates a DELETE request annotation.
  ///
  /// [path] The endpoint path for this DELETE request.
  /// [validateStatus] A list of HTTP status codes that should be considered
  /// successful for this request. Defaults to an empty list.
  const Delete(String path, {List<int> validateStatus = const []})
      : super(path, validateStatus: validateStatus);
}
