# Navigation

## Routes

| Destination | Route name | Path source | Arguments |
| --- | --- | --- | --- |
| Account | `AppRoutes.nAccount` | `AccountRoutes` | none |
| Profile | `AppRoutes.nProfile` | `SocialRoutes` | query `user`, optional `display_name`, `avatar` |
| Social connections | `AppRoutes.nSocialConnections` | `SocialRoutes` | `tab`, `title`, optional `user` retained by UI |
| User verification | `AppRoutes.nUserVerification` | `AccountRoutes` | `VerificationType` in `extra` |
| Delete account | `AppRoutes.nDeleteAccount` | `AccountRoutes` | none |
| Restore account | `AppRoutes.nRestoreAccount` | `AccountRoutes` | none |

Authentication protection is configured centrally by the app router and documented in Authentication/Session.

## Helpers and integrations

- Profile: `SocialNavigation.toProfileScreen`
- Connections/search/blocked users: `SocialNavigation`
- Activity: `ActivityNavigation.toActivityCenter`
- Message: `ChatActions.startChat`
- Seller: `SellerNavigation.toSellerStore` / own storefront helper
- Live: `LiveNavigation.toLiveRoom(liveId: ...)`
- Ads/listings/wishlist: `AdNavigation`

Screens should continue using these helpers rather than creating parallel GoRouter calls for feature destinations.

## Return refresh

Edit Profile is a modal sheet; completion invalidates profile/account state. Verification flow returns `bool?` and Account refreshes status. Avatar/follow operations invalidate immediately after success.

## Current backend limitation

Although the social connections route can carry a user, the current backend connection-list endpoints do not accept a target user. Profile therefore enables connection-list taps only for the owner. This prevents a public stat from opening the viewer's list under another person's title.

## Loop and identity safety

Profile target is a normalized stable user identifier. Empty navigation targets are ignored by `SocialNavigation.toProfileScreen`, and a backend response for a different target is rejected.
