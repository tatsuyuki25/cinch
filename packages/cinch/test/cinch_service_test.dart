import 'dart:typed_data';

import 'package:cinch/cinch.dart';
import 'package:test/test.dart';

/// Records the last request instead of sending it over the network.
class _RecordingAdapter implements HttpClientAdapter {
  late RequestOptions last;
  int status = 200;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString('{}', status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _Payload {
  _Payload(this.name);

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}

class _TestService extends Service {
  _TestService(this.adapter) : super('http://localhost:8080/') {
    httpClientAdapter = adapter;
  }

  final _RecordingAdapter adapter;

  Future<Response<dynamic>> patchBody(String id, _Payload payload) =>
      request(<dynamic>[const Patch('users/{id}')],
          [(const Path('id'), id), (const Body(), payload)]);

  Future<Response<dynamic>> patchFields(String name, int age) =>
      request(<dynamic>[const Patch('users')],
          [(const Field('name'), name), (const Field('age'), age)]);

  Future<Response<dynamic>> patchQuery(String force) =>
      request(<dynamic>[const Patch('users')], [(const Query('force'), force)]);

  Future<Response<dynamic>> patchNotFoundOk() => request(
      <dynamic>[const Patch('users', validateStatus: [404])],
      const <(dynamic, dynamic)>[]);

  Future<Response<dynamic>> put(String id) =>
      request(<dynamic>[const Put('users/{id}')], [(const Path('id'), id)]);

  Future<Response<dynamic>> patchAndGet() =>
      request(<dynamic>[const Patch('users'), const Get('users')],
          const <(dynamic, dynamic)>[]);
}

/// Mirrors the constructor shape emitted by cinch_gen (super parameters).
class _SuperParamService extends Service {
  _SuperParamService({
    super.connectTimeout,
    super.receiveTimeout,
    super.sendTimeout,
    super.validateStatus,
  }) : super('http://localhost:8080/');
}

void main() {
  late _RecordingAdapter adapter;
  late _TestService service;

  setUp(() {
    adapter = _RecordingAdapter();
    service = _TestService(adapter);
  });

  group('Patch', () {
    test('sends PATCH to the path with substituted path parameters', () async {
      await service.patchBody('42', _Payload('Ann'));

      expect(adapter.last.method, 'PATCH');
      expect(adapter.last.path, 'users/42');
    });

    test('sends the @Body object as the request data', () async {
      await service.patchBody('42', _Payload('Ann'));

      expect(adapter.last.data, {'name': 'Ann'});
    });

    test('sends @Field arguments as the data map', () async {
      await service.patchFields('Ann', 30);

      expect(adapter.last.method, 'PATCH');
      expect(adapter.last.data, {'name': 'Ann', 'age': 30});
    });

    test('sends @Query arguments as query parameters', () async {
      await service.patchQuery('true');

      expect(adapter.last.method, 'PATCH');
      expect(adapter.last.queryParameters, {'force': 'true'});
    });

    test('validateStatus on the annotation accepts the listed status',
        () async {
      adapter.status = 404;

      final response = await service.patchNotFoundOk();

      expect(response.statusCode, 404);
    });

    test('combined with another HTTP method throws', () {
      expect(service.patchAndGet(), throwsA(isA<Exception>()));
    });
  });

  test('Put still sends PUT', () async {
    await service.put('7');

    expect(adapter.last.method, 'PUT');
    expect(adapter.last.path, 'users/7');
  });

  group('super parameters', () {
    test('forwarded values reach dio options', () {
      bool validate(int? status) => status == 418;
      final service = _SuperParamService(
        connectTimeout: const Duration(seconds: 1),
        receiveTimeout: const Duration(seconds: 2),
        sendTimeout: const Duration(seconds: 3),
        validateStatus: validate,
      );

      expect(service.dio.options.connectTimeout, const Duration(seconds: 1));
      expect(service.dio.options.receiveTimeout, const Duration(seconds: 2));
      expect(service.dio.options.sendTimeout, const Duration(seconds: 3));
      expect(service.dio.options.validateStatus, same(validate));
    });

    test('omitted values fall back to Service defaults', () {
      final service = _SuperParamService();

      expect(service.dio.options.connectTimeout, const Duration(seconds: 5));
      expect(service.dio.options.receiveTimeout, const Duration(seconds: 10));
      expect(service.dio.options.sendTimeout, const Duration(seconds: 10));
      expect(service.validateStatus, isNull);
    });
  });
}
