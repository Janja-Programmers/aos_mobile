# Seller Storefront Media

## Backend boundary

Seller banner changes use the existing shared Media pipeline. Flutter uploads one image with purpose `seller_banner`, receives a canonical `MEDIA-*` ID, then calls `aos.api.v1.sellers.update_my_seller` with `shop_banner_media`. Removal uses `clear_shop_banner=true`. Flutter never sends a raw local path or arbitrary remote URL as storefront ownership proof.

The backend attaches the new `AOS Media Object` to `AOS Seller.shop_banner_media`, updates the cached public `shop_banner` URL, releases the replaced media, and returns the refreshed storefront fields. The public storefront continues to use the canonical `SELLER-*` identifier.

## Frontend flow

`MyStorefrontScreen` exposes the banner edit control only for the owner route. Existing banners offer Change and Remove actions. Change uses the shared camera/gallery acquisition, preparation, and upload coordinator with `MediaUseCase.sellerBanner`; the seller controller then refreshes canonical storefront state. Remove issues only the backend clear flag.

`StoreCustomizationScreen` uses the same shared banner acquisition/upload path. The frontend does not send the unsupported legacy `business_address` mutation field; seller location remains owned by the dedicated Seller Location flow.

## Failure and cleanup

Uploads retain the current visible banner until the backend mutation succeeds. Temporary acquired files are discarded once by the screen after upload completion. If upload succeeds but the storefront mutation fails, Flutter best-effort deletes the still-unattached uploaded media object. Backend mutation failures leave the previous storefront intact and surface the normalized failure message.

## Tests

Focused Seller API tests assert `shop_banner_media` for replacement, `clear_shop_banner` for removal, and absence of `business_address` in update requests. Physical-device checks must still cover camera/gallery permissions, large images, replacement, removal, retry, and slow-network behavior.
