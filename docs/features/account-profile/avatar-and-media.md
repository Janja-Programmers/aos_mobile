# Avatar and Media

## Display source and fallback

Profile avatar uses backend `user_image`, normalized through the existing media URL helper. Account header also recognizes established image aliases before falling back to the authenticated user image and finally initials/fallback UI.

## Interaction rules

- Active live room (`is_live` plus non-empty `live_id`): avatar tap navigates to Live.
- Own non-live profile: avatar tap opens gallery/camera choices.
- Public non-live profile: avatar tap does not expose edit controls.

## Upload flow

```text
Owner selects Camera or Gallery
→ MediaHelper platform picker
→ normalizeImageOrientation
→ mediaUploadApiProvider.uploadMedia(profileImage)
→ backend returns media_id
→ AccountsApi.updateProfile(profile_image_media)
→ AuthController user snapshot update
→ profile/account provider invalidation
→ refreshed avatar
```

The backend profile update does not accept an arbitrary remote URL as proof of ownership; a media ID is used for a new uploaded image. Empty `user_image` is the supported clearing signal.

## Permissions and native boundaries

Camera/gallery permission dialogs, image pickers, orientation correction, and device filesystem behavior are platform boundaries. Widget/unit tests mock or stop before these integrations; they never access a real camera, gallery, or media service.

## Failure handling

Upload and update failures show safe snack messages and leave prior profile state intact. A missing/blank returned media ID is treated as failure. Cache-busting behavior is delegated to the image/media stack; Profile invalidates its providers after success.
