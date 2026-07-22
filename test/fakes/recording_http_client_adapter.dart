import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef DioResponseHandler =
    FutureOr<ResponseBody> Function(RequestOptions options);

class RecordingHttpClientAdapter implements HttpClientAdapter {
  RecordingHttpClientAdapter(this._handler);

  final DioResponseHandler _handler;
  final List<RequestOptions> requests = <RequestOptions>[];
  bool isClosed = false;

  RequestOptions get singleRequest {
    if (requests.length != 1) {
      throw StateError('Expected one request, found ${requests.length}.');
    }
    return requests.single;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (isClosed) {
      throw StateError('The recording HTTP adapter is closed.');
    }
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {
    isClosed = true;
  }
}

ResponseBody jsonResponse(
  Object? body, {
  int statusCode = 200,
  Map<String, List<String>>? headers,
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers:
        headers ??
        const <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
  );
}
