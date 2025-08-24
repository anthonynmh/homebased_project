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
