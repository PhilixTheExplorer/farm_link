import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_service.dart';

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get orders with filters
  Future<List<Order>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? farmerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getOrders(
        page: page,
        limit: limit,
        status: status,
        farmerId: farmerId,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> ordersData = response['data']['orders'];
        final orders =
            ordersData.map((json) => _createOrderFromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return orders;
      }
    } catch (e) {
      debugPrint('Get orders error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.getOrderById(orderId);

      if (response != null && response['success'] == true) {
        return _createOrderFromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Get order by ID error: $e');
    }
    return null;
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.updateOrderStatus(orderId, status);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Update order status error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update payment status (Admin only)
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      return await _apiService.updatePaymentStatus(orderId, paymentStatus);
    } catch (e) {
      debugPrint('Update payment status error: $e');
      return false;
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>?> getOrderStats() async {
    try {
      final response = await _apiService.getOrderStats();

      if (response != null && response['success'] == true) {
        return response['data'];
      }
    } catch (e) {
      debugPrint('Get order stats error: $e');
    }
    return null;
  }

  // Get orders for current user (buyer perspective)
  Future<List<Order>> getMyOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await getOrders(page: page, limit: limit, status: status);
  }

  // Get orders for farmer (farmer perspective)
  Future<List<Order>> getFarmerOrders(
    String farmerId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await getOrders(
      page: page,
      limit: limit,
      status: status,
      farmerId: farmerId,
    );
  }

  // Helper method to create Order object from JSON
  Order _createOrderFromJson(Map<String, dynamic> json) {
    // Parse order items
    final List<dynamic> itemsData = json['items'] ?? [];
    final List<OrderItem> items =
        itemsData.map((itemJson) {
          return OrderItem(
            id: itemJson['id'],
            productId: itemJson['product_id'],
            product: Product.fromJson(itemJson['product']),
            quantity: itemJson['quantity'],
            price: (itemJson['price'] ?? 0).toDouble(),
          );
        }).toList();

    return Order(
      id: json['id'],
      buyerId: json['buyer_id'],
      items: items,
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
  OrderStatus _parseOrderStatus(String? status) {
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

  PaymentStatus _parsePaymentStatus(String? status) {
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

  // Get order status display text
  String getOrderStatusText(OrderStatus status) {
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

  // Get payment status display text
  String getPaymentStatusText(PaymentStatus status) {
    switch (status) {
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

  // Format order amount
  String formatAmount(double amount) {
    return '฿${amount.toStringAsFixed(0)}';
  }

  // Check if order can be cancelled
  bool canCancelOrder(Order order) {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed;
  }

  // Check if order can be updated by farmer
  bool canUpdateOrder(Order order) {
    return order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
  }
}
