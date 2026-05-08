import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';

import 'package:africaonlinestores/features/connect/presentation/widgets/seller_picker_body.dart';
import 'package:africaonlinestores/features/sellers/domain/seller_list_item.dart';

class NewCallScreen extends ConsumerStatefulWidget {
  const NewCallScreen({super.key});

  @override
  ConsumerState<NewCallScreen> createState() => _NewCallScreenState();
}

class _NewCallScreenState extends ConsumerState<NewCallScreen> {
  bool _isCalling = false;

  Future<void> _startCall({
    required BuildContext context,
    required SellerListItem seller,
  }) async {
    if (_isCalling) return;

    _isCalling = true;

    try {
      await AppNavigation.requireAuth(
        context,
        ref,
        onAuthenticated: () async {
          final manager = ref.read(callManagerProvider.notifier);

          if (seller.user.trim().isEmpty) {
            debugPrint('❌ seller.user is empty');
            return;
          }

          await manager.startOutgoingCall(
            userId: seller.user,
            callType: AOSCallType.audio,
            receiver: _buildReceiver(seller),
          );
        },
      );
    } finally {
      _isCalling = false;
    }
  }

  CallParticipant _buildReceiver(SellerListItem? seller) {
    final sellerName = seller?.shopName.trim();

    return CallParticipant(
      userId: seller!.user,
      displayName: sellerName != null && sellerName.isNotEmpty
          ? sellerName
          : seller.seller,
      avatarUrl: seller.avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Call', style: context.h5),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SellerPickerBody(
          title: 'Verified Sellers',
          onSellerTap: (seller) {
            _startCall(context: context, seller: seller);
          },
          trailingBuilder: (context, seller) {
            return IconButton(
              tooltip: 'Start audio call',
              icon: Icon(Icons.call, color: colors.success),
              onPressed: () {
                _startCall(context: context, seller: seller);
              },
            );
          },
        ),
      ),
    );
  }
}
