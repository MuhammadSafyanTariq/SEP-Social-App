import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/feature/presentation/real_estate/real_estate_detail_screen.dart';
import 'package:sep/feature/presentation/real_estate/upload_real_estate_screen.dart';
import 'package:intl/intl.dart';

class RealEstateListScreen extends StatefulWidget {
  const RealEstateListScreen({Key? key}) : super(key: key);

  @override
  State<RealEstateListScreen> createState() => _RealEstateListScreenState();
}

class _RealEstateListScreenState extends State<RealEstateListScreen> {
  final IApiMethod _apiMethod = IApiMethod();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> realEstateList = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  int totalPages = 1;

  // Filter options
  String? selectedCountry;
  String? selectedCity;
  RangeValues? priceRange;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Store user's shop ID to filter out their own listings
  String? myShopId;

  @override
  void initState() {
    super.initState();
    _fetchMyShopId();
    _loadRealEstateListings();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchMyShopId() async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final shopData = response.data!['data'];
        myShopId = shopData['_id'] as String?;
        AppUtils.log("My shop ID loaded for real estate filtering: $myShopId");
      } else {
        myShopId = null;
      }
    } catch (e) {
      AppUtils.log("Error fetching my shop ID: $e");
      myShopId = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!isLoadingMore && currentPage < totalPages) {
        _loadRealEstateListings(page: currentPage + 1);
      }
    }
  }

  Future<void> _loadRealEstateListings({int page = 1}) async {
    if (page == 1) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    try {
      final token = Preferences.authToken;

      // Build query parameters
      final queryParams = <String, dynamic>{'page': page, 'limit': 20};

      if (searchController.text.isNotEmpty) {
        queryParams['search'] = searchController.text;
      }

      final response = await _apiMethod.get(
        url: Urls.getAllUserProducts,
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];

        // Handle both array and object responses
        List<dynamic> products;
        if (data is List) {
          products = data;
        } else if (data is Map && data['products'] != null) {
          products = data['products'] as List<dynamic>;
        } else {
          products = [];
        }

        // Filter for real estate products (category contains 'realestate')
        final searchText = searchController.text.toLowerCase();
        final filteredProducts = products.where((product) {
          final category = product['category']?.toString().toLowerCase() ?? '';
          if (!category.contains('realestate')) return false;

          // Filter out listings from the current user's shop
          if (myShopId != null) {
            final productShopId = _extractShopId(product['shopId']);
            if (productShopId != null && productShopId == myShopId) {
              AppUtils.log(
                "  ✓ FILTERING OUT own real estate listing: ${product['name']} (Shop ID: $productShopId)",
              );
              return false; // Exclude user's own listings
            }
          }

          // Apply country filter
          if (selectedCountry != null && selectedCountry!.isNotEmpty) {
            final categoryParts = category.split('+');
            if (categoryParts.length < 3) return false;
            final country = categoryParts[2].toLowerCase();
            if (!country.contains(selectedCountry!.toLowerCase())) return false;
          }

          // Apply city filter
          if (selectedCity != null && selectedCity!.isNotEmpty) {
            final categoryParts = category.split('+');
            if (categoryParts.length < 4) return false;
            final city = categoryParts[3].toLowerCase();
            if (!city.contains(selectedCity!.toLowerCase())) return false;
          }

          // Apply price range filter
          if (priceRange != null) {
            final price =
                double.tryParse(product['price']?.toString() ?? '0') ?? 0;
            if (price < priceRange!.start || price > priceRange!.end)
              return false;
          }

          // If no search text, include all real estate products
          if (searchText.isEmpty) return true;

          // Search in name, description, and category (location/type)
          final name = product['name']?.toString().toLowerCase() ?? '';
          final description =
              product['description']?.toString().toLowerCase() ?? '';

          return name.contains(searchText) ||
              description.contains(searchText) ||
              category.contains(searchText);
        }).toList();

        final List<Map<String, dynamic>> newListings = filteredProducts
            .cast<Map<String, dynamic>>();

        setState(() {
          if (page == 1) {
            realEstateList = newListings;
          } else {
            realEstateList.addAll(newListings);
          }
          currentPage = page;

          // Calculate total pages based on filtered results
          final totalCount =
              response.data!['totalCount'] ?? filteredProducts.length;
          totalPages = (totalCount / 20).ceil();
        });
      }
    } catch (e) {
      AppUtils.toastError("Error loading listings: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  // Helper method to extract shop ID from dynamic shopId field
  String? _extractShopId(dynamic shopId) {
    if (shopId == null) return null;

    if (shopId is String) {
      return shopId;
    } else if (shopId is Map) {
      return shopId['_id'] as String?;
    }

    return null;
  }

  void _applyFilters() {
    setState(() {
      // Apply local filtering for country and city
      // This could be enhanced to do server-side filtering
      _loadRealEstateListings();
    });
  }

  void _showFilterDialog() {
    final TextEditingController countryController = TextEditingController(
      text: selectedCountry ?? '',
    );
    final TextEditingController cityController = TextEditingController(
      text: selectedCity ?? '',
    );

    RangeValues currentPriceRange = priceRange ?? RangeValues(0, 100000);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Padding(
              padding: 20.all,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: "Filter Real Estate",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  20.height,
                  TextView(
                    text: "Country",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  EditText(
                    controller: countryController,
                    hint: "Enter country",
                    radius: 8,
                  ),
                  16.height,
                  TextView(
                    text: "City",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  EditText(
                    controller: cityController,
                    hint: "Enter city",
                    radius: 8,
                  ),
                  16.height,
                  TextView(
                    text: "Price Range",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextView(
                        text:
                            "\$${currentPriceRange.start.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.btnColor,
                        ),
                      ),
                      TextView(
                        text:
                            "\$${currentPriceRange.end.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.btnColor,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: currentPriceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    activeColor: AppColors.btnColor,
                    inactiveColor: Colors.grey[300],
                    labels: RangeLabels(
                      '\$${currentPriceRange.start.toInt()}',
                      '\$${currentPriceRange.end.toInt()}',
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        currentPriceRange = values;
                      });
                    },
                  ),
                  20.height,
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCountry = null;
                              selectedCity = null;
                              priceRange = null;
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text("Clear"),
                        ),
                      ),
                      16.width,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCountry = countryController.text.isEmpty
                                  ? null
                                  : countryController.text;
                              selectedCity = cityController.text.isEmpty
                                  ? null
                                  : cityController.text;

                              // Only set price range if it's different from default
                              if (currentPriceRange.start > 0 ||
                                  currentPriceRange.end < 100000) {
                                priceRange = currentPriceRange;
                              } else {
                                priceRange = null;
                              }
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: 16.horizontal,
              child: Row(
                children: [
                  Expanded(
                    child: EditText(
                      controller: searchController,
                      hint: "Search by location, type...",
                      radius: 20.sdp,
                      prefixIcon: Icon(Icons.search, color: AppColors.grey),
                      onChange: (value) {
                        _loadRealEstateListings();
                      },
                    ),
                  ),
                  12.width,
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (selectedCountry != null ||
                              selectedCity != null ||
                              priceRange != null)
                          ? AppColors.btnColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showFilterDialog,
                      icon: Icon(
                        Icons.filter_list,
                        color:
                            (selectedCountry != null ||
                                selectedCity != null ||
                                priceRange != null)
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            16.height,

            // Listings Grid
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : realEstateList.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => _loadRealEstateListings(),
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: 16.all,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount:
                            realEstateList.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == realEstateList.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return _buildRealEstateCard(realEstateList[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
          16.height,
          TextView(
            text: "No listings found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          8.height,
          TextView(
            text: "Be the first to add a real estate listing!",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getFullImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '${Urls.appApiBaseUrl}$url';
  }

  Widget _buildRealEstateCard(Map<String, dynamic> listing) {
    final images = listing['mediaUrls'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : '';
    final name = listing['name'] ?? 'Untitled Property';
    final price = listing['price']?.toString() ?? '0';
    final description = listing['description'] ?? '';
    final category = listing['category']?.toString() ?? '';

    // Parse category to extract location info
    final categoryParts = category.split('+');
    String location = '';
    String propertyType = '';
    String country = '';
    String city = '';

    if (categoryParts.isNotEmpty) {
      propertyType = categoryParts[0];
    }
    if (categoryParts.length >= 4) {
      country = categoryParts[2];
      city = categoryParts[3];
      location = '$city, $country';
    }

    // Parse date
    final createdAt = listing['createdAt'] as String?;
    String formattedDate = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = 'Recently';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RealEstateDetailScreen(propertyId: listing['_id'] ?? ''),
          ),
        );
      },
      child: Container(
        padding: 12.all,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.sdp),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: Container(
                width: 140.sdp,
                height: 140.sdp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sdp),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.sdp),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          _getFullImageUrl(imageUrl),
                          width: 138.sdp,
                          height: 138.sdp,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
            ),

            12.height,

            // Property Name
            TextView(
              text: name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            6.height,

            // Description
            TextView(
              text: description.isNotEmpty
                  ? description
                  : "Property details not available",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              maxlines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            6.height,

            // Location
            if (location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[700]),
                  4.width,
                  Expanded(
                    child: TextView(
                      text: location,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      maxlines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            8.height,

            // Price
            TextView(
              text: '\$ $price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greenlight,
              ),
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            8.height,

            // View Details Button
            SizedBox(
              width: double.infinity,
              height: 40.sdp,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RealEstateDetailScreen(
                        propertyId: listing['_id'] ?? '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenlight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sdp),
                  ),
                ),
                icon: Icon(Icons.visibility, size: 18.sdp),
                label: Text(
                  'View Details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.home_work, size: 50, color: Colors.grey[400]),
    );
  }
}
