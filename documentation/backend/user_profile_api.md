# Introduction

This api handles all user profile services.

---

## Example Usage

```Dart
tbd
```

---

## Available Methods

### 1. getCurrentUserProfile

Get profile by supabase id (unique user ID).

#### Arguments

- String: userId

#### Returns

- UserProfile

### 2. insertCurrentUserProfile

Inserts the current user profile.

#### Arguments

- profile: UserProfile

#### Returns

- None

### 3. updateCurrentUserProfile

Updates the current user profile.

#### Arguments

- profile: UserProfile

#### Returns

- None

### 4. uploadAvatar

Upload avatar image to Supabase storage and stores filepath in profiles table

#### Arguments

- imageFile: File
- String: userId

#### Returns

- None

### 5. deleteAvatar

Delete avatar image from Supabase storage and removes filepath in profiles table

#### Arguments

- String: userId

#### Returns

- None

### 6. getAvatarUrl

Returns the current user's avatar URL from the profiles table (or null if none exists)

#### Arguments

- String: userId

#### Returns

- avatar_url: String
