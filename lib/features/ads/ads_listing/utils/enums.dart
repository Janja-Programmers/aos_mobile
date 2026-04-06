enum AdBackendStatus {
  active,
  draft,
  reviewing,
  declined,
  sold,
  expired,
  suspended,
}

enum AdTab { drafts, reviewing, active, declined, sold, expired, suspended }

extension AdTabX on AdTab {
  String get label {
    switch (this) {
      case AdTab.drafts:
        return 'Drafts';
      case AdTab.reviewing:
        return 'Reviewing';
      case AdTab.active:
        return 'Active';
      case AdTab.declined:
        return 'Declined';
      case AdTab.sold:
        return 'Sold';
      case AdTab.expired:
        return 'Expired';
      case AdTab.suspended:
        return 'Suspended';
    }
  }

  /// ONLY mapping needed
  AdBackendStatus? get backendStatus {
    switch (this) {
      case AdTab.drafts:
        return null; // handled separately
      case AdTab.reviewing:
        return AdBackendStatus.reviewing;
      case AdTab.active:
        return AdBackendStatus.active;
      case AdTab.declined:
        return AdBackendStatus.declined;
      case AdTab.sold:
        return AdBackendStatus.sold;
      case AdTab.expired:
        return AdBackendStatus.expired;
      case AdTab.suspended:
        return AdBackendStatus.suspended;
    }
  }
}

extension AdBackendStatusX on AdBackendStatus {
  String get value {
    switch (this) {
      case AdBackendStatus.active:
        return 'Active';
      case AdBackendStatus.draft:
        return 'Draft';
      case AdBackendStatus.reviewing:
        return 'Reviewing';
      case AdBackendStatus.declined:
        return 'Declined';
      case AdBackendStatus.sold:
        return 'Sold';
      case AdBackendStatus.expired:
        return 'Expired';
      case AdBackendStatus.suspended:
        return 'Suspended';
    }
  }
}
