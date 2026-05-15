# Communitii

The go-to platform to start your home-based business.

Have you ever wanted to try selling good food from your home but not know how to begin doing so?

No prior business knowledge required. You should do what you do best -- making good food :D

## Active Prototype

The active app entrypoint boots into `lib/v2`, a frontend-only Flutter product
MVP for storefront discovery and social commerce. It uses mock users, mock
storefronts, mock products, subscriptions, discussion threads, notifications,
and local persistence to demonstrate the casual-user and storefront-owner
flows.

Casual users can log in with simulated email/password or Google, discover and
search storefronts, filter by category/nearby/popular, subscribe to stores,
browse live and upcoming products, view discussions, and manage activity
notifications.

Storefront owners can switch into owner mode, edit their storefront profile,
view storefront stats, preview the storefront as a casual user, create/edit/delete
live and upcoming products, and reply to community discussion threads.

The v2 prototype intentionally does not implement real backend, database, auth,
API, storage, payments, delivery, maps, uploads, or real account deletion. Useful
prototype state is stored locally through `shared_preferences`.

See [Communitii V2 Product MVP](./lib/v2/README.md) for the current product slice,
navigation, state model, and development commands.

## Other Documentation

- [Developer Guide](./documentation/developer_guide.md)
- [User Guide](./documentation/user_guide.md)
