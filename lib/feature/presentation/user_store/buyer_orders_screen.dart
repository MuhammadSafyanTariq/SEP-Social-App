import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  final UserStoreController _storeController = Get.find<UserStoreController>();
  final Set<String> _expandedOrderIds = {};
  final Map<String, String> _productImageCache = {}; // Cache for product images
  String _selectedFilter =
      'all'; // all, pending, processing, shipped, delivered, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadBuyerOrders();
  }

  void _loadBuyerOrders() {
    LoaderUtils.show();
    _storeController
        .loadBuyerOrders()
        .then((_) {
          LoaderUtils.dismiss();
        })
        .catchError((error) {
          LoaderUtils.dismiss();
        });
  }

  Future<String> _getProductImage(String? productId) async {
    if (productId == null || productId.isEmpty) return '';

    // Check cache first
    if (_productImageCache.containsKey(productId)) {
      return _productImageCache[productId]!;
    }

    try {
      // Fetch product details
      final product = await _storeController.loadProductDetails(productId);

      if (product != null &&
          product.mediaUrls != null &&
          product.mediaUrls!.isNotEmpty) {
        final imageUrl = product.mediaUrls!.first;
        // Cache the image URL
        _productImageCache[productId] = imageUrl;
        return imageUrl;
      }
    } catch (e) {
      AppUtils.log('Error fetching product image: $e');
    }

    return '';
  }

  void _toggleOrderExpansion(String orderId) {
    AppUtils.log('Toggling order expansion for ID: $orderId');
    AppUtils.log('Current expanded IDs: $_expandedOrderIds');
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
        AppUtils.log('Removed from expanded set');
      } else {
        _expandedOrderIds.add(orderId);
        AppUtils.log('Added to expanded set');
      }
    });
    AppUtils.log('After toggle expanded IDs: $_expandedOrderIds');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          AppBar2(
            title: 'My Orders',
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
          ),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              AppUtils.log(
                '==================== BUYER ORDERS UI BUILD ====================',
              );
              AppUtils.log(
                'Controller userOrders length: ${_storeController.userOrders.length}',
              );

              // Get buyer orders and apply filter
              final allOrders = _storeController.userOrders;
              final buyerOrders = _selectedFilter == 'all'
                  ? allOrders
                  : _selectedFilter == 'shipped'
                  ? allOrders
                        .where(
                          (order) =>
                              order.status.toLowerCase() == 'shipped' ||
                              order.status.toLowerCase() == 'delivered',
                        )
                        .toList()
                  : allOrders
                        .where(
                          (order) =>
                              order.status.toLowerCase() ==
                              _selectedFilter.toLowerCase(),
                        )
                        .toList();

              AppUtils.log('Buyer orders count in UI: ${buyerOrders.length}');
              AppUtils.log('Selected filter: $_selectedFilter');

              // Log order details for debugging
              for (var order in buyerOrders) {
                AppUtils.log('Order ID: ${order.id}');
                AppUtils.log('  - Product Name: ${order.productName}');
                AppUtils.log('  - Product Price: ${order.productPrice}');
                AppUtils.log('  - Quantity: ${order.quantity}');
                AppUtils.log('  - Total Amount: ${order.totalAmount}');
                AppUtils.log('  - Status: ${order.status}');
                AppUtils.log('  - Store Name: ${order.storeName}');
                AppUtils.log('  - Seller Name: ${order.sellerName}');
              }
              AppUtils.log(
                '================================================================',
              );

              // Show empty state if no orders found
              if (buyerOrders.isEmpty) {
                AppUtils.log('Showing empty state - no orders');
                return _buildEmptyState();
              }

              AppUtils.log(
                'Building orders list with ${buyerOrders.length} items',
              );

              // Show orders list
              return RefreshIndicator(
                onRefresh: () async => _loadBuyerOrders(),
                child: ListView.builder(
                  padding: 16.allSide,
                  itemCount: buyerOrders.length,
                  itemBuilder: (context, index) {
                    final order = buyerOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Processing', 'value': 'processing'},
      {'label': 'Shipped', 'value': 'shipped'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return Container(
      height: 50.sdp,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: TextView(
                text: filter['label']!,
                style: 12.txtMediumBlack.copyWith(
                  color: isSelected ? AppColors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['value']!;
                });
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.btnColor,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? AppColors.btnColor
                    : AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final filterText = _selectedFilter == 'all'
        ? 'No Orders Found'
        : 'No ${_selectedFilter.capitalize} Orders';

    final filterSubtext = _selectedFilter == 'all'
        ? 'You haven\'t placed any orders yet'
        : 'You have no orders with ${_selectedFilter} status';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80.sdp,
            color: AppColors.grey,
          ),
          16.height,
          TextView(text: filterText, style: 20.txtMediumBlack),
          8.height,
          TextView(text: filterSubtext, style: 14.txtRegularGrey),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Use a unique identifier - prefer id, but fallback to productId + createdAt
    final orderId =
        order.id ??
        '${order.productId}_${order.createdAt?.millisecondsSinceEpoch ?? 0}';
    final isExpanded = _expandedOrderIds.contains(orderId);

    AppUtils.log(
      'Building order card for ID: $orderId, isExpanded: $isExpanded',
    );
    AppUtils.log('  - Order.id: ${order.id}');
    AppUtils.log('  - Product: ${order.productName}');
    AppUtils.log('  - Price: ${order.productPrice}');
    AppUtils.log('  - Quantity: ${order.quantity}');

    return GestureDetector(
      onTap: () {
        _toggleOrderExpansion(orderId);
      },
      child: Container(
        margin: 12.bottom,
        padding: 16.allSide,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main order info - Always visible
            Row(
              children: [
                // Product image with FutureBuilder
                FutureBuilder<String>(
                  future: _getProductImage(order.productId),
                  builder: (context, snapshot) {
                    final hasImage =
                        snapshot.hasData && snapshot.data!.isNotEmpty;
                    final imageUrl = snapshot.data ?? '';
                    final fullImageUrl = Urls.getFullImageUrl(imageUrl);

                    return Container(
                      width: 60.sdp,
                      height: 60.sdp,
                      decoration: BoxDecoration(
                        color: AppColors.btnColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageView(
                                url: fullImageUrl,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                imageType: ImageType.network,
                                defaultImage: AppImages.dummyProfile,
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag,
                              color: AppColors.btnColor,
                              size: 30.sdp,
                            ),
                    );
                  },
                ),
                16.width,

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: order.productName ?? 'Unknown Product',
                        style: 16.txtMediumBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      TextView(
                        text:
                            'Qty: ${order.quantity} × \$${(order.productPrice ?? 0.0).toStringAsFixed(2)}',
                        style: 14.txtRegularGrey,
                      ),
                      4.height,
                      TextView(
                        text:
                            'Total: \$${(order.totalAmount ?? 0.0).toStringAsFixed(2)}',
                        style: 16.txtMediumBlack.copyWith(
                          color: AppColors.btnColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildOrderStatus(order.status),
                    8.height,
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.grey,
                      size: 24.sdp,
                    ),
                  ],
                ),
              ],
            ),

            // Expanded details
            if (isExpanded) ...[
              16.height,
              Divider(color: AppColors.grey.withOpacity(0.3)),
              16.height,
              _buildExpandedDetails(order),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(OrderModel order) {
    return Container(
      padding: 12.allSide,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(text: 'Order Details', style: 14.txtMediumBlack),
          12.height,

          if (order.storeName != null)
            _buildDetailRow('Store', order.storeName!),

          if (order.sellerName != null)
            _buildDetailRow('Seller', order.sellerName!),

          if (order.address != null && order.address!.isNotEmpty)
            _buildDetailRow('Address', order.address!),

          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty)
            _buildDetailRow('Tracking', order.trackingNumber!),

          if (order.createdAt != null)
            _buildDetailRow(
              'Ordered',
              '${order.createdAt!.day.toString().padLeft(2, '0')}/${order.createdAt!.month.toString().padLeft(2, '0')}/${order.createdAt!.year} at ${order.createdAt!.hour.toString().padLeft(2, '0')}:${order.createdAt!.minute.toString().padLeft(2, '0')}',
            ),

          if (order.updatedAt != null && order.status != 'pending')
            _buildDetailRow(
              'Updated',
              '${order.updatedAt!.day.toString().padLeft(2, '0')}/${order.updatedAt!.month.toString().padLeft(2, '0')}/${order.updatedAt!.year} at ${order.updatedAt!.hour.toString().padLeft(2, '0')}:${order.updatedAt!.minute.toString().padLeft(2, '0')}',
            ),

          // Action buttons for pending orders
          if (order.status == 'pending') ...[
            16.height,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40.sdp,
                    child: OutlinedButton(
                      onPressed: () => _cancelOrder(order),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextView(
                        text: 'Cancel Order',
                        style: 14.txtMediumBlack.copyWith(color: AppColors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action button for shipped/delivered orders
          if (order.status.toLowerCase() == 'shipped' ||
              order.status.toLowerCase() == 'delivered') ...[
            16.height,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40.sdp,
                    child: ElevatedButton(
                      onPressed: () => _markAsCompleted(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenlight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextView(
                        text: 'Mark as Completed',
                        style: 14.txtMediumBlack.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatus(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = AppColors.orange;
        statusText = 'Pending';
        break;
      case 'processing':
        statusColor = AppColors.btnColor;
        statusText = 'Processing';
        break;
      case 'shipped':
        statusColor = AppColors.btnColor;
        statusText = 'Shipped';
        break;
      case 'delivered':
        statusColor = AppColors.green;
        statusText = 'Delivered';
        break;
      case 'completed':
        statusColor = AppColors.greenlight;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = AppColors.red;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = AppColors.grey;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: TextView(
        text: statusText,
        style: 12.txtMediumBlack.copyWith(color: statusColor),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: 6.bottom,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.sdp,
            child: TextView(text: '$label:', style: 12.txtRegularGrey),
          ),
          8.width,
          Expanded(
            child: TextView(
              text: value,
              style: 12.txtMediumBlack,
              maxlines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.red),
            8.width,
            Text('Cancel Order'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.pop(context);

              // Show loading using LoaderUtils
              LoaderUtils.show();

              // Call cancel order API
              final success = await _storeController.cancelOrder(order.id!);

              // Dismiss loading
              LoaderUtils.dismiss();

              // Reload orders if successful
              if (success) {
                _loadBuyerOrders();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.greenlight),
            8.width,
            Text('Mark as Completed'),
          ],
        ),
        content: Text(
          'Have you received this order? Marking it as completed confirms you have received the product.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog first
              Navigator.pop(context);

              // Show loading using LoaderUtils
              LoaderUtils.show();

              // Call mark as completed API
              final success = await _storeController.markOrderAsCompleted(
                order.id!,
              );

              // Dismiss loading
              LoaderUtils.dismiss();

              // Reload orders if successful
              if (success) {
                _loadBuyerOrders();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.greenlight),
            child: Text('Yes, Mark as Completed'),
          ),
        ],
      ),
    );
  }
}
