import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sep/components/appLoader.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/presentation/wallet/add_new_card.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import 'PaymentScreen.dart';
import 'paypal_topup_screen.dart';

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

  String get maskedCardNumber {
    String cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.length < 4) return cardNumber;
    return '**** **** **** ${cleanNumber.substring(cleanNumber.length - 4)}';
  }
}

class AddCreditCardScreen extends StatefulWidget {
  @override
  _AddCreditCardScreenState createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  final GetStripeCtrl stripeCtrl = Get.put(GetStripeCtrl());

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stripeCtrl.fetchCards();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToAddNewCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewCard(
          onCardAdded: (_) {
            stripeCtrl.refreshCardList();
          },
        ),
      ),
    );
  }

  void _deleteCard(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Delete Card'),
          ],
        ),
        content: Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await stripeCtrl.removeCardLocally(cardId);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCardsList() {
    return Obx(() {
      final cardModels = stripeCtrl.cardList;

      List<Widget> content = [];

      content.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sdp, vertical: 2.sdp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 130.sdp,
                height: 44.sdp,
                child: AppButton(
                  radius: 18.sdp,
                  buttonColor: AppColors.greenlight,
                  label: "+ Add New Card",
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  isFilledButton: true,
                  onTap: _navigateToAddNewCard,
                ),
              ),
            ],
          ),
        ),
      );
      if (stripeCtrl.isLoading.value) {
        content.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: AppLoader.loaderWidget(),
            ),
          ),
        );
      } else if (cardModels.isEmpty) {
        content.add(
          Container(
            margin: EdgeInsets.all(24.sdp),
            padding: EdgeInsets.all(32.sdp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.sdp),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.sdp),
                  decoration: BoxDecoration(
                    color: AppColors.greenlight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card_off,
                    size: 48.sdp,
                    color: AppColors.greenlight,
                  ),
                ),
                SizedBox(height: 20.sdp),
                TextView(
                  text: 'No payment methods added',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.sdp),
                TextView(
                  text: 'Add your first payment method to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        );
      } else {
        List<CreditCard> cards = cardModels.map((card) {
          return CreditCard(
            id: card.id,
            cardNumber: '**** **** **** ${card.card.last4}',
            expiryDate:
                '${card.card.expMonth.toString().padLeft(2, '0')}/${card.card.expYear.toString().substring(2)}',
            cardHolderName: card.card.brand,
            cardType: card.card.brand,
            dateAdded: DateTime.fromMillisecondsSinceEpoch(card.created * 1000),
          );
        }).toList();

        content.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 12.sdp),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.greenlight, size: 20),
                SizedBox(width: 8.sdp),
                TextView(
                  text: 'Saved Cards (${cards.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );

        content.add(
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return Obx(() {
                final isSelected = stripeCtrl.selectedCardId.value == card.id;

                return GestureDetector(
                  onTap: () {
                    stripeCtrl.selectedCardId.value = card.id;
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.sdp,
                      vertical: 8.sdp,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.greenlight.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.greenlight
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16.sdp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildCardListItem(card),
                  ),
                );
              });
            },
          ),
        );
        content.add(
          Padding(
            padding: EdgeInsets.all(16.sdp),
            child: AppButton(
              radius: 20.sdp,
              buttonColor: AppColors.greenlight,
              label: "Top Up Wallet with PayPal",
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              isFilledButton: true,
              onTap: () async {
                final userId = Preferences.uid ?? "";
                if (userId.isEmpty) {
                  AppUtils.toastError("User ID not found");
                  return;
                }
                await context.pushNavigator(
                  PayPalTopUpScreen(
                    userId: userId,
                    onBalanceUpdated: (newBalance) {
                      // Refresh profile when balance updates
                      ProfileCtrl.find.getProfileDetails();
                    },
                  ),
                );
                // Refresh after returning
                ProfileCtrl.find.getProfileDetails();
              },
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      );
    });
  }

  Widget _buildCardListItem(CreditCard card) {
    return Padding(
      padding: EdgeInsets.all(16.sdp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Type Icon
          Container(
            width: 48.sdp,
            height: 32.sdp,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getCardGradient(card.cardType),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.sdp),
            ),
            child: Center(
              child: TextView(
                text: _getCardIcon(card.cardType),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.sdp),

          // Card Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextView(
                  text: card.maskedCardNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.sdp),
                Text(
                  card.cardHolderName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.sdp),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextView(
                        text: 'Expires ${card.expiryDate}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 8.sdp),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.sdp,
                        vertical: 2.sdp,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenlight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.sdp),
                        border: Border.all(
                          color: AppColors.greenlight.withOpacity(0.3),
                        ),
                      ),
                      child: TextView(
                        text: card.cardType.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.greenlight,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.sdp),

          // Menu Button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.sdp),
            ),
            onSelected: (value) {
              if (value == 'delete') _deleteCard(context, card.id);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8.sdp),
                    TextView(
                      text: 'Delete Card',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getCardGradient(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return [Color(0xFF1A237E), Color(0xFF3949AB)];
      case 'mastercard':
        return [Color(0xFFE65100), Color(0xFFFF9800)];
      case 'american express':
        return [Color(0xFF006064), Color(0xFF00ACC1)];
      case 'discover':
        return [Color(0xFF4A148C), Color(0xFF7B1FA2)];
      default:
        return [Color(0xFF667eea), Color(0xFF764ba2)];
    }
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'american express':
        return 'AMEX';
      case 'discover':
        return 'DISC';
      default:
        return 'CARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Payment Methods',
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
                  padding: EdgeInsets.all(16.sdp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_buildSavedCardsList()],
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
