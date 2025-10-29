import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/utils/appUtils.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  final UserStoreController _storeController = Get.find<UserStoreController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSellerOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSellerOrders() {
    _storeController.loadSellerOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar2(
            title: 'Store Orders',
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
          ),

          // Tab bar for order status filter
          Container(
            margin: 16.allSide,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.btnColor,
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.grey,
              labelStyle: 12.txtMediumWhite,
              unselectedLabelStyle: 12.txtRegularGrey,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Processing'),
                Tab(text: 'Shipped'),
              ],
            ),
          ),

          Expanded(
            child: GetBuilder<UserStoreController>(
              builder: (controller) {
                if (controller.isLoadingOrders.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!controller.hasStore) {
                  return _buildNoStoreState();
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(controller.getSellerOrders()),
                    _buildOrdersList(
                      _filterOrdersByStatus(
                        controller.getSellerOrders(),
                        'pending',
                      ),
                    ),
                    _buildOrdersList(
                      _filterOrdersByStatus(
                        controller.getSellerOrders(),
                        'processing',
                      ),
                    ),
                    _buildOrdersList(
                      _filterOrdersByStatus(
                        controller.getSellerOrders(),
                        'shipped',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStoreState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80.sdp, color: AppColors.grey),
          16.height,
          TextView(text: 'No Store Found', style: 20.txtMediumBlack),
          8.height,
          TextView(
            text: 'Create a store to start receiving orders',
            style: 14.txtRegularGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadSellerOrders(),
      child: ListView.builder(
        padding: 16.allSide,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sdp,
            color: AppColors.grey,
          ),
          16.height,
          TextView(text: 'No Orders Yet', style: 20.txtMediumBlack),
          8.height,
          TextView(
            text: 'Orders from customers will appear here',
            style: 14.txtRegularGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final product = _storeController.getProductById(order.productId ?? '');

    return Container(
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
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(
                text: 'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                style: 16.txtMediumBlack,
              ),
              _buildOrderStatus(order.status),
            ],
          ),

          12.height,

          // Product info
          if (product != null) ...[
            Row(
              children: [
                // Product image
                Container(
                  width: 60.sdp,
                  height: 60.sdp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.grey.withOpacity(0.1),
                  ),
                  child: product.mediaUrls?.isNotEmpty == true
                      ? ImageView(
                          url: product.mediaUrls!.first,
                          imageType: ImageType.network,
                          fit: BoxFit.cover,
                          width: 60.sdp,
                          height: 60.sdp,
                        )
                      : Icon(Icons.image, color: AppColors.grey),
                ),

                12.width,

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: product.name ?? 'Unknown Product',
                        style: 16.txtMediumBlack,
                      ),
                      4.height,
                      TextView(
                        text: 'Quantity: ${order.quantity}',
                        style: 14.txtRegularGrey,
                      ),
                      4.height,
                      TextView(
                        text:
                            '\$${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                        style: 16.txtMediumBlack,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Fallback if product not found
            Container(
              padding: 12.allSide,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag, color: AppColors.grey),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: 'Product Information Unavailable',
                          style: 14.txtRegularGrey,
                        ),
                        4.height,
                        TextView(
                          text: 'Quantity: ${order.quantity}',
                          style: 12.txtRegularGrey,
                        ),
                        TextView(
                          text:
                              '\$${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                          style: 14.txtMediumBlack,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          16.height,

          // Customer and delivery info
          _buildOrderDetails(order),

          // Action buttons for sellers
          if (order.status == 'pending' || order.status == 'processing') ...[
            16.height,
            _buildSellerActions(order),
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

  Widget _buildOrderDetails(OrderModel order) {
    return Container(
      padding: 12.allSide,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDetailRow('Customer ID', order.userId ?? 'Unknown'),

          if (order.address?.isNotEmpty == true)
            _buildDetailRow('Delivery Address', order.address!),

          if (order.trackingNumber?.isNotEmpty == true)
            _buildDetailRow('Tracking Number', order.trackingNumber!),

          if (order.createdAt != null)
            _buildDetailRow(
              'Order Date',
              '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: 4.bottom,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(text: '$label:', style: 12.txtRegularGrey),
          8.width,
          Expanded(
            child: TextView(text: value, style: 12.txtMediumBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerActions(OrderModel order) {
    return Column(
      children: [
        if (order.status == 'pending') ...[
          // Accept/Reject buttons for pending orders
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.sdp,
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(order, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: TextView(
                      text: 'Reject',
                      style: 14.txtMediumBlack.copyWith(color: AppColors.red),
                    ),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: Container(
                  height: 40.sdp,
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order, 'processing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: TextView(text: 'Accept', style: 14.txtMediumWhite),
                  ),
                ),
              ),
            ],
          ),
        ],

        if (order.status == 'processing') ...[
          // Mark as shipped button
          Container(
            width: double.infinity,
            height: 40.sdp,
            child: ElevatedButton(
              onPressed: () => _showShippingDialog(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextView(
                text: 'Mark as Shipped',
                style: 14.txtMediumWhite,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<OrderModel> _filterOrdersByStatus(
    List<OrderModel> orders,
    String status,
  ) {
    return orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  void _updateOrderStatus(OrderModel order, String newStatus) {
    String action = '';
    switch (newStatus) {
      case 'processing':
        action = 'accept';
        break;
      case 'cancelled':
        action = 'reject';
        break;
      case 'shipped':
        action = 'mark as shipped';
        break;
      default:
        action = 'update';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action'),
        content: Text('Are you sure you want to $action this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _storeController.updateOrderStatus(order.id!, newStatus);
            },
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'cancelled'
                  ? AppColors.red
                  : AppColors.btnColor,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showShippingDialog(OrderModel order) {
    final trackingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ship Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter tracking number for this shipment:'),
            SizedBox(height: 16),
            TextField(
              controller: trackingController,
              decoration: InputDecoration(
                hintText: 'Tracking Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Update order with tracking number and shipped status
              _storeController.updateOrderStatus(order.id!, 'shipped');
              AppUtils.toast(
                'Order marked as shipped with tracking: ${trackingController.text.trim()}',
              );
            },
            child: Text('Ship Order'),
          ),
        ],
      ),
    );
  }
}
