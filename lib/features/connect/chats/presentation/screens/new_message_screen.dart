import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/utils/chat_actions.dart';
import 'package:africaonlinestores/features/connect/presentation/widgets/seller_picker_body.dart';

class NewMessageScreen extends ConsumerWidget {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Message', style: context.h5),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SellerPickerBody(
          title: 'Verified Sellers',
          onSellerTap: (seller) {
            AppNavigation.requireAuth(
              context,
              ref,
              onAuthenticated: () {
                ChatActions.startChat(
                  context: context,
                  ref: ref,
                  user: seller.user,
                  displayName: seller.shopName,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
