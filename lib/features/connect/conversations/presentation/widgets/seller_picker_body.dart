import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/seller_tile.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_list_controller.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerPickerBody extends ConsumerStatefulWidget {
  const SellerPickerBody({
    super.key,
    required this.title,
    required this.onSellerTap,
    this.trailingBuilder,
  });

  final String title;
  final ValueChanged<SellerListItem> onSellerTap;
  final Widget Function(BuildContext context, SellerListItem seller)?
  trailingBuilder;

  @override
  ConsumerState<SellerPickerBody> createState() => _SellerPickerBodyState();
}

class _SellerPickerBodyState extends ConsumerState<SellerPickerBody> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(sellerListControllerProvider.notifier).loadInitial();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final threshold = position.maxScrollExtent - 300;

    if (position.pixels >= threshold) {
      ref.read(sellerListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerListControllerProvider);
    final controller = ref.read(sellerListControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchController,
            onChanged: controller.updateSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search sellers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        controller.updateSearch('');
                        setState(() {});
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: context.h5.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: Builder(
            builder: (context) {
              if (state.isLoadingInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null && state.items.isEmpty) {
                return _SellerListErrorView(
                  message: state.error!.message,
                  onRetry: controller.retry,
                );
              }

              if (state.isEmpty) {
                return _SellerListEmptyView(
                  hasSearch: state.search.isNotEmpty,
                  onRetry: controller.retry,
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final seller = state.items[index];

                  return SellerTile(
                    seller: seller,
                    onTap: () => widget.onSellerTap(seller),
                    trailing: widget.trailingBuilder?.call(context, seller),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _SellerListErrorView extends StatelessWidget {
  const _SellerListErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: context.body),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SellerListEmptyView extends StatelessWidget {
  const _SellerListEmptyView({required this.hasSearch, required this.onRetry});

  final bool hasSearch;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'No sellers matched your search.'
                  : 'No sellers found.',
              textAlign: TextAlign.center,
              style: context.body,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
