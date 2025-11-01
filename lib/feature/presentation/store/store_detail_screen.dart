import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/store_model.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';

/// Screen to view any store's details by shop ID
/// This is different from StoreViewScreen which is for the user's own store
class StoreDetailScreen extends StatefulWidget {
  final String shopId;

  const StoreDetailScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  bool isLoading = true;
  StoreModel? store;
  final IApiMethod apiMethod = IApiMethod();

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    setState(() => isLoading = true);

    try {
      final token = Preferences.authToken;
      final response = await apiMethod.get(
        url: Urls.getShopById(widget.shopId),
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final storeData = response.data!['data'];

        // Handle ownerId - if it's an object, extract just the ID string
        if (storeData['ownerId'] is Map) {
          storeData['ownerId'] = (storeData['ownerId'] as Map)['_id'];
        }

        setState(() {
          store = StoreModel.fromJson(storeData);
          isLoading = false;
        });
      } else {
        setState(() {
          store = null;
          isLoading = false;
        });
        AppUtils.toastError("Store not found");
      }
    } catch (e) {
      AppUtils.log("Error loading store: $e");
      setState(() {
        store = null;
        isLoading = false;
      });
      AppUtils.toastError("Failed to load store details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              title: "Store Details",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              hasTopSafe: false,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : store == null
                  ? _buildErrorView()
                  : _buildStoreDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          TextView(
            text: "Store not found",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreDetailsView() {
    return RefreshIndicator(
      onRefresh: _loadStoreDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Logo
                    if (store!.logoUrl != null && store!.logoUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          store!.logoUrl!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildLogoPlaceholder();
                          },
                        ),
                      )
                    else
                      _buildLogoPlaceholder(),
                    const SizedBox(height: 16),

                    // Store Name
                    TextView(
                      text: store!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: store!.isActive
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextView(
                        text: store!.isActive ? "Active" : "Inactive",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: store!.isActive
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description Section
            _buildInfoCard(
              title: "Description",
              icon: Icons.description_outlined,
              child: TextView(
                text: store!.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Information
            _buildInfoCard(
              title: "Contact Information",
              icon: Icons.contact_mail_outlined,
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.email_outlined,
                    "Email",
                    store!.contactEmail,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    "Phone",
                    store!.contactPhone,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "Address",
                    store!.address,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Statistics Card
            _buildInfoCard(
              title: "Store Statistics",
              icon: Icons.bar_chart,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    "Products",
                    store!.products.length.toString(),
                    Icons.inventory_2_outlined,
                  ),
                  Container(height: 60, width: 1, color: Colors.grey[300]),
                  _buildStatItem(
                    "Created",
                    _formatDate(store!.createdAt),
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // View Products Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  AppUtils.toast("View products coming soon");
                },
                icon: const Icon(Icons.inventory_outlined, color: Colors.white),
                label: const Text(
                  "View Products",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.store, size: 60, color: Colors.grey[400]),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.btnColor, size: 24),
                const SizedBox(width: 8),
                TextView(
                  text: title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextView(
                text: value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.btnColor, size: 32),
        const SizedBox(height: 8),
        TextView(
          text: value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        TextView(
          text: label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.year}";
  }
}
