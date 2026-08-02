import 'package:africaonlinestores/core/api/api_response.dart';
import 'package:africaonlinestores/core/api/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unwrapFrappe', () {
    test('unwraps a successful nested Frappe payload', () {
      final response = Response<Object?>(
        requestOptions: RequestOptions(path: '/shorts'),
        statusCode: 200,
        data: <String, dynamic>{
          'message': <String, dynamic>{
            'ok': true,
            'data': <String, dynamic>{'id': 'SHORT-2026-00001'},
          },
        },
      );

      final result = unwrapFrappe(response);

      expect(result.isRight, isTrue);
      expect(result.rightOrNull?['ok'], isTrue);
    });

    test('preserves a stable error from an HTTP-successful envelope', () {
      final response = Response<Object?>(
        requestOptions: RequestOptions(path: '/shorts'),
        statusCode: 200,
        data: <String, dynamic>{
          'message': <String, dynamic>{
            'ok': false,
            'error': 'SHORT_NOT_READY',
            'message': 'The short is still processing.',
          },
        },
      );

      final result = unwrapFrappe(response);

      expect(result.isLeft, isTrue);
      expect(result.leftOrNull?.error, 'SHORT_NOT_READY');
      expect(result.leftOrNull?.type, FailureType.unknown);
    });
  });
}
