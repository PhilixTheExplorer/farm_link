import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentStatus { pending, paid, failed, refunded }

class OrderItem {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final double price; // price at time of order

  OrderItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime createdDate;
  final DateTime updatedDate;

  Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.notes,
    required this.createdDate,
    required this.updatedDate,
  });

  // Get unique farmers from order items
  List<String> get farmerIds {
    return items.map((item) => item.product.farmerId).toSet().toList();
  }

  // Get total items count
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyer_id'],
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      deliveryAddress: json['delivery_address'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'],
      createdDate: DateTime.parse(json['created_at']),
      updatedDate:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.parse(json['created_at']),
    );
  }

  // Helper methods to parse enums
  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': _statusToString(status),
      'payment_status': _paymentStatusToString(paymentStatus),
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdDate.toIso8601String(),
      'updated_at': updatedDate.toIso8601String(),
    };
  }

  // Helper methods to convert enums to strings
  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String _paymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }

  Order copyWith({
    String? id,
    String? buyerId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? deliveryAddress,
    String? paymentMethod,
    String? notes,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
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
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  bool get isCancelled {
    return status == OrderStatus.cancelled;
  }

  // Format total amount
  String get formattedTotal {
    return '฿${totalAmount.toStringAsFixed(0)}';
  }
}
