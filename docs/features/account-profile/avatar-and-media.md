# Avatar and Media

## Display source and fallback

Profile avatar uses backend `avatar`/`user_image`, normalized through the existing media URL helper. Account header also recognizes established image aliases before falling back to the authenticated user image and finally initials/fallback UI.

## Interaction rules

- Own profile: avatar tap opens gallery/camera/remove choices even while the account is Live; the separate LIVE badge still communicates active Live state.
- Public profile with an active Live: avatar tap navigates to Live.
- Public non-live profile: avatar tap does not expose edit controls.

## Upload flow

```text
Owner selects Camera or Gallery
→ shared MediaAcquisitionService and app-owned staging
→ MediaPreparationService bounded native image preparation
→ MediaUploadCoordinator(profileImage)
→ backend returns media_id
→ AccountsApi.updateProfile(avatar_media_id)
→ AuthController user snapshot update
→ profile/account provider invalidation
→ seller storefront invalidation when this profile owns a seller
→ refreshed avatar
```

The backend profile update does not accept an arbitrary remote URL as proof of ownership; a media ID is used for a new uploaded image. `remove_avatar=true` is the canonical clearing request. The frontend uses the backend-owned profile response to refresh both auth and profile presentation after replacement/removal.

## Permissions and native boundaries

Camera/gallery permission dialogs and device filesystem behavior are platform boundaries. Profile uses the shared in-app camera and approved gallery adapter; it does not import picker plugins. Widget/unit tests mock or stop before these integrations; they never access a real camera, gallery, or media service.

## Failure handling

Upload and update failures show safe snack messages and leave prior profile state intact. A missing/blank returned media ID is treated as failure. If upload succeeds but the profile mutation fails, Flutter best-effort deletes the still-unattached media object to avoid leaving an orphan. Cache-busting behavior is delegated to the image/media stack; Profile invalidates profile/account state and any known seller storefront after success.
