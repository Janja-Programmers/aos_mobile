import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_update_contract.dart';

String adFailureMessage(Failure failure, {String? adStatus}) {
  final code = (failure.error ?? '').trim().toUpperCase();

  switch (code) {
    case 'INVALID_AD_STATE':
      final status = adStatus?.trim() ?? '';
      return status.isEmpty
          ? 'This action is no longer available for the listing\'s current state. Refresh and try again.'
          : AdUpdateContract.editBlockedMessage(status);
    case 'AD_SELLER_INACTIVE':
      return 'Your seller account is not active, so this listing cannot be changed.';
    case 'SELLER_REQUIRED':
      return 'A seller profile is required before you can create or edit listings.';
    case 'AD_PRICE_REQUIRED':
      return 'Enter a valid price for the selected price type.';
    case 'INVALID_CATEGORY_SCHEMA':
      return 'One or more values are no longer allowed for this category. Review the category details and pricing.';
    case 'CATEGORY_NOT_SELLABLE':
      return 'Choose a sellable final category before continuing.';
    case 'CATEGORY_NOT_FOUND':
      return 'The selected category is no longer available. Choose another category.';
    case 'AD_MEDIA_REQUIRED':
      return 'Add at least one image before submitting the listing.';
    case 'AD_PRIMARY_IMAGE_REQUIRED':
      return 'Choose exactly one primary listing image.';
    case 'DUPLICATE_AD_MEDIA':
      return 'The same media file cannot be added more than once.';
    case 'DUPLICATE_AD_ATTRIBUTE':
      return 'A category detail was supplied more than once. Review the listing details.';
    case 'INVALID_LOCATION':
      return 'Choose a location that belongs to your current marketplace.';
    case 'MARKET_LOCKED':
      return 'This listing belongs to a different marketplace and cannot be moved to the current one.';
    case 'CONFIG_ERROR':
      return 'Your marketplace preferences are incomplete. Update your account country and currency before posting.';
    case 'AD_NOT_FOUND':
    case 'AD_ACCESS_DENIED':
      return 'This listing is no longer available.';
    case 'INVALID_AD_INPUT':
      return 'Some listing information does not match the rules for this category or listing state. Review the fields and try again.';
    case 'VALIDATION_ERROR':
      return failure.message.trim().isEmpty
          ? 'Review the listing information and try again.'
          : failure.message.trim();
    default:
      return failure.message.trim().isEmpty
          ? 'The listing request could not be completed.'
          : failure.message.trim();
  }
}
