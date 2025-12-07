import 'package:sep/feature/data/models/dataModels/bank_detail/bank_detail.dart';
import 'package:sep/utils/appUtils.dart';

import '../../../services/networking/apiMethods.dart';
import '../../../services/storage/preferences.dart';
import '../../presentation/controller/auth_Controller/profileCtrl.dart';
import '../models/dataModels/TransactionListModel.dart';
import '../models/dataModels/get_card_model.dart';
import '../models/dataModels/profile_data/profile_data_model.dart';
import '../models/dataModels/responseDataModel.dart';
import '../../../services/networking/urls.dart';

class PaymentRepo {
  static final IApiMethod _apiMethod = IApiMethod();

  static Future<ResponseData<ProfileDataModel>> createAccountStripe({
    required String email,
  }) async {
    final body = {'email': email};

    final response = await _apiMethod.post(
      url: Urls.createAccountStripe,
      body: body,
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future<ResponseData<TransactionListModel>>
  paymentTransactionList() async {
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.get(
      url: Urls.paymentTransactionList,
      headers: {'Content-Type': 'application/json'},
      query: {"userId": Preferences.uid ?? ""},
    );

    AppUtils.log('API Response: ${response.data}');

    if (response.isSuccess && response.data != null) {
      final transactionList = TransactionListModel.fromJson(response.data!);
      return ResponseData<TransactionListModel>(
        isSuccess: true,
        data: transactionList,
      );
    } else {
      AppUtils.log('Response data is null or API call failed');
      return ResponseData<TransactionListModel>(
        isSuccess: false,
        error: Exception('Failed to load transaction list'),
      );
    }
  }

  static Future<ResponseData<Map<String, dynamic>>> deleteCard({
    required String paymentMethodId,
  }) async {
    final result = await _apiMethod.delete(
      url: Urls.deleteCard,
      body: {'paymentMethodId': paymentMethodId},
    );

    if (result.isSuccess) {
      return ResponseData(isSuccess: true, data: result.data);
    } else {
      return ResponseData(isSuccess: false, exception: result.getError);
    }
  }

  static Future<ResponseData<Map<String, dynamic>>> payment({
    required String paymentMethodId,
    required String amount,
    required String currency,
    required String customerId,
  }) async {
    final result = await _apiMethod.post(
      url: Urls.payment,
      body: {
        'customerId': customerId,
        "paymentMethodId": paymentMethodId,
        "amount": amount,
        "currency": currency,
        "userId": Preferences.uid ?? "",
      },
      headers: {},
    );

    if (result.isSuccess) {
      return ResponseData(isSuccess: true, data: result.data);
    } else {
      return ResponseData(isSuccess: false, exception: result.getError);
    }
  }

  static Future<ResponseData<ProfileDataModel>> token({
    required String customerId,
    required String paymentMethodId,
  }) async {
    final body = {'customerId': customerId, "paymentMethodId": paymentMethodId};

    final response = await _apiMethod.post(
      url: Urls.token,
      body: body,
      headers: {},
    );
    if (response.isSuccess == true && response.data != null) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future<ResponseData<List<GetCardModel>>> getCardList() async {
    final body = {'email': ProfileCtrl.find.profileData.value.email ?? ""};

    final response = await _apiMethod.get(
      url: Urls.getCardList,
      body: body,
      headers: {},
      query: {
        "customerId": ProfileCtrl.find.profileData.value.stripeCustomerId ?? "",
      },
    );

    if (response.isSuccess) {
      try {
        if (response.data is Map && response.data?['data'] is List) {
          final cardList = (response.data?['data'] as List)
              .map((e) => GetCardModel.fromJson(e))
              .toList();

          return ResponseData(isSuccess: true, data: cardList);
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception(
              "Expected a list in 'data', got ${response.data.runtimeType}",
            ),
          );
        }
      } catch (e) {
        return ResponseData(
          isSuccess: false,
          error: Exception("Parsing error: $e"),
        );
      }
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future topUpWallet({required String amount}) async {
    final response = await _apiMethod.post(
      url: Urls.topUpWallet,
      body: {"userId": Preferences.uid, "amount": amount},
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  // Method to deduct wallet balance for advertisement boosts
  static Future<ResponseData<Map<String, dynamic>>> deductWalletBalance({
    required String userId,
    required double amount,
    required String purpose,
  }) async {
    try {
      AppUtils.log(
        "Deducting wallet balance - UserId: $userId, Amount: \$${amount}, Purpose: $purpose",
      );

      // Use the new simplified deduct balance endpoint
      final response = await _apiMethod.post(
        url: Urls.deductBalance,
        authToken: Preferences.authToken,
        body: {"userId": userId, "amount": amount},
        headers: {'Content-Type': 'application/json'},
      );

      AppUtils.log("Wallet deduction API response: ${response.toJson()}");

      if (response.isSuccess) {
        AppUtils.log("Wallet balance deducted successfully");
        return ResponseData(isSuccess: true, data: response.data ?? {});
      } else {
        AppUtils.log("Wallet deduction failed: ${response.error}");
        return ResponseData(
          isSuccess: false,
          error: response.error ?? Exception("Wallet deduction failed"),
        );
      }
    } catch (e) {
      AppUtils.log("Exception in deductWalletBalance: $e");
      return ResponseData(
        isSuccess: false,
        error: Exception("Error processing wallet deduction: $e"),
      );
    }
  }

  static Future createBankAccountToken({required BankDetail data}) async {
    final response = await _apiMethod.post(
      url: Urls.createBankAccountToken,
      body: data.toJson(),
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future payoutToBank() async {
    final response = await _apiMethod.post(
      url: Urls.payoutToBank,
      body: {
        "connectedAccountId": "acct_1S3yS4F8kt4qvS8T",
        "amount": "20",
        "userIpAddress": "223.178.210.55",
        "userId": Preferences.uid,
      },
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future addBankAccountToCustomer() async {
    final response = await _apiMethod.post(
      url: Urls.addBankAccountToCustomer,
      body: {
        "customerId": "cus_Szs519tMB4Zgta",
        "bankAccountToken": "btok_1S3uVlQHPe7BrzsMWMQl3Hzr",
      },
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future addBankAccountToConnectedAccount() async {
    final response = await _apiMethod.post(
      url: Urls.addBankAccountToConnectedAccount,
      body: {
        "connectedAccountId": "acct_1S3sLg6Es323Sgg8",
        "bankAccountToken": "btok_1S3uZPQHPe7BrzsMAQcUITkS",
      },
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future getExternalBankAccounts() async {
    final response = await _apiMethod.get(
      url: Urls.getExternalBankAccounts,
      query: {'connectedAccountId': 'acct_1S3sLg6Es323Sgg8'},
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future createAccountLink() async {
    final response = await _apiMethod.post(
      url: Urls.createAccountLink,
      body: {
        "connectedAccountId": "acct_1S3sLg6Es323Sgg8",
        "userId": Preferences.uid,
      },
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  static Future topUpAccount() async {
    final response = await _apiMethod.post(
      url: Urls.topUpAccount,
      body: {
        "amount": "2000",
        "currency": "usd",
        "description": "Top-up for week of May 31",
        "statement_descriptor": "Weekly top-up",
      },
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ProfileDataModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }
}
