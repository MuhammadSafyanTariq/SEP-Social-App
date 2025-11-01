import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/networking/urls.dart' show Urls;

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final int quantity;
  final double totalAmount;

  const CheckoutScreen({
    Key? key,
    required this.productData,
    required this.quantity,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final IApiMethod _apiMethod = IApiMethod();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final ProfileCtrl _profileCtrl = ProfileCtrl.find;
  bool isProcessing = false;

  // List of valid countries
  static const List<String> validCountries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Argentina',
    'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
    'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin',
    'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil',
    'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon',
    'Canada', 'Cape Verde', 'Central African Republic', 'Chad', 'Chile',
    'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', 'Croatia',
    'Cuba', 'Cyprus', 'Czech Republic', 'Denmark', 'Djibouti', 'Dominica',
    'Dominican Republic', 'East Timor', 'Ecuador', 'Egypt', 'El Salvador',
    'Equatorial Guinea', 'Eritrea', 'Estonia', 'Ethiopia', 'Fiji', 'Finland',
    'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece',
    'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti',
    'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq',
    'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan',
    'Kenya', 'Kiribati', 'North Korea', 'South Korea', 'Kuwait', 'Kyrgyzstan',
    'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein',
    'Lithuania', 'Luxembourg', 'Macedonia', 'Madagascar', 'Malawi', 'Malaysia',
    'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius',
    'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
    'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal',
    'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'Norway',
    'Oman', 'Pakistan', 'Palau', 'Panama', 'Papua New Guinea', 'Paraguay',
    'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal',
    'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia',
    'Solomon Islands', 'Somalia', 'South Africa', 'South Sudan', 'Spain',
    'Sri Lanka', 'Sudan', 'Suriname', 'Swaziland', 'Sweden', 'Switzerland',
    'Syria', 'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Togo', 'Tonga',
    'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam',
    'Yemen', 'Zambia', 'Zimbabwe',
    // Common abbreviations
    'USA', 'UK', 'UAE',
  ];

  @override
  void initState() {
    super.initState();
    // Load user's profile to get current address if available
    _profileCtrl.getProfileDetails();

    // Add listeners to update UI when address fields change
    _streetController.addListener(() => setState(() {}));
    _cityController.addListener(() => setState(() {}));
    _postalCodeController.addListener(() => setState(() {}));
    _countryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return '${Urls.appApiBaseUrl}$url';
  }

  String _buildAddressPreview() {
    final parts = <String>[];

    if (_streetController.text.trim().isNotEmpty) {
      parts.add(_streetController.text.trim());
    }

    if (_cityController.text.trim().isNotEmpty ||
        _postalCodeController.text.trim().isNotEmpty) {
      final cityPart = _cityController.text.trim();
      final codePart = _postalCodeController.text.trim();

      if (cityPart.isNotEmpty && codePart.isNotEmpty) {
        parts.add("$cityPart($codePart)");
      } else if (cityPart.isNotEmpty) {
        parts.add(cityPart);
      } else if (codePart.isNotEmpty) {
        parts.add("($codePart)");
      }
    }

    if (_countryController.text.trim().isNotEmpty) {
      parts.add(_countryController.text.trim());
    }

    return parts.isEmpty ? "Enter address details above" : parts.join(", ");
  }

  bool _isValidAddress(String text) {
    // Check if address has at least 5 characters and contains letters
    return text.trim().length >= 5 && RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  bool _isValidCity(String text) {
    // City should have at least 2 characters and only letters/spaces
    final trimmed = text.trim();
    return trimmed.length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed);
  }

  bool _isValidPostalCode(String text) {
    // Postal code should be alphanumeric with at least 3 characters
    final trimmed = text.trim();
    return trimmed.length >= 3 &&
        RegExp(r'^[a-zA-Z0-9\s-]+$').hasMatch(trimmed);
  }

  bool _isValidCountry(String text) {
    // Check if country exists in the valid countries list (case-insensitive)
    final trimmed = text.trim();
    return validCountries.any(
      (country) => country.toLowerCase() == trimmed.toLowerCase(),
    );
  }

  Future<void> _createOrder() async {
    // Validate all address fields with proper validation
    if (_streetController.text.trim().isEmpty) {
      AppUtils.toastError("Please enter street address");
      return;
    }

    if (!_isValidAddress(_streetController.text)) {
      AppUtils.toastError(
        "Please enter a valid street address (minimum 5 characters)",
      );
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      AppUtils.toastError("Please enter city");
      return;
    }

    if (!_isValidCity(_cityController.text)) {
      AppUtils.toastError("Please enter a valid city name (letters only)");
      return;
    }

    if (_postalCodeController.text.trim().isEmpty) {
      AppUtils.toastError("Please enter postal code");
      return;
    }

    if (!_isValidPostalCode(_postalCodeController.text)) {
      AppUtils.toastError("Please enter a valid postal code");
      return;
    }

    if (_countryController.text.trim().isEmpty) {
      AppUtils.toastError("Please enter country");
      return;
    }

    if (!_isValidCountry(_countryController.text)) {
      AppUtils.toastError(
        "Please enter a valid country name from the supported list",
      );
      return;
    }

    // Format address as: street, city(code), country
    final formattedAddress =
        "${_streetController.text.trim()}, ${_cityController.text.trim()}(${_postalCodeController.text.trim()}), ${_countryController.text.trim()}";

    // Check wallet balance
    final walletBalance =
        _profileCtrl.profileData.value.walletBalance?.toDouble() ?? 0.0;
    if (walletBalance < widget.totalAmount) {
      AppUtils.toastError(
        "Insufficient wallet balance. Your balance: \$${walletBalance.toStringAsFixed(2)}",
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      final token = Preferences.authToken;
      final productId = widget.productData['_id'] as String;
      final storeData = widget.productData['shopId'] as Map<String, dynamic>?;
      final storeId = storeData?['_id'] as String?;

      if (storeId == null) {
        AppUtils.toastError("Store information not available");
        setState(() => isProcessing = false);
        return;
      }

      final orderData = {
        "productId": productId,
        "storeId": storeId,
        "quantity": widget.quantity,
        "totalAmount": widget.totalAmount,
        "address": formattedAddress,
      };

      AppUtils.log("Creating order with data: $orderData");

      final response = await _apiMethod.post(
        url: '/api/order/create',
        authToken: token,
        body: orderData,
        headers: {},
      );

      AppUtils.log("Order creation response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        // Refresh profile to update wallet balance
        await _profileCtrl.getProfileDetails();

        // Show success dialog
        _showSuccessDialog(response.data!['data']);
      } else {
        AppUtils.toastError(
          response.data?['message'] ?? "Failed to create order",
        );
      }
    } catch (e) {
      AppUtils.log("Error creating order: $e");
      AppUtils.toastError("Error creating order: ${e.toString()}");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 60, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              "Order Placed Successfully!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Status: ${orderData['status']?.toString().toUpperCase() ?? 'PENDING'}",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.btnColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to product details
                  Navigator.of(context).pop(); // Go back to products list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productName = widget.productData['name'] ?? 'Product';
    final productPrice =
        double.tryParse(widget.productData['price']?.toString() ?? '0') ?? 0.0;
    final mediaUrls =
        (widget.productData['mediaUrls'] as List?)?.cast<String>() ?? [];
    final imageUrl = mediaUrls.isNotEmpty
        ? _getFullImageUrl(mediaUrls.first)
        : '';
    final storeData = widget.productData['shopId'] as Map<String, dynamic>?;
    final storeName = storeData?['name'] ?? 'Store';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              title: "Checkout",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Details Section
                    _buildSectionCard(
                      title: "Product Details",
                      child: Row(
                        children: [
                          // Product Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ImageView(
                                      url: imageUrl,
                                      imageType: ImageType.network,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 78,
                                    ),
                                  )
                                : Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                          ),
                          const SizedBox(width: 14),
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
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Sold by: $storeName",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "\$${productPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.btnColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Order Details Section
                    _buildSectionCard(
                      title: "Order Details",
                      child: Column(
                        children: [
                          _buildDetailRow("Quantity", "${widget.quantity}"),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Price per unit",
                            "\$${productPrice.toStringAsFixed(2)}",
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[300], height: 1),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Subtotal",
                            "\$${widget.totalAmount.toStringAsFixed(2)}",
                            isTotal: false,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Delivery Fee",
                            "Free",
                            valueColor: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[300], height: 1),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            "Total Amount",
                            "\$${widget.totalAmount.toStringAsFixed(2)}",
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Delivery Address Section
                    _buildSectionCard(
                      title: "Delivery Address",
                      child: Column(
                        children: [
                          // Street Address
                          EditText(
                            controller: _streetController,
                            hint: "Street Address",
                            noOfLines: 2,
                            radius: 10,
                            borderColor: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),

                          // City
                          EditText(
                            controller: _cityController,
                            hint: "City",
                            radius: 10,
                            borderColor: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),

                          // Postal Code
                          EditText(
                            controller: _postalCodeController,
                            hint: "Postal Code",
                            inputType: TextInputType.text,
                            radius: 10,
                            borderColor: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),

                          // Country
                          EditText(
                            controller: _countryController,
                            hint: "Country",
                            radius: 10,
                            borderColor: Colors.grey.shade300,
                          ),

                          // Preview formatted address
                          if (_streetController.text.isNotEmpty ||
                              _cityController.text.isNotEmpty ||
                              _postalCodeController.text.isNotEmpty ||
                              _countryController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Address Preview:",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _buildAddressPreview(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[900],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Method Section
                    _buildSectionCard(
                      title: "Payment Method",
                      child: Obx(() {
                        final walletBalance =
                            _profileCtrl.profileData.value.walletBalance
                                ?.toDouble() ??
                            0.0;
                        final hasEnoughBalance =
                            walletBalance >= widget.totalAmount;

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: hasEnoughBalance
                                    ? Colors.green.withOpacity(0.05)
                                    : Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: hasEnoughBalance
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: hasEnoughBalance
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: hasEnoughBalance
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Wallet Balance",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "\$${walletBalance.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: hasEnoughBalance
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    hasEnoughBalance
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: hasEnoughBalance
                                        ? Colors.green
                                        : Colors.red,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                            if (!hasEnoughBalance) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Please add \$${(widget.totalAmount - walletBalance).toStringAsFixed(2)} to your wallet",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color:
                valueColor ?? (isTotal ? AppColors.btnColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final walletBalance =
              _profileCtrl.profileData.value.walletBalance?.toDouble() ?? 0.0;
          final hasEnoughBalance = walletBalance >= widget.totalAmount;

          return ElevatedButton(
            onPressed: hasEnoughBalance && !isProcessing ? _createOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasEnoughBalance
                  ? AppColors.btnColor
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        hasEnoughBalance
                            ? "Pay Now - \$${widget.totalAmount.toStringAsFixed(2)}"
                            : "Insufficient Balance",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }
}
