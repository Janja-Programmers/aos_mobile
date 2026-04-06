import 'package:africaonlinestores/features/ads/ads_listing/utils/enums.dart';

class AdListingEmptyConfig {
  static String title(AdTab tab) {
    switch (tab) {
      case AdTab.drafts:
        return 'No Drafts Yet';

      case AdTab.reviewing:
        return 'Nothing Under Review';

      case AdTab.active:
        return 'No Listings Yet';

      case AdTab.declined:
        return 'No Declined Ads';

      case AdTab.sold:
        return 'No Sold Ads';

      case AdTab.expired:
        return 'No Expired Ads';

      case AdTab.suspended:
        return 'No Suspended Ads';
    }
  }

  static String description(AdTab tab) {
    switch (tab) {
      case AdTab.drafts:
        return 'You have no saved drafts. Start creating one anytime.';

      case AdTab.reviewing:
        return 'Your ads being reviewed will appear here.';

      case AdTab.active:
        return "You haven't posted any ads yet.";

      case AdTab.declined:
        return 'Ads that need fixes will appear here.';

      case AdTab.sold:
        return 'Ads you have sold will appear here.';

      case AdTab.expired:
        return 'Expired ads will appear here. You can relist them anytime.';

      case AdTab.suspended:
        return 'Suspended ads will appear here. Contact support for help.';
    }
  }

  static String primaryLabel(AdTab tab) {
    switch (tab) {
      case AdTab.drafts:
        return 'Continue Editing';

      case AdTab.reviewing:
        return 'Create New Ad';

      case AdTab.active:
        return 'Post Your First Ad';

      case AdTab.declined:
        return 'Fix Your Ad';

      case AdTab.sold:
        return 'Create New Ad';

      case AdTab.expired:
        return 'Relist Ad';

      case AdTab.suspended:
        return 'Contact Support';
    }
  }
}
