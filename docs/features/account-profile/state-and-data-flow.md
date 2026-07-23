# State and Data Flow

## Account load

```text
AuthAuthenticated
→ accountsControllerProvider creates AccountsController
→ loadProfile()
→ AccountsApi.getProfile()
→ backend get_profile self serializer
→ AccountState.profile
→ AccountScreen header/banner/actions
```

A failure produces `AccountState.errorMessage`; it does not invalidate Authentication/Session.

## Public profile load

```text
Profile route user
→ _ProfileRequest family key
→ AccountsApi.getProfile(target_user)
→ AccountProfileSnapshot
→ ownership/interaction/privacy derivation
→ optional seller and Shorts integration reads
→ _ProfileViewData
→ _ProfileScaffold
```

Target mismatch, empty data, or backend failure throws into the provider error state. No interactive partial profile is emitted.

## Edit

```text
Prefilled sheet
→ validation and duplicate guard
→ update_profile
→ authenticated user snapshot update
→ close sheet
→ invalidate profile family + account provider
→ reload authoritative data
```

## Avatar

Media upload and profile update are separate operations. Profile state changes only after a valid media ID is accepted by `update_profile`.

## Follow

```text
Follow button guard
→ toggle_follow(target_user)
→ backend returns relationship/count snapshot
→ invalidate profile/account providers
→ reload profile serializer
```

On failure, the current view remains unchanged.

## Logout

`accountsControllerProvider` watches the auth state. When Authentication/Session emits guest, a new empty controller replaces the authenticated one. Profile itself renders a guest message rather than retaining an authenticated profile surface.

## Family isolation

`_ProfileRequest` equality/hash include target identity and current-user/fallback inputs. Riverpod therefore isolates User A and User B requests and invalidation targets the exact family key.
