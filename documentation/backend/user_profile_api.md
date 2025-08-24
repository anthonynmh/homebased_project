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

- None

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

Upload avatar image to Supabase storage and stores public URL in table

#### Arguments

- imageFile: File

#### Returns

- None

### 5. getAvatarUrl

Returns the current user's avatar URL from the profiles table (or null if none exists)

#### Arguments

- None

#### Returns

- avatar_url: String
