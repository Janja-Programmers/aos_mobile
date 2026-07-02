import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:flutter/material.dart';

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
    required void Function(AOSAdListItem ad) onMarkAvailable,
    required void Function(AOSAdListItem ad) onRenew,
    required VoidCallback onDelete,
    required void Function(AOSAdListItem ad) onContactSupport,
  }) {
    switch (tab) {
      case AdTab.active:
        return [
          AdAction(
            label: 'Edit',
            onPressed: () => onEdit(ad),
            type: AdActionType.secondary,
          ),
          AdAction(
            label: 'Mark as sold',
            onPressed: () => onMarkSold(ad),
            type: AdActionType.primary,
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
            label: 'Fix Issue',
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
            label: 'Mark Available',
            onPressed: () => onMarkAvailable(ad),
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
            label: 'Renew',
            onPressed: () => onRenew(ad),
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
