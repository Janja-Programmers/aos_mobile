import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';

enum AdActionType { primary, secondary, destructive, disabled }

class AdAction {
  final String label;
  final VoidCallback? onPressed;
  final AdActionType type;

  const AdAction({
    required this.label,
    required this.onPressed,
    required this.type,
  });
}

/// -------------------------------------
/// SINGLE SOURCE OF TRUTH
/// -------------------------------------
class AdListingActions {
  static List<AdAction> forTab({
    required AdTab tab,
    required AOSAdListItem ad,
    required void Function(AOSAdListItem ad) onEdit,
    required void Function(AOSAdListItem ad) onMarkSold,
    required VoidCallback onDelete,
    required void Function(AOSAdListItem ad) onContactSupport,
  }) {
    switch (tab) {
      case AdTab.active:
        return [
          AdAction(
            label: 'Mark as sold',
            onPressed: () => onMarkSold(ad),
            type: AdActionType.primary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.reviewing:
        return [
          const AdAction(
            label: 'Processing',
            onPressed: null,
            type: AdActionType.disabled,
          ),
          AdAction(
            label: 'Edit',
            onPressed: () => onEdit(ad),
            type: AdActionType.secondary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.drafts:
        return [
          AdAction(
            label: 'Continue editing',
            onPressed: () => onEdit(ad),
            type: AdActionType.primary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.declined:
        return [
          AdAction(
            label: 'Fix Ad',
            onPressed: () => onEdit(ad),
            type: AdActionType.primary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.sold:
        return [
          AdAction(
            label: 'View',
            onPressed: () => onEdit(ad),
            type: AdActionType.primary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.expired:
        return [
          AdAction(
            label: 'Relist',
            onPressed: () => onEdit(ad),
            type: AdActionType.primary,
          ),
          AdAction(
            label: 'Delete',
            onPressed: onDelete,
            type: AdActionType.destructive,
          ),
        ];

      case AdTab.suspended:
        return [
          AdAction(
            label: 'Contact Support',
            onPressed: () => onContactSupport(ad),
            type: AdActionType.primary,
          ),
        ];
    }
  }
}
