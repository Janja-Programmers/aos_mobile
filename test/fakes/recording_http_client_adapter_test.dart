import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recording_http_client_adapter.dart';

void main() {
  test(
    'records request details and returns the scripted JSON response',
    () async {
      final RecordingHttpClientAdapter adapter = RecordingHttpClientAdapter((
        RequestOptions options,
      ) {
        return jsonResponse(<String, Object?>{
          'message': <String, Object?>{'ok': true},
        });
      });
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
        ..httpClientAdapter = adapter;

      final Response<Map<String, dynamic>> response = await dio
          .post<Map<String, dynamic>>(
            '/resource',
            data: <String, Object?>{'value': 1},
            queryParameters: <String, Object?>{'page': 2},
          );

      expect(response.data?['message'], <String, Object?>{'ok': true});
      expect(adapter.singleRequest.method, 'POST');
      expect(adapter.singleRequest.path, '/resource');
      expect(adapter.singleRequest.queryParameters['page'], 2);
      expect(adapter.singleRequest.data, <String, Object?>{'value': 1});
    },
  );
}
