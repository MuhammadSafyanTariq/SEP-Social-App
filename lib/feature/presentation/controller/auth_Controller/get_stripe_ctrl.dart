import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

import '../../../data/models/dataModels/TransactionListModel.dart';
import '../../../data/models/dataModels/get_card_model.dart';
import '../../../data/repository/iAuthRepository.dart';
import '../../../data/repository/payment_repo.dart';
import '../../../domain/respository/authRepository.dart';

class GetStripeCtrl extends GetxController {
  final AuthRepository _authRepository = IAuthRepository();
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  var cardList = <GetCardModel>[].obs;
  var selectedCardId = ''.obs;
  var isLoading = false.obs;

  var transactionList = <TransactionItem>[].obs;
  var isTransactionLoading = false.obs;

  Future<void> fetchCards() async {
    isLoading.value = true;

    try {
      AppUtils.log(
        "Fetching cards for user: ${profileCtrl.profileData.value.email ?? ""}",
      );

      var response = await PaymentRepo.getCardList();

      if (response.isSuccess) {
        cardList.value = response.data ?? [];
        selectedCardId.value = response.data?.firstOrNull?.id ?? '';
      } else {
        // Silently handle error - cards are optional for wallet-based payments
        AppUtils.log("Could not fetch cards: ${response.getError}");
      }
    } catch (e) {
      // Silently handle exception - cards are optional for wallet-based payments
      AppUtils.log("Exception while fetching cards: $e");
    } finally {
      isLoading.value = false;
    }

    //   if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
    //     cardList.value = response.data!;
    //     selectedCardId.value = response.data!.first.id;
    //     AppUtils.log("Card list fetched: ${cardList.length} cards.");
    //   } else {
    //     cardList.clear();
    //     selectedCardId.value = '';
    //     // AppUtils.toastError("Failed to fetch cards");
    //     AppUtils.log("Fetch failed: ${response.error ?? 'Unknown error'}");
    //   }
    // } catch (e, stacktrace) {
    //   // AppUtils.toastError("Error fetching cards");
    //   AppUtils.log("Exception while fetching cards: $e");
    //   AppUtils.log("Stacktrace: $stacktrace");
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> refreshCardList() async {
    AppUtils.log("Refreshing card list...");
    cardList.clear();
    selectedCardId.value = '';
    await fetchCards();
  }

  Future<void> removeCardLocally(String cardId) async {
    AppUtils.log("Attempting to delete card: $cardId");

    try {
      final response = await PaymentRepo.deleteCard(paymentMethodId: cardId);

      if (response.isSuccess) {
        cardList.removeWhere((card) => card.id == cardId);
        AppUtils.toast("Card removed");
        AppUtils.log("Card removed locally: $cardId");

        if (selectedCardId.value == cardId) {
          if (cardList.isNotEmpty) {
            selectedCardId.value = cardList.first.id;
          } else {
            selectedCardId.value = '';
          }
        }
      } else {
        AppUtils.toastError("Failed to delete card");
        AppUtils.log("Delete API failed: ${response.exception}");
      }
    } catch (e, stacktrace) {
      AppUtils.toastError("Error while deleting card");
      AppUtils.log("Exception during card deletion: $e");
      AppUtils.log("Stacktrace: $stacktrace");
    } finally {}
  }

  GetCardModel? get selectedCard {
    try {
      return cardList.firstWhere((c) => c.id == selectedCardId.value);
    } catch (_) {
      return null;
    }
  }

  Future<void> getTransactionList() async {
    isTransactionLoading.value = true;

    isTransactionLoading.value = false;
    // try {
    final response = await PaymentRepo.paymentTransactionList();

    if (response.isSuccess && response.data != null) {
      transactionList.value = response.data?.data ?? [];
      AppUtils.log(
        "Transaction list fetched: ${transactionList.length} items.",
      );
    } else {
      transactionList.clear();
      AppUtils.toastError("Failed to fetch transactions");
      AppUtils.log("Transaction fetch failed: ${response.error}");
    }
    // }
    //
    // catch (e, stacktrace) {
    //   AppUtils.toastError("Error fetching transactions");
    //   AppUtils.log("Exception while fetching transactions: $e");
    //   AppUtils.log("Stacktrace: $stacktrace");
    // }

    // finally {
    //   isTransactionLoading.value = false;
    // }
    isTransactionLoading.value = false;
  }

  Future<void> refreshTransactionList() async {
    AppUtils.log("Refreshing transaction list...");
    transactionList.clear();
    await getTransactionList();
  }

  Future<void> makePayment({
    required String amount,
    required String currency,
  }) async {
    final cardId = selectedCardId.value;
    var stripeCustomerId = profileCtrl.profileData.value.stripeCustomerId ?? "";

    if (cardId.isEmpty || stripeCustomerId.isEmpty) {
      final errorMsg = "Missing card or customer information";
      AppUtils.log("Payment validation failed: $errorMsg");
      throw Exception(errorMsg);
    }

    AppUtils.log(
      "Initiating payment for customer $stripeCustomerId with card $cardId",
    );

    try {
      var response = await PaymentRepo.payment(
        paymentMethodId: cardId,
        amount: amount,
        currency: currency,
        customerId: stripeCustomerId,
      );

      AppUtils.log(
        "Payment API Response: isSuccess=${response.isSuccess}, data=${response.data}, exception=${response.exception}",
      );

      // Helper function to check if payment is successful
      bool isPaymentSuccessful = false;
      String? successMessage;

      // Check response data first (if API response is successful)
      if (response.isSuccess && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        isPaymentSuccessful =
            responseData['statue'] == true ||
            responseData['status'] == true ||
            (responseData['message']?.toString().toLowerCase().contains(
                  'successful',
                ) ??
                false);
        successMessage = "Payment response: ${response.data}";
      }

      // If not successful via normal response, check if success data is in the exception
      if (!isPaymentSuccessful && response.exception != null) {
        final exceptionString = response.exception.toString();
        if (exceptionString.contains('"statue":true') ||
            exceptionString.contains('"status":true') ||
            exceptionString.toLowerCase().contains('payment successful')) {
          isPaymentSuccessful = true;
          successMessage =
              "Payment successful (from exception): $exceptionString";
        }
      }

      if (isPaymentSuccessful) {
        AppUtils.toast("Payment successful");
        AppUtils.log(successMessage ?? "Payment completed successfully");
        await getTransactionList();
        return; // Successfully completed
      }

      // If we reach here, payment genuinely failed
      final errorMsg = response.exception?.toString() ?? "Payment failed";
      AppUtils.log("Payment API error: $errorMsg");

      // Show user-friendly error message based on error type
      String userMessage = _getPaymentErrorMessage(errorMsg);
      AppUtils.toastError(userMessage);
      throw Exception(errorMsg);
    } catch (e, stacktrace) {
      AppUtils.log("Exception during payment: $e");
      AppUtils.log("Stacktrace: $stacktrace");

      // Check if the exception message indicates a successful payment
      final exceptionString = e.toString().toLowerCase();
      if (exceptionString.contains('payment successful') ||
          exceptionString.contains('"statue":true') ||
          exceptionString.contains('"status":true')) {
        AppUtils.toast("Payment successful");
        AppUtils.log(
          "Payment completed successfully (caught exception with success)",
        );
        try {
          await getTransactionList();
        } catch (transactionError) {
          AppUtils.log(
            "Error fetching transactions after successful payment: $transactionError",
          );
          // Don't fail the payment just because transaction list failed
        }
        return;
      }

      // Genuine error
      String userMessage = _getPaymentErrorMessage(e.toString());
      AppUtils.toastError(userMessage);
      if (e is! Exception) {
        throw Exception("Payment processing error: $e");
      }
      rethrow;
    }
  }

  Future<void> purchaseTokens({required double amount}) async {
    final userId = profileCtrl.profileData.value.id ?? "";

    if (userId.isEmpty) {
      AppUtils.toastError("User ID not found");
      throw Exception("User ID not found");
    }

    // Validate amount (minimum purchase)
    if (amount <= 0) {
      AppUtils.toastError("Invalid amount. Please enter a valid amount.");
      throw Exception("Invalid amount");
    }

    // Check if user has sufficient balance
    final currentBalance = profileCtrl.profileData.value.walletBalance ?? 0.0;
    if (currentBalance < amount) {
      AppUtils.toastError(
        "Insufficient balance. Please add funds to your wallet first.",
      );
      throw Exception("Insufficient balance");
    }

    AppUtils.log(
      "Initiating token purchase for user $userId with amount \$${amount}",
    );

    try {
      final response = await _authRepository.purchaseTokens(
        userId: userId,
        amount: amount,
      );

      AppUtils.log("API Response - Success: ${response.isSuccess}");
      AppUtils.log("API Response - Data: ${response.data}");
      AppUtils.log("API Response - Error: ${response.getError}");

      if (response.isSuccess) {
        AppUtils.log("Token purchase successful! Response: ${response.data}");

        // Refresh profile data to get updated token balance
        await profileCtrl.getProfileDetails();

        // Log the updated profile data after refresh
        final updatedProfile = profileCtrl.profileData.value;
        AppUtils.log(
          "After profile refresh - tokenBalance: ${updatedProfile.tokenBalance}, walletTokens: ${updatedProfile.walletTokens}",
        );

        // Refresh transaction list
        await getTransactionList();

        // Success - no need to throw
        return;
      } else {
        final errorMessage =
            response.getError?.toString() ?? "Failed to purchase tokens";
        AppUtils.log("Token purchase failed: $errorMessage");
        throw Exception(errorMessage);
      }
    } catch (e, stacktrace) {
      AppUtils.log("Exception during token purchase: $e");
      AppUtils.log("Stacktrace: $stacktrace");
      rethrow; // Re-throw to let packages screen handle the error
    }
  }

  // Method to deduct wallet balance for advertisement boosts
  Future<void> deductWalletForAdvertisement({
    required double amount,
    required String purpose,
  }) async {
    try {
      final userId = profileCtrl.profileData.value.id ?? "";

      if (userId.isEmpty) {
        AppUtils.toastError("User ID not found");
        throw Exception("User ID not found");
      }

      // Refresh profile to get latest balance
      await profileCtrl.getProfileDetails();

      // Check current wallet balance
      final currentProfile = profileCtrl.profileData.value;
      final currentBalance = (currentProfile.walletBalance ?? 0).toDouble();

      AppUtils.log(
        "Current wallet balance: \$${currentBalance}, Required amount: \$${amount}",
      );

      if (currentBalance < amount) {
        final errorMsg =
            "Insufficient wallet balance. You have \$${currentBalance.toStringAsFixed(2)} but need \$${amount.toStringAsFixed(2)}. Please add funds to your wallet first.";
        AppUtils.toastError(errorMsg);
        throw Exception("Insufficient wallet balance");
      }

      AppUtils.log(
        "Attempting to deduct \$${amount} from wallet for $purpose (User: $userId)",
      );

      // For now, let's simulate wallet deduction by directly updating the balance
      // This is a temporary solution until the proper API endpoint is available
      final response = await PaymentRepo.deductWalletBalance(
        userId: userId,
        amount: amount,
        purpose: purpose,
      );

      AppUtils.log(
        "Wallet deduction API Response - Success: ${response.isSuccess}",
      );

      if (response.isSuccess) {
        AppUtils.log("Wallet deduction successful!");

        // Refresh profile data to get updated wallet balance
        await profileCtrl.getProfileDetails();

        // Log the updated profile data after refresh
        final updatedProfile = profileCtrl.profileData.value;
        AppUtils.log(
          "After wallet deduction - walletBalance: ${updatedProfile.walletBalance}",
        );

        // Refresh transaction list to show the deduction
        try {
          await getTransactionList();
        } catch (e) {
          AppUtils.log("Failed to refresh transaction list: $e");
          // Don't fail the whole operation if transaction refresh fails
        }

        AppUtils.toast(
          "Successfully deducted \$${amount.toStringAsFixed(2)} for $purpose",
        );
        return;
      } else {
        final errorMessage =
            response.error?.toString() ?? "Failed to deduct from wallet";
        AppUtils.log("Wallet deduction failed: $errorMessage");
        AppUtils.toastError("Wallet deduction failed. Please try again.");
        throw Exception(errorMessage);
      }
    } catch (e, stacktrace) {
      AppUtils.log("Exception during wallet deduction: $e");
      AppUtils.log("Stacktrace: $stacktrace");

      // Show user-friendly error message
      if (!e.toString().contains("Insufficient wallet balance")) {
        AppUtils.toastError(
          "Failed to process wallet deduction. Please try again.",
        );
      }

      rethrow; // Re-throw to let caller handle the error
    }
  }

  /// Helper method to convert payment error messages into user-friendly text
  String _getPaymentErrorMessage(String errorMsg) {
    final errorLower = errorMsg.toLowerCase();

    // Minimum amount errors
    if (errorLower.contains('minimum charge amount') ||
        errorLower.contains('amount must be greater')) {
      return "Amount too small. Minimum charge is \$0.50 for USD.";
    }

    // Card declined errors
    if (errorLower.contains('card was declined') ||
        errorLower.contains('card declined')) {
      if (errorLower.contains('insufficient') || errorLower.contains('funds')) {
        return "Insufficient funds. Please use a different card or add funds.";
      }
      if (errorLower.contains('expired')) {
        return "Your card has expired. Please use a different card.";
      }
      if (errorLower.contains('lost') || errorLower.contains('stolen')) {
        return "This card cannot be used. Please use a different card.";
      }
      return "Your card was declined. Please try a different card.";
    }

    // Authentication/verification errors
    if (errorLower.contains('authentication') ||
        errorLower.contains('verify') ||
        errorLower.contains('3d secure')) {
      return "Card verification failed. Please try again or use a different card.";
    }

    // Processing errors
    if (errorLower.contains('processing error') ||
        errorLower.contains('unable to process')) {
      return "Unable to process payment. Please try again.";
    }

    // Network/timeout errors
    if (errorLower.contains('timeout') ||
        errorLower.contains('network') ||
        errorLower.contains('connection')) {
      return "Connection error. Please check your internet and try again.";
    }

    // Invalid card errors
    if (errorLower.contains('invalid card') ||
        errorLower.contains('incorrect number') ||
        errorLower.contains('incorrect cvc')) {
      return "Invalid card details. Please check and try again.";
    }

    // Generic payment failed
    return "Payment failed. Please try again or use a different card.";
  }
}
