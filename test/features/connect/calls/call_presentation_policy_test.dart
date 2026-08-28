import 'package:africaonlinestores/features/connect/calls/application/services/call_presentation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visible Android app uses Flutter incoming-call surface', () {
    expect(
      incomingCallSurfaceFor(isAndroid: true, isAppVisible: true),
      IncomingCallSurface.flutter,
    );
  });

  test('background Android app uses native incoming-call surface', () {
    expect(
      incomingCallSurfaceFor(isAndroid: true, isAppVisible: false),
      IncomingCallSurface.native,
    );
  });

  test('iOS keeps native CallKit as incoming-call surface', () {
    expect(
      incomingCallSurfaceFor(isAndroid: false, isAppVisible: true),
      IncomingCallSurface.native,
    );
    expect(
      incomingCallSurfaceFor(isAndroid: false, isAppVisible: false),
      IncomingCallSurface.native,
    );
  });
}
