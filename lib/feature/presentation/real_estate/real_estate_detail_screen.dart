import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:intl/intl.dart';

class RealEstateDetailScreen extends StatefulWidget {
  final String propertyId;
  final Map<String, dynamic>? propertyData;

  const RealEstateDetailScreen({
    Key? key,
    required this.propertyId,
    this.propertyData,
  }) : super(key: key);

  @override
  State<RealEstateDetailScreen> createState() => _RealEstateDetailScreenState();
}

class _RealEstateDetailScreenState extends State<RealEstateDetailScreen> {
  final IApiMethod _apiMethod = IApiMethod();
  bool isLoading = true;
  Map<String, dynamic>? propertyData;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Use provided data if available, otherwise fetch from API
    if (widget.propertyData != null) {
      propertyData = widget.propertyData;
      isLoading = false;
    } else {
      _loadPropertyDetails();
    }
  }

  Future<void> _loadPropertyDetails() async {
    setState(() => isLoading = true);

    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: '${Urls.userProduct}/${widget.propertyId}',
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        setState(() {
          propertyData = response.data!['data'];
        });
      } else {
        AppUtils.toastError("Failed to load property details");
        Navigator.pop(context);
      }
    } catch (e) {
      AppUtils.toastError("Error: ${e.toString()}");
      Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _extractLocationInfo(String key) {
    if (propertyData == null) return '';

    final category = propertyData!['category']?.toString() ?? '';
    final parts = category.split('+');

    // Format: category+realestate+country+city+contactInfo
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

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      AppUtils.toastError("Could not launch phone dialer");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      AppUtils.toastError("Could not launch email");
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.toast("$label copied to clipboard");
  }

  String _getFullImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '${Urls.appApiBaseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (propertyData == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: TextView(text: "Property not found")),
      );
    }

    final images = propertyData!['mediaUrls'] as List<dynamic>? ?? [];
    final name = propertyData!['name'] ?? 'Untitled Property';
    final description =
        propertyData!['description'] ?? 'No description available';
    final price = propertyData!['price']?.toString() ?? '0';
    final country = _extractLocationInfo('country');
    final city = _extractLocationInfo('city');
    final contact = _extractLocationInfo('contact');
    final propertyType = _extractLocationInfo('propertyType');

    // Parse date
    final createdAt = propertyData!['createdAt'] as String?;
    String formattedDate = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = DateFormat('MMMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = 'Date not available';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            AppBar2(
              title: "Property Details",
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Carousel
                    if (images.isNotEmpty)
                      Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            child: PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) {
                                setState(() => currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  _getFullImageUrl(images[index] as String),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholderImage(),
                                );
                              },
                            ),
                          ),

                          // Image counter
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextView(
                                text:
                                    '${currentImageIndex + 1}/${images.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _buildPlaceholderImage(),

                    // Property Info
                    Padding(
                      padding: 16.all,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property Name
                          TextView(
                            text: name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          8.height,

                          // Price
                          TextView(
                            text: '\$$price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.btnColor,
                            ),
                          ),
                          12.height,

                          // Location
                          if (city.isNotEmpty || country.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: Colors.blue[700],
                                  ),
                                  6.width,
                                  TextView(
                                    text:
                                        '$city${city.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          16.height,

                          // Property Details Card
                          Container(
                            padding: 16.all,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                if (propertyType.isNotEmpty)
                                  _buildDetailRow(
                                    'Property Type',
                                    propertyType,
                                  ),
                                if (propertyType.isNotEmpty &&
                                    formattedDate.isNotEmpty)
                                  Divider(height: 24),
                                if (formattedDate.isNotEmpty)
                                  _buildDetailRow('Listed On', formattedDate),
                              ],
                            ),
                          ),
                          24.height,

                          // Description
                          TextView(
                            text: "Description",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          8.height,
                          TextView(
                            text: description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey[700],
                            ),
                          ),
                          24.height,

                          // Contact Information
                          if (contact.isNotEmpty) ...[
                            TextView(
                              text: "Contact Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            12.height,
                            Container(
                              padding: 16.all,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: () {
                                          final shop =
                                              propertyData!['shopId']
                                                  as Map<String, dynamic>?;
                                          final logoUrl =
                                              shop?['logoUrl']?.toString() ??
                                              '';

                                          if (logoUrl.isNotEmpty) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: ImageView(
                                                url: _getFullImageUrl(logoUrl),
                                                imageType: ImageType.network,
                                                fit: BoxFit.cover,
                                                width: 48,
                                                height: 48,
                                              ),
                                            );
                                          }
                                          return Icon(
                                            Icons.store,
                                            color: Colors.green[700],
                                            size: 26,
                                          );
                                        }(),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextView(
                                              text:
                                                  (propertyData!['shopId']
                                                      as Map<
                                                        String,
                                                        dynamic
                                                      >?)?['name'] ??
                                                  'Owner',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            4.height,
                                            TextView(
                                              text: contact.isNotEmpty
                                                  ? contact
                                                  : "Property Owner",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.copy, size: 20),
                                        onPressed: () => _copyToClipboard(
                                          contact,
                                          "Contact",
                                        ),
                                        color: Colors.green[700],
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            // Detect if it's a phone number or email
                                            if (contact.contains('@')) {
                                              _launchEmail(contact);
                                            } else {
                                              _launchPhone(contact);
                                            }
                                          },
                                          icon: Icon(
                                            contact.contains('@')
                                                ? Icons.email
                                                : Icons.phone,
                                            size: 18,
                                          ),
                                          label: Text(
                                            contact.contains('@')
                                                ? 'Send Email'
                                                : 'Call Now',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[600],
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            // Navigate to owner's profile
                                            final shop =
                                                propertyData!['shopId']
                                                    as Map<String, dynamic>?;

                                            // Extract owner ID from nested object or string
                                            String? ownerId;
                                            final ownerIdField =
                                                shop?['ownerId'];
                                            if (ownerIdField is String) {
                                              ownerId = ownerIdField;
                                            } else if (ownerIdField
                                                is Map<String, dynamic>) {
                                              ownerId =
                                                  ownerIdField['_id']
                                                      as String?;
                                            }

                                            String ownerName =
                                                shop?['name'] ?? 'Owner';

                                            if (ownerId != null &&
                                                ownerId.isNotEmpty) {
                                              final profileData =
                                                  ProfileDataModel(
                                                    id: ownerId,
                                                    name: ownerName,
                                                    email: contact.contains('@')
                                                        ? contact
                                                        : null,
                                                    phone:
                                                        !contact.contains('@')
                                                        ? contact
                                                        : null,
                                                  );

                                              Get.to(
                                                () => FriendProfileScreen(
                                                  data: profileData,
                                                ),
                                              );
                                            } else {
                                              AppUtils.toastError(
                                                "Owner information not available",
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.person_outline,
                                            size: 18,
                                          ),
                                          label: Text('Owner'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.green[700],
                                            side: BorderSide(
                                              color: Colors.green[600]!,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextView(
          text: label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        TextView(
          text: value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: Colors.grey[400]),
          8.height,
          TextView(
            text: "No image available",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
