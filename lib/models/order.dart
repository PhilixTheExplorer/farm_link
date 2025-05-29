enum OrderStatus { pending, confirmed, preparing, ready, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productTitle;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productTitle: json['productTitle'],
      quantity: json['quantity'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
    };
  }
}

class Order {
  final String id;
  final String buyerId;
  final String buyerName;
  final String farmerId;
  final String farmerName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String? notes;
  final double? rating; // Buyer's rating for this order
  final String? review; // Buyer's review

  Order({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    this.notes,
    this.rating,
    this.review,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate:
          json['deliveryDate'] != null
              ? DateTime.parse(json['deliveryDate'])
              : null,
      deliveryAddress: json['deliveryAddress'],
      notes: json['notes'],
      rating: json['rating']?.toDouble(),
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'rating': rating,
      'review': review,
    };
  }

  Order copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? farmerId,
    String? farmerName,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? deliveryAddress,
    String? notes,
    double? rating,
    String? review,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  // Helper getters
  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
