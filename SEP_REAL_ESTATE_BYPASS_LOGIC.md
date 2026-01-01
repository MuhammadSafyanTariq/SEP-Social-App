# SEP Real Estate - Bypass Logic Documentation

## 📋 Overview

The SEP Real Estate module leverages the existing product infrastructure without modifying core product APIs or database schemas. It uses a **"bypass logic"** approach where real estate-specific data is encoded in the `category` field of the product model.

---

## 🔑 Key Concept: Category Field Encoding

Real estate data is stored using the existing product API endpoints, with special metadata encoded in the `category` field:

**Format:**
```
propertyType+realestate+country+city+contactInfo
```

**Example:**
```
Villa+realestate+UAE+Dubai+971501234567
```

### Field Breakdown:
- **Index 0**: Property Type (e.g., "Villa", "Apartment", "House")
- **Index 1**: Identifier `"realestate"` (used for filtering)
- **Index 2**: Country
- **Index 3**: City
- **Index 4**: Contact Information (phone/email)

---

## 💾 Saving Real Estate Data

### 1. Upload New Real Estate Listing

**File:** [lib/feature/presentation/real_estate/upload_real_estate_screen.dart](lib/feature/presentation/real_estate/upload_real_estate_screen.dart)

**Process:**

#### Step 1: Validate User Has Shop
```dart
final shopResponse = await _apiMethod.get(
  url: Urls.getMyShop,
  authToken: token,
  headers: {},
);

final shopId = shopResponse.data!['data']['_id'] as String;
```
- Real estate listings require a shop (reusing product module logic)
- Shop ID is required to associate the listing with the user

#### Step 2: Upload Media Files
```dart
List<String> uploadedUrls = [];
for (String filePath in selectedImages) {
  final response = await _authRepository.uploadPhoto(
    imageFile: File(filePath),
  );
  if (response.isSuccess) {
    uploadedUrls.add(response.data!.first);
  }
}
```
- Supports up to 10 images/videos
- Uses existing photo upload infrastructure
- Returns array of uploaded media URLs

#### Step 3: Encode Category Field (Bypass Logic)
```dart
final categoryValue = 
  "${_propertyTypeController.text.trim()}+realestate+${_countryController.text.trim()}+${_cityController.text.trim()}+${_contactInfoController.text.trim()}";
```
- Concatenates real estate metadata with `+` delimiter
- `realestate` keyword is the identifier for filtering

#### Step 4: Create Product with Encoded Data
```dart
final realEstateData = {
  "name": _propertyNameController.text.trim(),
  "description": _descriptionController.text.trim(),
  "price": double.parse(_priceController.text.trim()),
  "mediaUrls": uploadedUrls,
  "category": categoryValue, // Bypass: storing real estate data
  "isAvailable": true,
  "shopId": shopId,
};

final response = await _apiMethod.post(
  url: Urls.userProduct, // Uses existing product endpoint
  body: realEstateData,
  headers: {},
  authToken: token,
);
```

**API Endpoint:** `POST /api/products` (existing product endpoint)

---

### 2. Edit Existing Real Estate Listing

**File:** [lib/feature/presentation/real_estate/edit_real_estate_screen.dart](lib/feature/presentation/real_estate/edit_real_estate_screen.dart)

**Process:**

Similar to upload, but uses `PUT` method:

```dart
final categoryValue = 
  "${_propertyTypeController.text.trim()}+realestate+${_countryController.text.trim()}+${_cityController.text.trim()}+${_contactInfoController.text.trim()}";

final updateData = {
  "name": _propertyNameController.text.trim(),
  "description": _descriptionController.text.trim(),
  "price": double.parse(_priceController.text.trim()),
  "mediaUrls": allMediaUrls,
  "category": categoryValue,
  "isAvailable": true,
  "shopId": shopId,
};

final response = await _apiMethod.put(
  url: '${Urls.userProduct}/${widget.propertyId}',
  body: updateData,
  headers: {},
  authToken: token,
);
```

**API Endpoint:** `PUT /api/products/:id` (existing product endpoint)

---

## 🔍 Fetching Real Estate Data

### 1. Fetch All Real Estate Listings

**File:** [lib/feature/presentation/real_estate/real_estate_list_screen.dart](lib/feature/presentation/real_estate/real_estate_list_screen.dart)

**Process:**

#### Step 1: Fetch All Products
```dart
final response = await _apiMethod.get(
  url: Urls.getAllUserProducts,
  authToken: token,
  headers: {},
);

List<dynamic> products;
if (data is List) {
  products = data;
} else if (data is Map && data['products'] != null) {
  products = data['products'] as List<dynamic>;
}
```

**API Endpoint:** `GET /api/products` (existing product endpoint)

#### Step 2: Filter for Real Estate Products
```dart
final filteredProducts = products.where((product) {
  final category = product['category']?.toString().toLowerCase() ?? '';
  
  // Check if product is a real estate listing
  if (!category.contains('realestate')) return false;
  
  // ... additional filters
}).toList();
```

**Key Filter:** Check if `category` contains `"realestate"` keyword

#### Step 3: Extract Real Estate Metadata
```dart
// Parse category field to extract real estate data
final categoryParts = category.split('+');

// Extract specific fields:
String propertyType = '';
String country = '';
String city = '';
String contactInfo = '';

if (categoryParts.isNotEmpty) {
  propertyType = categoryParts[0];  // Index 0: Property Type
}
if (categoryParts.length >= 3) {
  country = categoryParts[2];        // Index 2: Country
}
if (categoryParts.length >= 4) {
  city = categoryParts[3];           // Index 3: City
}
if (categoryParts.length >= 5) {
  contactInfo = categoryParts[4];    // Index 4: Contact Info
}
```

#### Step 4: Apply Advanced Filters
```dart
// Filter by country
if (selectedCountry != null && selectedCountry!.isNotEmpty) {
  final categoryParts = category.split('+');
  if (categoryParts.length < 3) return false;
  final country = categoryParts[2].toLowerCase();
  if (!country.contains(selectedCountry!.toLowerCase())) return false;
}

// Filter by city
if (selectedCity != null && selectedCity!.isNotEmpty) {
  final categoryParts = category.split('+');
  if (categoryParts.length < 4) return false;
  final city = categoryParts[3].toLowerCase();
  if (!city.contains(selectedCity!.toLowerCase())) return false;
}

// Filter by price range
if (priceRange != null) {
  final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
  if (price < priceRange!.start || price > priceRange!.end) return false;
}

// Filter by search text (name, description, location, type)
if (searchText.isNotEmpty) {
  final name = product['name']?.toString().toLowerCase() ?? '';
  final description = product['description']?.toString().toLowerCase() ?? '';
  
  return name.contains(searchText) ||
         description.contains(searchText) ||
         category.contains(searchText);
}
```

#### Step 5: Exclude Own Listings
```dart
// Filter out listings from the current user's shop
if (myShopId != null) {
  final productShopId = _extractShopId(product['shopId']);
  if (productShopId != null && productShopId == myShopId) {
    return false; // Exclude user's own listings
  }
}
```

---

### 2. Fetch Single Real Estate Detail

**File:** [lib/feature/presentation/real_estate/real_estate_detail_screen.dart](lib/feature/presentation/real_estate/real_estate_detail_screen.dart)

**Process:**

#### Step 1: Fetch Product by ID
```dart
final response = await _apiMethod.get(
  url: '${Urls.userProduct}/${widget.propertyId}',
  authToken: token,
  headers: {},
);

propertyData = response.data!['data'];
```

**API Endpoint:** `GET /api/products/:id` (existing product endpoint)

#### Step 2: Extract Location & Contact Info
```dart
String _extractLocationInfo(String key) {
  final category = propertyData!['category']?.toString() ?? '';
  final parts = category.split('+');

  // Format: propertyType+realestate+country+city+contactInfo
  if (key == 'country' && parts.length >= 3) {
    return parts[2];
  } else if (key == 'city' && parts.length >= 4) {
    return parts[3];
  } else if (key == 'contact' && parts.length >= 5) {
    return parts[4];
  } else if (key == 'propertyType' && parts.isNotEmpty) {
    return parts[0];
  }

  return '';
}
```

#### Step 3: Display Parsed Data
```dart
// Usage in UI:
String propertyType = _extractLocationInfo('propertyType');
String country = _extractLocationInfo('country');
String city = _extractLocationInfo('city');
String contactInfo = _extractLocationInfo('contact');
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    SAVING FLOW                          │
└─────────────────────────────────────────────────────────┘

User Input:
  ├── Property Name
  ├── Description
  ├── Price
  ├── Property Type (Villa, Apartment, etc.)
  ├── Country
  ├── City
  ├── Contact Info
  └── Media Files (images/videos)

         ↓

Encode Category Field:
  "Villa+realestate+UAE+Dubai+971501234567"

         ↓

Create Product Object:
  {
    "name": "Luxury Villa",
    "description": "Beautiful 5BR villa...",
    "price": 2500000,
    "mediaUrls": ["url1", "url2"],
    "category": "Villa+realestate+UAE+Dubai+971501234567",
    "isAvailable": true,
    "shopId": "shop123"
  }

         ↓

POST /api/products (existing endpoint)

         ↓

Stored in Product Collection


┌─────────────────────────────────────────────────────────┐
│                   FETCHING FLOW                         │
└─────────────────────────────────────────────────────────┘

GET /api/products (all products)

         ↓

Filter Products:
  category.contains('realestate')

         ↓

Parse Category Field:
  "Villa+realestate+UAE+Dubai+971501234567"
            ↓
  parts = category.split('+')
            ↓
  ├── parts[0] = "Villa"        (Property Type)
  ├── parts[1] = "realestate"   (Identifier)
  ├── parts[2] = "UAE"          (Country)
  ├── parts[3] = "Dubai"        (City)
  └── parts[4] = "971501234567" (Contact)

         ↓

Apply Filters:
  ├── Country Filter
  ├── City Filter
  ├── Price Range Filter
  ├── Search Text Filter
  └── Exclude Own Listings

         ↓

Display Real Estate Listings
```

---

## 🛡️ Filtering Real Estate from Regular Products

**File:** [lib/feature/presentation/SportsProducts/sportsProduct.dart](lib/feature/presentation/SportsProducts/sportsProduct.dart)

To prevent real estate listings from appearing in regular product lists:

```dart
// Filter out real estate products (category contains "+realestate+")
final category = product.category?.toLowerCase() ?? '';
if (category.contains('+realestate+')) {
  return false; // Exclude real estate products
}
```

---

## 📊 Summary

### ✅ Advantages of Bypass Logic:
1. **No Backend Changes**: Uses existing product API endpoints
2. **No Database Migration**: Leverages existing product schema
3. **Fast Implementation**: No need to create new tables/collections
4. **Backward Compatible**: Doesn't break existing product functionality
5. **Flexible**: Can add more metadata by extending the format

### ⚠️ Considerations:
1. **Category Field Parsing**: Must be consistent across all screens
2. **Validation**: Ensure `+` delimiter isn't used in user input
3. **Migration Path**: If backend support is added later, can migrate from encoded format
4. **Search Limitations**: Category field is not indexed for real estate-specific searches

### 🔧 Technical Details:
- **Identifier Keyword**: `realestate` (case-insensitive)
- **Delimiter**: `+` character
- **Format**: `propertyType+realestate+country+city+contactInfo`
- **API Endpoints**: Uses standard product CRUD endpoints
- **Media Storage**: Uses existing photo upload service

---

## 📁 Related Files

- [upload_real_estate_screen.dart](lib/feature/presentation/real_estate/upload_real_estate_screen.dart) - Create new listings
- [edit_real_estate_screen.dart](lib/feature/presentation/real_estate/edit_real_estate_screen.dart) - Update existing listings
- [real_estate_list_screen.dart](lib/feature/presentation/real_estate/real_estate_list_screen.dart) - Browse & filter listings
- [real_estate_detail_screen.dart](lib/feature/presentation/real_estate/real_estate_detail_screen.dart) - View listing details

---

## 🚀 Quick Reference

**Saving:**
```dart
// Encode: propertyType+realestate+country+city+contactInfo
final category = "$propertyType+realestate+$country+$city+$contact";

// Save via product API
POST /api/products { category: category, ... }
```

**Fetching:**
```dart
// Filter products
if (category.contains('realestate')) { /* is real estate */ }

// Parse data
final parts = category.split('+');
final propertyType = parts[0];
final country = parts[2];
final city = parts[3];
final contact = parts[4];
```

---

**Last Updated:** December 31, 2025
