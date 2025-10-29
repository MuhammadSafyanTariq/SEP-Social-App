class TransactionListModel {
   List<TransactionItem>? data;

  TransactionListModel({required this.data});

  factory TransactionListModel.fromJson(Map<String, dynamic> json) {
    return TransactionListModel(
      data: (json['data'] as List)
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }
}

class TransactionItem {
   String? id;
   String? userId;
   String? type;
   num? amount;
   num? balanceAfter;
   String? relatedOrderId;
   String? stripePaymentId;
   String? description;
   String? createdAt;

  TransactionItem({
     this.id,
     this.userId,
     this.type,
     this.amount,
     this.balanceAfter,
     this.relatedOrderId,
     this.stripePaymentId,
     this.description,
     this.createdAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['_id'],
      userId: json['userId'],
      type: json['type'],
      amount: json['amount'],
      balanceAfter: json['balance_after'],
      relatedOrderId: json['related_order_id'],
      stripePaymentId: json['stripe_payment_id'],
      description: json['description'],
      createdAt: json['createdAt'],
    );
  }
}
