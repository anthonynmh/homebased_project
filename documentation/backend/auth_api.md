# Introduction

This api handles all authentication services.

---

## Example Usage

```Dart
import 'package:homebased_project/backend/auth_api/auth_service.dart';

await AuthService.signInWithEmailPassword(
  email: "test@gmail.com",
  password: "password",
);
```

---

## Default Supabase Instance

This service will call the global Supabse instance in `/supabase_service_api/supabase_service.dart`.

To override this instance (e.g., for testing), you may call the `setClient()` method.

### Example

```Dart
setUp(() {
  final mockSupabaseInstance = SupabaseClient('testUrl', 'testKey');
  AuthService.setClient(mockSupabaseInstance);
});

tearDown(() {
  AuthService.resetClient(); // reset to global, if necessary
});
```

## Available Methods

### 1. signInWithEmailPassword

This method authenticates (logs in) a user using email and password.

#### Arguments

- email: String
- password: String

#### Returns

- None

### 2. signUpWithEmailPassword

This method creates (signs up) a new user profile using email and password.

#### Arguments

- email: String
- password: String

#### Returns

- None

### 2. signOut

This method logs out a user.

#### Arguments

- None

#### Returns

- None

### 2. signInWithGoogle

This method logs in a user via Google.

#### Arguments

- None

#### Returns

- success: Boolean
