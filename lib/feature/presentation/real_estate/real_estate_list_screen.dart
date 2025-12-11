import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRealEstateListings();
    _scrollController.addListener(_onScroll);
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
        final List<dynamic> products = response.data!['data'];

        // Filter for real estate products (category contains 'realestate')
        final filteredProducts = products.where((product) {
          final category = product['category']?.toString().toLowerCase() ?? '';
          return category.contains('realestate');
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

  void _applyFilters() {
    setState(() {
      // Apply local filtering for country and city
      // This could be enhanced to do server-side filtering
      _loadRealEstateListings();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter country",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setModalState(() => selectedCountry = value);
                },
              ),
              16.height,
              TextView(
                text: "City",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              8.height,
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter city",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setModalState(() => selectedCity = value);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            AppBar2(
              title: "Real Estate Listings",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
              backgroundColor: AppColors.white,
              hasTopSafe: true,
            ),

            // Search Bar
            Padding(
              padding: 16.horizontal,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by location, type...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            _loadRealEstateListings();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) => _loadRealEstateListings(),
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
                          childAspectRatio: 0.75,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadRealEstateScreen()),
          );
          if (result == true) {
            _loadRealEstateListings();
          }
        },
        backgroundColor: AppColors.btnColor,
        icon: Icon(Icons.add),
        label: Text("Add Listing"),
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

  Widget _buildRealEstateCard(Map<String, dynamic> listing) {
    final images = listing['mediaUrls'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : '';
    final name = listing['name'] ?? 'Untitled Property';
    final price = listing['price']?.toString() ?? '0';
    final category = listing['category']?.toString() ?? '';

    // Parse category to extract location info
    final categoryParts = category.split('+');
    String location = '';
    String country = '';
    String city = '';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: 8.all,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        if (location.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              2.width,
                              Expanded(
                                child: TextView(
                                  text: location,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: '\$$price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.btnColor,
                          ),
                        ),
                        if (formattedDate.isNotEmpty)
                          TextView(
                            text: formattedDate,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ],
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
