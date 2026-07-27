import 'package:africaonlinestores/core/theme/app_theme.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long picker value remains overflow-safe at text scale 2', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PickerField(
                value:
                    'A deliberately very long translated country or currency '
                    'name that must remain readable without RenderFlex overflow',
                leading: Icon(Icons.public),
                trailing: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
