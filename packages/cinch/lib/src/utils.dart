/// A mixin that provides dynamic URL configuration capability.
///
/// Classes that implement this mixin can dynamically specify API base URLs
/// at runtime, allowing for flexible endpoint configuration.
mixin ApiUrlMixin {
  /// Gets the API base URL for HTTP requests.
  ///
  /// This property should be overridden by implementing classes to provide
  /// the appropriate base URL for their API endpoints.
  String get url;
}
