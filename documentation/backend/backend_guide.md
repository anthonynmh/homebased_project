# Internal API Documentation

**Purpose:** Describes how to use the `user_profile_api` and `business_profile_api` to interact with the Supabase backend.

---

# User Profile

### `lib/user_profile_api/user_profile_service.dart`

### Purpose

Handles all backend logic related to the **user profile**, including:

- Fetching user profile info
- Uploading profile pictures
- Creating or updating the user profile

---

### `UserProfileService.getProfile()`

```dart
Future<UserProfile?> getProfile()
```

Fetches the currently logged-in user's profile.

#### Returns:

A `UserProfile` object:

```dart
UserProfile {
  String id;
  String username;
  String? avatarUrl;
}
```

---

### `UserProfileService.upsertProfile(UserProfile profile)`

```dart
Future<void> upsertProfile(UserProfile profile)
```

Creates or updates a user profile in the backend.

#### Arguments:

A `UserProfile` object. Example:

```dart
UserProfile(
  id: Supabase.instance.client.auth.currentUser!.id,
  username: 'John Doe',
  avatarUrl: 'https://your-project.supabase.co/storage/v1/object/public/avatars/some_image.jpg',
)
```

---

### `UserProfileService.uploadAvatar(File imageFile)`

```dart
Future<String?> uploadAvatar(File imageFile)
```

Uploads an image file to Supabase Storage (bucket: `avatars`) and returns the **public URL**.

#### Arguments:

- A `File` object representing the selected image.

#### Returns:

- A `String` URL pointing to the uploaded avatar image.
- `null` if upload fails.

---

### Example usage in frontend:

```dart
final imageUrl = await UserProfileService.uploadAvatar(imageFile);

final profile = UserProfile(
  id: Supabase.instance.client.auth.currentUser!.id,
  username: 'Jane Doe',
  avatarUrl: imageUrl,
);

await UserProfileService.upsertProfile(profile);
```

---

## `lib/business_profile_api/business_profile_service.dart`

### Purpose

Handles backend logic related to **business profile** data, including:

- Fetching business profiles
- Uploading business logos
- Creating or updating the business profile

---

### `BusinessProfileService.getProfile()`

```dart
Future<BusinessProfile?> getProfile()
```

Fetches the business profile associated with the current user.

#### Returns:

A `BusinessProfile` object:

```dart
BusinessProfile {
  String id;
  String businessName;
  String? logoUrl;
}
```

---

### `BusinessProfileService.upsertProfile(BusinessProfile profile)`

```dart
Future<void> upsertProfile(BusinessProfile profile)
```

Creates or updates the business profile in the backend.

#### Arguments:

A `BusinessProfile` object. Example:

```dart
BusinessProfile(
  id: Supabase.instance.client.auth.currentUser!.id,
  businessName: 'HomeFix Pte Ltd',
  logoUrl: 'https://your-project.supabase.co/storage/v1/object/public/logos/some_logo.jpg',
)
```

---

### `BusinessProfileService.uploadLogo(File imageFile)`

```dart
Future<String?> uploadLogo(File imageFile)
```

Uploads a business logo image to Supabase Storage (bucket: `logos`) and returns the **public URL**.

#### Arguments:

- A `File` object representing the image.

#### Returns:

- A `String` URL pointing to the uploaded logo.
- `null` if upload fails.

---

### Example usage in frontend:

```dart
final logoUrl = await BusinessProfileService.uploadLogo(imageFile);

final business = BusinessProfile(
  id: Supabase.instance.client.auth.currentUser!.id,
  businessName: 'HomeRepair Co.',
  logoUrl: logoUrl,
);

await BusinessProfileService.upsertProfile(business);
```

---

## Data Model Reference

### `UserProfile`

```dart
class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
}
```

### `BusinessProfile`

```dart
class BusinessProfile {
  final String id;
  final String businessName;
  final String? logoUrl;
}
```

---

## Notes

- `id` should always be the current authenticated user's ID from Supabase.
- Upload functions return public URLs you can use directly in `Image.network()`.
- These functions abstract all backend logic — no need to write any SQL or REST queries in the frontend.
