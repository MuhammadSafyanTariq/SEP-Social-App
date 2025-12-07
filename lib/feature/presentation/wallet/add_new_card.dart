import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../data/repository/payment_repo.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class CreditCard {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cardType;
  final DateTime dateAdded;

  CreditCard({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cardType,
    required this.dateAdded,
  });
}

class AddNewCard extends StatefulWidget {
  final Function(CreditCard) onCardAdded;

  const AddNewCard({Key? key, required this.onCardAdded}) : super(key: key);

  @override
  _AddNewCardState createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> with TickerProviderStateMixin {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();

  final FocusNode cardNumberFocus = FocusNode();
  final FocusNode expiryDateFocus = FocusNode();
  final FocusNode cvvFocus = FocusNode();
  final FocusNode cardHolderNameFocus = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CardFieldInputDetails? _cardDetails;

  String cardType = '';
  bool isFormValid = false;
  bool isCreatingToken = false;

  final GetStripeCtrl stripeCtrl = Get.put(GetStripeCtrl());
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  List<String?> get cardValidationData => [
    _cardDetails?.validNumber.name,
    _cardDetails?.validExpiryDate.name,
    _cardDetails?.validCVC.name,
  ];

  Widget _buildCardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: 'Card Number / Expiry / CVC',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.sdp),

        CardField(
          autofocus: true,
          enablePostalCode: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sdp),
              borderSide: BorderSide(color: AppColors.greenlight, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sdp),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sdp),
              borderSide: BorderSide(color: AppColors.greenlight, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sdp),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            error: cardValidationData.contains('Invalid') ? SizedBox() : null,
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sdp),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.all(20.sdp),
          ),
          onCardChanged: (card) {
            setState(() {
              AppUtils.log(card?.validCVC.name);

              // CardValidationState.Invalid
              // CardValidationState.Incomplete
              // CardValidationState.Valid
              _cardDetails = card;

              // Detect card type from brand
              if (card?.brand != null) {
                switch (card!.brand) {
                  case CardBrand.Visa:
                    cardType = 'Visa';
                    break;
                  case CardBrand.Mastercard:
                    cardType = 'Mastercard';
                    break;
                  case CardBrand.Amex:
                    cardType = 'American Express';
                    break;
                  case CardBrand.Discover:
                    cardType = 'Discover';
                    break;
                  default:
                    cardType = card.brand.toString().split('.').last;
                }
              }

              isFormValid =
                  card?.complete == true &&
                  cardHolderNameController.text.trim().isNotEmpty;
            });
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _initializeStripe();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    cardHolderNameController.addListener(_validateForm);

    cardHolderNameController.addListener(() {
      setState(() {
        isFormValid =
            (_cardDetails?.complete == true) &&
            cardHolderNameController.text.trim().isNotEmpty;
      });
    });
  }

  void _initializeStripe() {
    Stripe.publishableKey =
        "pk_live_51RQkfPF7GWl0gz6oggK8qEi9q8HgBJeZzneF9utkZXsReup0jHbiN9QXF0XqRhYUOFMqoaF0WdA28Gsifyx9esKO00cznRBhbr";
  }

  @override
  void dispose() {
    _animationController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    cardHolderNameController.dispose();
    cardNumberFocus.dispose();
    expiryDateFocus.dispose();
    cvvFocus.dispose();
    cardHolderNameFocus.dispose();
    super.dispose();
  }

  void _validateForm() {
    // Validation is handled by CardField's onCardChanged callback
    // This method is kept for the cardHolderNameController listener
    bool valid =
        (_cardDetails?.complete == true) &&
        cardHolderNameController.text.trim().isNotEmpty;

    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

  bool _validateCardNumber(String value) {
    return value.replaceAll(' ', '').length >= 13;
  }

  bool _validateExpiryDate(String value) {
    if (value.length != 5) return false;
    try {
      List<String> parts = value.split('/');
      int month = int.parse(parts[0]);
      int year = int.parse('20${parts[1]}');
      DateTime expiry = DateTime(year, month);
      return expiry.isAfter(DateTime.now()) && month >= 1 && month <= 12;
    } catch (e) {
      return false;
    }
  }

  bool _validateCVV(String value) {
    return value.length >= 3 && value.length <= 4;
  }

  Future<void> _createStripeToken() async {
    if (!isFormValid) {
      AppUtils.toast("Please complete all card details");
      return;
    }

    setState(() {
      isCreatingToken = true;
    });

    try {
      final name = cardHolderNameController.text.trim();

      final billingDetails = BillingDetails(
        name: name,
        address: Address(
          postalCode: '174021',
          country: 'IN',
          city: '',
          line1: '',
          line2: '',
          state: '',
        ),
      );

      final paymentMethod = await Stripe.instance
          .createPaymentMethod(
            params: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: billingDetails,
              ),
            ),
          )
          .applyLoader;

      AppUtils.log('Stripe PaymentMethod created: ${paymentMethod.id}');

      var customerId = profileCtrl.profileData.value.stripeCustomerId ?? "";

      var responseData = await PaymentRepo.token(
        paymentMethodId: paymentMethod.id,
        customerId: customerId,
      );

      AppUtils.log("Token API raw response: $responseData");
      AppUtils.log("Token API isSuccess: ${responseData.isSuccess}");

      if (responseData.isSuccess == true) {
        AppUtils.toast("Card Added Successfully");
        context.pop();
        Future.delayed(Duration(milliseconds: 300), () {
          final stripeCtrl = Get.find<GetStripeCtrl>();
          stripeCtrl.refreshCardList();
        });
      } else {
        AppUtils.toast("Failed to add card. Please try again.");
        AppUtils.log("Card add failed: $responseData");
      }
    } catch (e, stacktrace) {
      AppUtils.log('Stripe error: $e\n$stacktrace');
      AppUtils.toast("An error occurred. Please try again.");
    } finally {
      setState(() {
        isCreatingToken = false;
      });
    }
  }

  Widget _buildCardPreview() {
    return Container(
      height: 200.sdp,
      margin: EdgeInsets.symmetric(horizontal: 8.sdp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.greenlight, AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.sdp),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenlight.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.sdp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(
                  text: 'CREDIT CARD',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (cardType.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.sdp,
                      vertical: 6.sdp,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(15.sdp),
                    ),
                    child: TextView(
                      text: cardType,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Spacer(),
            TextView(
              text: cardNumberController.text.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _formatCardNumber(cardNumberController.text),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
            SizedBox(height: 24.sdp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'CARD HOLDER',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.sdp),
                    TextView(
                      text: cardHolderNameController.text.isEmpty
                          ? 'YOUR NAME'
                          : cardHolderNameController.text.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'EXPIRES',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.sdp),
                    TextView(
                      text: expiryDateController.text.isEmpty
                          ? 'MM/YY'
                          : expiryDateController.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += value[i];
    }
    return formatted;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sdp),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sdp),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sdp),
            borderSide: BorderSide(color: AppColors.greenlight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.sdp),
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.sdp,
            vertical: 20.sdp,
          ),
        ),
        validator: validator,
        onFieldSubmitted: (value) {
          if (focusNode == cardNumberFocus) {
            FocusScope.of(context).requestFocus(expiryDateFocus);
          } else if (focusNode == expiryDateFocus) {
            FocusScope.of(context).requestFocus(cvvFocus);
          } else if (focusNode == cvvFocus) {
            FocusScope.of(context).requestFocus(cardHolderNameFocus);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Add New Card',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            prefixImage: 'back',
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
          ),
          // Main content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.sdp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCardPreview(),
                      SizedBox(height: 32),

                      TextView(
                        text: 'Card Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20.sdp),
                      _buildCardField(),
                      // _addCard(),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: cardHolderNameController,
                        label: 'Cardholder Name',
                        focusNode: cardHolderNameFocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                        validator: (value) =>
                            (value?.trim().isNotEmpty ?? false)
                            ? null
                            : 'Enter cardholder name',
                      ),

                      SizedBox(height: 24),

                      Container(
                        padding: EdgeInsets.all(20.sdp),
                        decoration: BoxDecoration(
                          color: AppColors.greenlight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.sdp),
                          border: Border.all(
                            color: AppColors.greenlight.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: AppColors.greenlight,
                              size: 24,
                            ),
                            SizedBox(width: 16.sdp),
                            Expanded(
                              child: TextView(
                                text:
                                    'Your card information is encrypted and secure',
                                style: TextStyle(
                                  color: AppColors.greenlight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.sdp),

                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        child: AppButton(
                          radius: 25.sdp,
                          buttonColor: AppColors.greenlight,
                          label: isCreatingToken ? "Processing..." : "Add Card",
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          isFilledButton: true,
                          onTap: (isFormValid && !isCreatingToken)
                              ? _createStripeToken
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
