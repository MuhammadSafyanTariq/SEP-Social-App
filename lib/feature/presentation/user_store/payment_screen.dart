import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/wallet/wallet_screen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/widget.dart';

class PaymentScreen extends StatefulWidget {
  final UserProductModel product;
  final int initialQuantity;

  const PaymentScreen({
    Key? key,
    required this.product,
    this.initialQuantity = 1,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final UserStoreController _storeController = Get.find<UserStoreController>();
  final TextEditingController _addressController = TextEditingController();
  late int _quantity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  double get _totalPrice => (widget.product.price ?? 0) * _quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar2(
            title: 'Payment',
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: 16.allSide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  24.height,
                  _buildQuantitySelector(),
                  24.height,
                  _buildAddressField(),
                  24.height,
                  _buildPriceSummary(),
                  24.height,
                  _buildWalletBalance(),
                  32.height,
                  _buildPaymentButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final hasImage =
        widget.product.mediaUrls != null &&
        widget.product.mediaUrls!.isNotEmpty;
    final rawImageUrl = hasImage ? widget.product.mediaUrls!.first : '';
    final imageUrl = rawImageUrl.isNotEmpty
        ? AppUtils.configImageUrl(rawImageUrl)
        : '';

    // Debug logging
    AppUtils.log('Payment Screen - Product Image Debug:');
    AppUtils.log('  hasImage: $hasImage');
    AppUtils.log('  rawImageUrl: $rawImageUrl');
    AppUtils.log('  imageUrl: $imageUrl');
    AppUtils.log('  mediaUrls: ${widget.product.mediaUrls}');

    return Container(
      padding: 16.allSide,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image - Left
          Container(
            width: 80.sdp,
            height: 80.sdp,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: hasImage && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageView(
                      url: imageUrl,
                      fit: BoxFit.cover,
                      width: 80.sdp,
                      height: 78.sdp,
                      imageType: ImageType.network,
                    ),
                  )
                : Icon(Icons.inventory_2, color: AppColors.grey, size: 40.sdp),
          ),
          16.width,

          // Product Name and Price - Right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: widget.product.name ?? '',
                  style: 16.txtMediumBlack,
                  maxlines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.height,
                TextView(
                  text:
                      '\$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: 18.txtMediumBlack.copyWith(color: AppColors.btnColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: 16.allSide,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          TextView(text: 'Quantity:', style: 16.txtMediumBlack),
          Spacer(),

          // Quantity controls
          GestureDetector(
            onTap: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
              }
            },
            child: Container(
              width: 36.sdp,
              height: 36.sdp,
              decoration: BoxDecoration(
                color: _quantity > 1
                    ? AppColors.btnColor
                    : AppColors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.remove, color: AppColors.white, size: 20.sdp),
            ),
          ),
          16.width,

          TextView(text: _quantity.toString(), style: 18.txtMediumBlack),
          16.width,

          GestureDetector(
            onTap: () {
              setState(() {
                _quantity++;
              });
            },
            child: Container(
              width: 36.sdp,
              height: 36.sdp,
              decoration: BoxDecoration(
                color: AppColors.btnColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: AppColors.white, size: 20.sdp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Container(
      padding: 16.allSide,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.btnColor, size: 20.sdp),
              8.width,
              TextView(text: 'Delivery Address', style: 16.txtMediumBlack),
              4.width,
              TextView(
                text: '*',
                style: 16.txtMediumBlack.copyWith(color: AppColors.red),
              ),
            ],
          ),
          12.height,
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your complete delivery address...',
              hintStyle: 14.txtRegularGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.btnColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: 14.txtRegularWhite.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: 16.allSide,
      decoration: BoxDecoration(
        color: AppColors.btnColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.btnColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(text: 'Unit Price:', style: 14.txtRegularGrey),
              TextView(
                text: '\$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
                style: 14.txtMediumBlack,
              ),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(text: 'Quantity:', style: 14.txtRegularGrey),
              TextView(text: '$_quantity', style: 14.txtMediumBlack),
            ],
          ),
          16.height,
          Divider(color: AppColors.btnColor.withOpacity(0.3)),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(text: 'Total Price:', style: 18.txtMediumBlack),
              TextView(
                text: '\$${_totalPrice.toStringAsFixed(2)}',
                style: 22.txtMediumBlack.copyWith(color: AppColors.btnColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBalance() {
    return Obx(() {
      final walletBalance = _storeController.walletBalance.value;

      return Container(
        padding: 16.allSide,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.btnColor,
                  size: 24.sdp,
                ),
                12.width,
                TextView(text: 'Wallet Balance:', style: 16.txtMediumBlack),
              ],
            ),
            TextView(
              text: '\$${walletBalance.toStringAsFixed(2)}',
              style: 18.txtMediumBlack.copyWith(
                color: walletBalance >= _totalPrice
                    ? AppColors.greenlight
                    : AppColors.red,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentButtons() {
    return Column(
      children: [
        AppButton(
          label: 'Pay Now',
          onTap: _handlePayment,
          isLoading: _isLoading,
          width: double.infinity,
          height: 48.sdp,
          buttonColor: AppColors.btnColor,
        ),
        16.height,
        AppButton(
          label: 'Cancel',
          onTap: () => Navigator.pop(context),
          width: double.infinity,
          height: 48.sdp,
          buttonColor: AppColors.white,
          buttonBorderColor: AppColors.grey,
          labelStyle: 16.txtMediumBlack,
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;

    // Validate address
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      AppUtils.toastError('Please enter a delivery address');
      return;
    }

    if (address.length < 10) {
      AppUtils.toastError('Please enter a complete delivery address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current wallet balance
      await _storeController.loadWalletBalance();
      final walletBalance = _storeController.walletBalance.value;

      // Check if user has sufficient balance
      if (walletBalance < _totalPrice) {
        setState(() => _isLoading = false);
        _showTopUpDialog();
        return;
      }

      // Get current user details from ProfileCtrl
      final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
      final userId = profileCtrl.profileData.value.id;

      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        AppUtils.toastError('User not found. Please login again.');
        return;
      }

      // Create order with user-provided address
      final order = OrderModel(
        userId: userId,
        storeId: widget.product.storeId,
        productId: widget.product.id,
        quantity: _quantity,
        totalAmount: _totalPrice,
        status: 'pending',
        address: address, // Use the address from the text field
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppUtils.log('Creating order with address: $address');

      // Create order via API first (before deducting balance)
      await _storeController.createOrder(order);

      // Only deduct amount from wallet if order creation was successful
      await _storeController.deductFromWallet(_totalPrice);

      setState(() => _isLoading = false);

      // Show success dialog
      _showPaymentSuccess();
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtils.toastError('Payment failed: ${e.toString()}');
    }
  }

  void _showTopUpDialog() {
    final shortfall = _totalPrice - _storeController.walletBalance.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.red),
            SizedBox(width: 8),
            Text('Insufficient Balance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your wallet balance is insufficient to complete this purchase.',
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Required:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${_storeController.walletBalance.value.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shortfall:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${shortfall.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                  ),
                ),
              ],
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
              _navigateToTopUp();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.btnColor),
            child: Text('Top Up Wallet'),
          ),
        ],
      ),
    );
  }

  void _navigateToTopUp() {
    // Navigate to wallet screen for top-up
    Get.to(() => WalletScreen());
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.greenlight),
            SizedBox(width: 8),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your order has been placed successfully.'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Paid:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenlight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Balance:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${(_storeController.walletBalance.value).toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to payment screen
              Navigator.pop(context); // Go back to product detail screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
