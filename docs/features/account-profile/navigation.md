# Navigation

## Routes

| Destination        | Route name                     | Path source     | Arguments                                       |
| ------------------ | ------------------------------ | --------------- | ----------------------------------------------- |
| Account            | `AppRoutes.nAccount`           | `AccountRoutes` | none                                            |
| Profile            | `AppRoutes.nProfile`           | `SocialRoutes`  | query `user`, optional `display_name`, `avatar` |
| Social connections | `AppRoutes.nSocialConnections` | `SocialRoutes`  | `tab`, `title`, optional `user` retained by UI  |
| User verification  | `AppRoutes.nUserVerification`  | `AccountRoutes` | `VerificationType` in `extra`                   |
| Delete account     | `AppRoutes.nDeleteAccount`     | `AccountRoutes` | none                                            |
| Restore account    | `AppRoutes.nRestoreAccount`    | `AccountRoutes` | none                                            |

Authentication protection is configured centrally by the app router and documented in Authentication/Session.

## Helpers and integrations

- Profile: `SocialNavigation.toProfileScreen`
- Connections/search/blocked users: `SocialNavigation`
- Activity: `ActivityNavigation.toActivityCenter`
- Message: `ChatActions.startChat`
- Seller: `SellerNavigation.toSellerStore` / own storefront helper using only the canonical `SELLER-*` ID
- Live: `LiveNavigation.toLiveRoom(liveId: ...)`
- Ads/listings/wishlist: `AdNavigation`

Screens should continue using these helpers rather than creating parallel GoRouter calls for feature destinations.

## Return refresh

Edit Profile is a modal sheet; completion invalidates profile/account state. Verification flow returns `bool?` and Account refreshes status. Avatar/follow operations invalidate immediately after success.

## Current backend limitation

Although the social connections route can carry a user, the current backend connection-list endpoints do not accept a target user. Profile therefore enables connection-list taps only for the owner. This prevents a public stat from opening the viewer's list under another person's title.

## Loop and identity safety

Profile navigation uses the public `ACC-*` account identity. The backend may still accept a legacy email reference on input, but its successful response canonicalizes the identity to `account_id`; the frontend accepts that canonicalization and keeps the display name separate.

Own-storefront navigation uses only `seller_id` from `get_my_seller_status` or the authenticated seller summary. Email and `account_id` are rejected as storefront route values. Empty targets remain ignored by the navigation helpers.

The backend currently provides no public username/handle field. Profile and connection UI therefore show `display_name` and do not manufacture a username from email or an opaque account ID.
