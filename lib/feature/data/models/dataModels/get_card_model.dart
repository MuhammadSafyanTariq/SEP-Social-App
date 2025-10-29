class GetCardModel {
  final String id;
  final BillingDetails billingDetails;
  final CardDetails card;
  final int created;

  GetCardModel({
    required this.id,
    required this.billingDetails,
    required this.card,
    required this.created,
  });

  factory GetCardModel.fromJson(Map<String, dynamic> json) {
    return GetCardModel(
      id: json['id'] ?? '',
      billingDetails: BillingDetails.fromJson(json['billing_details'] ?? {}),
      card: CardDetails.fromJson(json['card'] ?? {}),
      created: json['created'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billing_details': billingDetails.toJson(),
      'card': card.toJson(),
      'created': created,
    };
  }
}

class BillingDetails {
  final String? name;
  // You can add other fields like email, phone, address, etc. here if needed

  BillingDetails({this.name});

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CardDetails {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  CardDetails({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      brand: json['brand'] ?? 'Unknown',
      last4: json['last4'] ?? '',
      expMonth: json['exp_month'] ?? 1,
      expYear: json['exp_year'] ?? 1970,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
    };
  }
}
