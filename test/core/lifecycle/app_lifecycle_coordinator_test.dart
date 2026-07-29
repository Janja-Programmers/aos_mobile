import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLifecycleController', () {
    test('normalizes the restored initial lifecycle state', () {
      final AppLifecycleController controller = AppLifecycleController(
        initialState: AppLifecycleState.paused,
      );

      expect(controller.state.phase, AppVisibilityPhase.background);
      expect(controller.state.isInitial, isTrue);
      expect(controller.state.shouldProtectContent, isTrue);
    });

    test('inactive remains visible and does not protect content', () {
      final AppLifecycleController controller = AppLifecycleController(
        initialState: AppLifecycleState.resumed,
      );

      controller.handlePlatformState(AppLifecycleState.inactive);

      expect(controller.state.phase, AppVisibilityPhase.inactive);
      expect(controller.state.isVisible, isTrue);
      expect(controller.state.shouldProtectContent, isFalse);
    });

    test('hidden and paused protect content', () {
      final AppLifecycleController controller = AppLifecycleController(
        initialState: AppLifecycleState.resumed,
      );

      controller.handlePlatformState(AppLifecycleState.hidden);
      expect(controller.state.phase, AppVisibilityPhase.hidden);
      expect(controller.state.shouldProtectContent, isTrue);

      controller.handlePlatformState(AppLifecycleState.paused);
      expect(controller.state.phase, AppVisibilityPhase.background);
      expect(controller.state.shouldProtectContent, isTrue);
    });

    test('equivalent repeated states are deterministically deduplicated', () {
      final AppLifecycleController controller = AppLifecycleController(
        initialState: AppLifecycleState.resumed,
      );

      controller.handlePlatformState(AppLifecycleState.hidden);
      final int sequence = controller.state.sequence;
      controller.handlePlatformState(AppLifecycleState.hidden);
      controller.handlePlatformState(AppLifecycleState.hidden);

      expect(controller.state.sequence, sequence);
    });

    test('rapid distinct transitions retain deterministic ordering', () {
      final AppLifecycleController controller = AppLifecycleController(
        initialState: AppLifecycleState.resumed,
      );

      controller.handlePlatformState(AppLifecycleState.inactive);
      controller.handlePlatformState(AppLifecycleState.hidden);
      controller.handlePlatformState(AppLifecycleState.paused);
      controller.handlePlatformState(AppLifecycleState.resumed);

      expect(controller.state.phase, AppVisibilityPhase.foreground);
      expect(controller.state.sequence, 4);
      expect(controller.state.isInitial, isFalse);
    });
  });

  testWidgets('root coordinator forwards platform lifecycle events', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appLifecycleInitialStateProvider.overrideWithValue(
          AppLifecycleState.resumed,
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RootLifecycleCoordinator(child: SizedBox.expand()),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();

    expect(
      container.read(appLifecycleControllerProvider).phase,
      AppVisibilityPhase.hidden,
    );
  });
}
