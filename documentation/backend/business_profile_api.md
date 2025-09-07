# Introduction

This API handles all business profile services, including retrieval, update, and storage of business logos and photos.

## Available Methods

### 1. getCurrentBusinessProfile

Get the current user's business profile by Supabase user ID.

#### Arguments

None

#### Returns

BusinessProfile? (nullable)

### 2. getAllBusinessProfiles

Fetch all business profiles (useful for listings, marketplace, etc.).

#### Arguments

None

#### Returns

List<BusinessProfile>

### 3. updateCurrentBusinessProfile

Updates the current user's business profile. Only non-null fields are updated.

#### Arguments

profile: BusinessProfile

#### Returns

None

### 4. uploadBusinessLogo

Upload a business logo image to Supabase storage under:
<user_id>/logo/logo.<ext>

Stores only the file path in the database (logo_url).

#### Arguments

imageFile: File

#### Returns

None

### 5. getCurrentBusinessLogoUrl

Returns a signed URL (valid 60 seconds) for the current user's business logo.

#### Arguments

None

#### Returns

String? (nullable signed URL)

### 6. uploadBusinessPhotos

Upload one or more photos to Supabase storage under:
<user_id>/business_photos/<filename>

Stores all file paths in the business_photos array column.

#### Arguments

imageFiles: List<File>

#### Returns

None

### 7. getCurrentBusinessPhotosUrls

Fetch signed URLs (valid 60 seconds) for all business photos belonging to the current user.

#### Arguments

None

#### Returns

List<String> (signed URLs)

### 8. searchBusinessProfilesBySector

Retrieve all business profiles for a given sector (e.g. “F&B”, “Retail”).

#### Arguments

sector: String

#### Returns

List<BusinessProfile>
