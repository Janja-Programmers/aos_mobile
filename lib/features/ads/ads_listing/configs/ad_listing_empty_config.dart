class AdListingEmptyConfig {
  static String title(String tab) {
    switch (tab) {
      case 'Drafts':
        return 'No Drafts Yet';
      case 'Reviewing':
        return 'Nothing Under Review';
      case 'Declined':
        return 'No Declined Ads';
      case 'Active':
      default:
        return 'No Listings Yet';
    }
  }

  static String description(String tab) {
    switch (tab) {
      case 'Drafts':
        return 'You have no saved drafts.';
      case 'Reviewing':
        return 'You have no ads currently under review.';
      case 'Declined':
        return 'You have no declined ads.';
      case 'Active':
      default:
        return "You haven't posted any ads yet.";
    }
  }

  static String primaryLabel(String tab) {
    switch (tab) {
      case 'Drafts':
      case 'Reviewing':
      case 'Declined':
        return 'Create An Ad';
      case 'Active':
      default:
        return 'Post Your First Ad';
    }
  }
}
