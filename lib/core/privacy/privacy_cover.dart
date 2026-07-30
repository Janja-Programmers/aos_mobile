import 'package:africaonlinestores/core/lifecycle/app_lifecycle_coordinator.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyCoverState {
  const PrivacyCoverState({required this.isVisible});

  final bool isVisible;
}

class PrivacyCoverCoordinator {
  const PrivacyCoverCoordinator();

  PrivacyCoverState resolve({
    required AuthState authState,
    required AppLifecycleSnapshot lifecycle,
  }) {
    return PrivacyCoverState(
      isVisible:
          authState is AuthAuthenticated && lifecycle.shouldProtectContent,
    );
  }
}

final privacyCoverCoordinatorProvider = Provider<PrivacyCoverCoordinator>((
  ref,
) {
  return const PrivacyCoverCoordinator();
});

final privacyCoverStateProvider = Provider<PrivacyCoverState>((ref) {
  final PrivacyCoverCoordinator coordinator = ref.watch(
    privacyCoverCoordinatorProvider,
  );
  return coordinator.resolve(
    authState: ref.watch(authControllerProvider),
    lifecycle: ref.watch(appLifecycleControllerProvider),
  );
});

class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final Color backgroundColor = Theme.of(
      context,
    ).colorScheme.surface.withAlpha(255);

    return Positioned.fill(
      child: BlockSemantics(
        child: Semantics(
          container: true,
          label: localizations.privacy_cover_accessibility_label,
          child: ColoredBox(
            color: backgroundColor,
            child: SafeArea(
              child: Center(
                child: ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/logo_redone.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.storefront, size: 72);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
