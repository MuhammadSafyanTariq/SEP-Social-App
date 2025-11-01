import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final IApiMethod apiMethod = IApiMethod();

  // Orders data
  List<Map<String, dynamic>> orders = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool isLoadingOrders = false;
  final ScrollController _scrollController = ScrollController();
  Set<String> expandedOrderIds = {};
  String selectedOrderStatus = 'all'; // Filter for orders

  // Product details cache
  Map<String, Map<String, dynamic>> productCache = {};

  @override
  void initState() {
    super.initState();
    _loadOrders(page: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingOrders && currentPage < totalPages) {
        _loadOrders(page: currentPage + 1);
      }
    }
  }

  Future<void> _loadOrders({int page = 1, int limit = 10}) async {
    if (isLoadingOrders) return;

    setState(() => isLoadingOrders = true);

    try {
      final token = Preferences.authToken;

      AppUtils.log("Loading customer orders, page: $page");

      final response = await apiMethod.get(
        url: '/api/order/my-orders?page=$page&limit=$limit',
        authToken: token,
        headers: {},
      );

      AppUtils.log("Orders response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];
        final List<dynamic> ordersList = data['orders'] ?? [];
        final pagination = data['pagination'];

        setState(() {
          if (page == 1) {
            orders = List<Map<String, dynamic>>.from(ordersList);
          } else {
            orders.addAll(List<Map<String, dynamic>>.from(ordersList));
          }

          currentPage = pagination['page'] ?? 1;
          totalPages = pagination['totalPages'] ?? 1;
          totalCount = pagination['totalCount'] ?? 0;
          isLoadingOrders = false;
        });
      } else {
        setState(() => isLoadingOrders = false);
      }
    } catch (e) {
      AppUtils.log("Error loading orders: $e");
      setState(() => isLoadingOrders = false);
    }
  }

  // Method to fetch product details by ID
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    // Check cache first
    if (productCache.containsKey(productId)) {
      return productCache[productId];
    }

    try {
      final token = Preferences.authToken;
      final response = await apiMethod.get(
        url: '/api/user-product/$productId',
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final productData = response.data!['data'] as Map<String, dynamic>;
        // Cache the product data
        productCache[productId] = productData;
        return productData;
      }
      return null;
    } catch (e) {
      AppUtils.log("Error fetching product by ID: $e");
      return null;
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedOrderStatus == 'all') {
      return orders;
    }
    return orders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      if (selectedOrderStatus == 'in progress') {
        return status == 'processing';
      }
      return status == selectedOrderStatus.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              title: "My Orders",
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
              child: orders.isEmpty && !isLoadingOrders
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildOrderFilterChips(),
                          const SizedBox(height: 8),
                          _buildOrdersList(),
                          if (isLoadingOrders)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your order history will appear here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'In Progress', 'value': 'in progress'},
      {'label': 'Shipped', 'value': 'shipped'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Canceled', 'value': 'cancelled'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedOrderStatus == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedOrderStatus = filter['value']!;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.green.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? Colors.green.shade700 : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? Colors.green.shade600 : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    final displayOrders = filteredOrders;

    if (displayOrders.isEmpty && orders.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_list_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "No ${selectedOrderStatus == 'all' ? '' : selectedOrderStatus} orders found",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: displayOrders.map((order) => _buildOrderCard(order)).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['_id'] ?? '';
    final isExpanded = expandedOrderIds.contains(orderId);

    final storeId = order['storeId'] as Map<String, dynamic>?;
    final sellerId = order['sellerId'] as Map<String, dynamic>?;
    final productIdField = order['productId'];

    // Extract product ID string
    String? productIdString;
    String productName = 'Product';

    if (productIdField is String) {
      productIdString = productIdField;
    } else if (productIdField is Map<String, dynamic>) {
      productIdString = productIdField['_id'] as String?;
      productName = productIdField['name'] ?? 'Product';
    }

    final storeName = storeId?['name'] ?? 'Store';
    final sellerName = sellerId?['name'] ?? 'Seller';
    final sellerEmail = sellerId?['email'] ?? '';
    final quantity = order['quantity'] ?? 0;
    final totalAmount = order['totalAmount'] ?? 0.0;
    final status = order['status'] ?? 'pending';
    final trackingNumber = order['trackingNumber'] ?? '';
    final address = order['address'] ?? '';
    final createdAt = order['createdAt'] ?? '';

    return FutureBuilder<Map<String, dynamic>?>(
      future: productIdString != null
          ? fetchProductById(productIdString)
          : null,
      builder: (context, snapshot) {
        // Get product data from snapshot or use defaults
        final productData = snapshot.data;
        if (productData != null) {
          productName = productData['name'] ?? productName;
        }

        final productMediaUrls = productData?['mediaUrls'] as List? ?? [];

        String productImageUrl = '';
        if (productMediaUrls.isNotEmpty) {
          final url = productMediaUrls[0] as String;
          productImageUrl = url.startsWith('http')
              ? url
              : '${Urls.appApiBaseUrl}$url';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedOrderIds.remove(orderId);
                    } else {
                      expandedOrderIds.add(orderId);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: productImageUrl.isNotEmpty
                                ? Image.network(
                                    productImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultProductImage();
                                    },
                                  )
                                : _buildDefaultProductImage(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order #${orderId.substring(orderId.length - 8)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _getStatusColor(status),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Divider
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 12),

                      // Order Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Qty: $quantity',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.btnColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatOrderDate(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // Cancel Order Button for Pending Orders
                      if (status.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleCancelOrder(orderId),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text(
                              "Cancel Order",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Mark as Completed Button for Shipped Orders
                      if (status.toLowerCase() == 'shipped') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleMarkAsCompleted(orderId),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: const Text(
                              "Mark as Completed",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Expanded Details
              if (isExpanded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Details Section
                      Row(
                        children: [
                          Icon(Icons.store, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            "Store Information",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow2(
                              Icons.store_outlined,
                              "Store",
                              storeName,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow2(
                              Icons.person_outline,
                              "Seller",
                              sellerName,
                            ),
                            if (sellerEmail.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildDetailRow2(
                                Icons.email_outlined,
                                "Email",
                                sellerEmail,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delivery Address Section
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Delivery Address",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          address.isNotEmpty ? address : 'No address provided',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Tracking Number Section (if available)
                      if (trackingNumber.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tracking Number",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            trackingNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultProductImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
    );
  }

  Widget _buildDetailRow2(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'shipped':
        return const Color(0xFF2196F3); // Blue
      case 'processing':
        return const Color(0xFFFF9800); // Orange
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      case 'pending':
        return const Color(0xFF9E9E9E); // Grey
      case 'all':
        return const Color(0xFF757575); // Dark Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _formatOrderDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
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
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleCancelOrder(String orderId) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cancel Order'),
            ],
          ),
          content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.post(
        url: '/api/order/cancel',
        authToken: token,
        body: {'orderId': orderId},
        headers: {},
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Order cancelled successfully");
        // Reload orders to refresh the list
        _loadOrders(page: 1);
      } else {
        final errorMessage =
            response.data?['message'] ?? "Failed to cancel order";
        AppUtils.toast(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error cancelling order: $e");
      AppUtils.toast("An error occurred while cancelling the order");
    }
  }

  Future<void> _handleMarkAsCompleted(String orderId) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Confirm Delivery'),
            ],
          ),
          content: const Text(
            'Please confirm that you have received your order in good condition. Once marked as completed, this action cannot be undone.\n\nHave you received your order?',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Received',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.post(
        url: '/api/order/mark-completed',
        authToken: token,
        body: {'orderId': orderId},
        headers: {},
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Order marked as completed successfully");
        // Reload orders to refresh the list
        _loadOrders(page: 1);
      } else {
        final errorMessage =
            response.data?['message'] ?? "Failed to mark order as completed";
        AppUtils.toast(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error marking order as completed: $e");
      AppUtils.toast("An error occurred while marking the order as completed");
    }
  }
}
