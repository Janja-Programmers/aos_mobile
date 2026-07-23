# Privacy and Visibility

## Context matrix

| Data/action | Current account / own profile | Public profile | Deleted/blocked profile |
| --- | --- | --- | --- |
| Full name, bio, avatar | Yes | Backend-public value | Redacted/backend-safe value |
| Email | Owner context only | Not rendered | Not rendered |
| Edit profile | Yes | No | No |
| Avatar edit | Own, non-live only | No | No |
| Message/follow | No self-action | When backend state permits | No |
| Private/Saved/Liked tabs | Yes | No | No content loading |
| Seller storefront | Owner has Account entry; visitor may see public seller integration | Valid public seller only | No |
| Live navigation | Valid `live_id` | Valid `live_id` | No |
| Verification documents | Never | Never | Never |

## Backend-enforced rules

- Authentication for account/profile/social operations
- owner-only email serialization
- blocked viewer `PROFILE_UNAVAILABLE`
- deleted-user redaction
- follow/block/self mutation rules
- profile validation and media ownership
- soft-delete/restore policy

## Frontend-enforced behavior

- owner/public control separation
- private-tab filtering
- non-interactive blocked/deleted view
- public email suppression
- action loading guards
- navigation eligibility
- sanitized error presentation

## Shared responsibility

Frontend conditional UI reduces accidental disclosure and invalid actions. It must never be described as authorization. Backend serializers and permission helpers remain authoritative.

## Sensitive boundaries

The UI and tests must not surface session IDs, verification document URLs, private seller metadata, raw internal account status, passwords, production emails/phones/locations, or backend stack traces. Public fixtures contain only fields allowed by the public serializer.
