# Real Estate Module

## Overview
This module provides real estate listing functionality that leverages the existing product upload infrastructure without modifying the core product module. It uses a "bypass logic" approach where real estate-specific data is encoded in the category field.

## Features
- ✅ Upload real estate listings with up to 10 photos/videos
- ✅ Browse all real estate listings in a grid view
- ✅ View detailed property information
- ✅ Search and filter by location
- ✅ Display country, city, price, upload date, and contact info
- ✅ Contact property owners via phone or email

## Implementation Details

### Bypass Logic
The module reuses the existing product API (`/api/user-product`) by encoding real estate-specific information in the `category` field:

**Format:** `propertyType+realestate+country+city+contactInfo`

**Example:** `House+realestate+USA+New York+john@example.com`

This allows the module to:
1. Store additional real estate fields without database changes
2. Filter real estate listings by checking if category contains "realestate"
3. Extract location and contact info from the category string

### Screens

#### 1. RealEstateListScreen
**Path:** `lib/feature/presentation/real_estate/real_estate_list_screen.dart`

Features:
- Grid view of all real estate listings
- Search bar for filtering
- Filter dialog for country/city
- Pull to refresh
- Pagination support
- FAB button to add new listings

**Usage:**
```dart
import 'package:sep/feature/presentation/real_estate/real_estate_list_screen.dart';

// Navigate to listings
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RealEstateListScreen(),
  ),
);
```

#### 2. RealEstateDetailScreen
**Path:** `lib/feature/presentation/real_estate/real_estate_detail_screen.dart`

Features:
- Image carousel with page indicator
- Property details (price, location, type, date)
- Full description
- Contact information card
- Call/Email buttons

**Usage:**
```dart
import 'package:sep/feature/presentation/real_estate/real_estate_detail_screen.dart';

// Navigate to detail view
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RealEstateDetailScreen(
      propertyId: 'property_id_here',
    ),
  ),
);
```

#### 3. UploadRealEstateScreen
**Path:** `lib/feature/presentation/real_estate/upload_real_estate_screen.dart`

Features:
- Multi-image/video picker (up to 10 media files)
- Form validation
- Property type, location, price, and description fields
- Contact information (phone or email)
- Uses existing product upload API

**Usage:**
```dart
import 'package:sep/feature/presentation/real_estate/upload_real_estate_screen.dart';

// Navigate to upload screen
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UploadRealEstateScreen(),
  ),
);

if (result == true) {
  // Listing was uploaded successfully
  // Refresh your list
}
```

## Integration Guide

### Add to Navigation Menu

To add a "Real Estate" option to your app's menu or home screen:

```dart
import 'package:sep/feature/presentation/real_estate/real_estate_list_screen.dart';

// In your menu widget
ListTile(
  leading: Icon(Icons.home_work),
  title: Text('Real Estate'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealEstateListScreen(),
      ),
    );
  },
),
```

### Add to Bottom Navigation

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.home_work),
  label: 'Real Estate',
),
```

## API Endpoints Used

The module uses existing product API endpoints:

- **List Products:** `GET /api/user-product/all`
  - Returns all products (filtered client-side for real estate)
  
- **Get Product Details:** `GET /api/user-product/:id`
  - Returns single product/property details
  
- **Create Product:** `POST /api/user-product`
  - Creates new product/property listing
  
- **Get User Shop:** `GET /api/shop/myShop`
  - Required to associate listings with a shop

## Data Model

The module leverages the existing `ProductDataModel`:

```dart
{
  "_id": "property_id",
  "name": "Beautiful 3BR House",
  "description": "Spacious house with garden...",
  "price": "350000",
  "mediaUrls": ["url1", "url2", ...],
  "category": "House+realestate+USA+California++1234567890",
  "createdAt": "2025-12-11T...",
  "shopId": "shop_id"
}
```

## Important Notes

1. **Shop Required:** Users must create a shop before uploading real estate listings (same requirement as products)

2. **No Database Changes:** This implementation doesn't require any backend modifications

3. **Filtering:** Real estate listings are filtered from all products by checking if the category contains "realestate"

4. **Contact Privacy:** Contact information is stored in the category field and displayed only in the detail view

5. **Existing Product Module:** The product module remains completely untouched and functional

## Future Enhancements

Potential improvements (would require backend changes):

- Dedicated real estate table in database
- Advanced filters (bedrooms, bathrooms, square footage)
- Map view integration
- Favorites/saved properties
- Property comparison
- Virtual tours
- Mortgage calculator

## Dependencies

All required dependencies are already in your project:
- `flutter/material.dart` - UI components
- `get` - State management
- `image_picker` - Media selection
- `url_launcher` - Contact actions
- `intl` - Date formatting

## Testing

To test the module:

1. Navigate to the Real Estate List Screen
2. Tap the "Add Listing" FAB button
3. Fill in property details and upload images
4. Submit the listing
5. Verify it appears in the list
6. Tap to view details
7. Test contact functionality

## Support

For issues or questions:
- Check that you have a shop created (required for product API)
- Verify internet connection for API calls
- Check console logs for API errors
- Ensure all required fields are filled when uploading
