# Internal API Documentation

**Purpose:** Describes how to use the `map_api` to properly display maps and access their information.

# Single Marker Map

### `lib/map_api/map_service.dart`

### Purpose

Displays a map, alongside a single dynamic marker. This marker will update its location to where the user taps on the map, and call a callback function if specified.

### `MapService.getSingleMarkerMap()`

```dart
Widget getSingleMarkerMap({
    required LatLng initialCenter,
    void Function(LatLng)? onMarkerChanged,
})
```

Builds and returns a SingleMarkerMap centered at the specified location and with the specified callback, if any.

#### Arguments
- A `LatLng` object defining the coordinates of the center of the map
- A function taking in a `LatLng` object and returning nothing that is called whenever the position of the dynamic marker is updated using the updated location as the argument

#### Returns

- A `SingleMarkerMap` widget.


---

# Mulit-Marker Map

### `lib/map_api/map_service.dart`

### Purpose

Displays a map populated with static markers at locations specified from a list of `BusinessProfiles`.

### `MapService.getMultiMarkerMap()`

```dart
Widget getMultiMarkerMap({
    required LatLng initialCenter,
    required List<BusinessProfile> markerProfiles,
    void Function(BusinessProfile)? onMarkerTapped,
})
```

Builds and returns a MultiMarkerMap centered at the specified location, populated with markers at the locations of the provided `BusinessProfiles`.

#### Arguments
- A `LatLng` object defining the coordinates of the center of the map
- A `List` of `BusinessProfile` objects, containing latitude and longitude that determine where each marker is placed, and other information specifying what business each marker represents
- A function taking in a `BusinessProfile` object and returning nothing that is called whenever a marker is tapped, using its corresponding `BusinessProfile` as the argument

#### Returns

- A `MultiMarkerMap` widget.
