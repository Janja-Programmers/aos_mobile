import 'dart:async';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/application/location_search_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/application/location_search_state.dart';
import 'package:africaonlinestores/features/ads/ads_form/domain/ad_location_page.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({
    super.key,
    this.selectedId,
    this.showAllLocations = true,
  });

  final String? selectedId;
  final bool showAllLocations;

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(locationSearchControllerProvider.notifier).loadInitial(),
      );
    });
  }

  void _onSearchChanged() {
    if (!mounted) return;
    ref
        .read(locationSearchControllerProvider.notifier)
        .updateQuery(_searchController.text);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    if (position.extentAfter > 240) return;

    unawaited(ref.read(locationSearchControllerProvider.notifier).loadMore());
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocationSearchState state = ref.watch(
      locationSearchControllerProvider,
    );
    final Color accent = context.appColors.primaryRedSoft;
    final String selectedId = (widget.selectedId ?? '').trim();
    final bool isAllSelected = selectedId.isEmpty;
    final bool showAllLocations =
        widget.showAllLocations && state.query.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.ads_location_select_title, style: context.h5),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchBar(controller: _searchController),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.hasMore
                    ? context.l10n.ads_location_results_more(state.items.length)
                    : context.l10n.ads_location_results_exact(
                        state.items.length,
                      ),
                style: context.p,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _LocationResults(
                state: state,
                controller: _scrollController,
                showAllLocations: showAllLocations,
                isAllSelected: isAllSelected,
                selectedId: selectedId,
                accent: accent,
                onRetry: () =>
                    ref.read(locationSearchControllerProvider.notifier).retry(),
                onLoadMoreRetry: () => ref
                    .read(locationSearchControllerProvider.notifier)
                    .loadMore(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationResults extends StatelessWidget {
  const _LocationResults({
    required this.state,
    required this.controller,
    required this.showAllLocations,
    required this.isAllSelected,
    required this.selectedId,
    required this.accent,
    required this.onRetry,
    required this.onLoadMoreRetry,
  });

  final LocationSearchState state;
  final ScrollController controller;
  final bool showAllLocations;
  final bool isAllSelected;
  final String selectedId;
  final Color accent;
  final Future<void> Function() onRetry;
  final Future<void> Function() onLoadMoreRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingInitial && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return _LocationError(message: state.error!.message, onRetry: onRetry);
    }

    if (state.items.isEmpty && !showAllLocations) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.common_no_results, style: context.pMuted),
        ),
      );
    }

    final int leadingCount = showAllLocations ? 1 : 0;
    final int footerCount = state.isLoadingMore || state.error != null ? 1 : 0;

    return ListView.builder(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      itemCount: leadingCount + state.items.length + footerCount,
      itemBuilder: (BuildContext context, int index) {
        if (showAllLocations && index == 0) {
          return _LocationTile(
            label: context.l10n.location_all_locations,
            selected: isAllSelected,
            accent: accent,
            onTap: () => Navigator.of(context).pop(<String, dynamic>{
              'id': '',
              'label': context.l10n.location_all_locations,
            }),
          );
        }

        final int itemIndex = index - leadingCount;
        if (itemIndex >= state.items.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Center(
              child: TextButton(
                onPressed: onLoadMoreRetry,
                child: Text(
                  context.l10n.common_try_again,
                  style: AppTextStylesX(context).button,
                ),
              ),
            ),
          );
        }

        final AdLocation location = state.items[itemIndex];
        return _LocationTile(
          label: location.name,
          selected: !isAllSelected && location.id == selectedId,
          accent: accent,
          onTap: () => Navigator.of(
            context,
          ).pop(<String, dynamic>{'id': location.id, 'label': location.name}),
        );
      },
    );
  }
}

class _LocationError extends StatelessWidget {
  const _LocationError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center, style: context.pMuted),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                context.l10n.common_try_again,
                style: AppTextStylesX(context).button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.location_on_outlined,
        color: selected ? accent : colors.textPrimary,
      ),
      title: Text(label, style: context.pStrong),
      trailing: selected
          ? Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(Icons.check, size: 16, color: colors.white),
            )
          : null,
    );
  }
}
