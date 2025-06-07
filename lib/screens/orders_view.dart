import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  bool _isLoading = true;
  List<Order> _orders = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    // This would be replaced with an actual API call in a real implementation
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data based on the API response format from the prompt
      final mockOrders = [
        Order(
          id: "9b2ef8a3-6f0d-4e42-8026-a8ba22a77c12",
          buyerId: "user-123",
          items: [
            OrderItem(
              id: "item-1",
              productId: "prod-1",
              product: Product(
                id: "prod-1",
                title: "Fresh Tomatoes",
                description: "Organic tomatoes",
                price: 12.50,
                imageUrl:
                    "https://i.ytimg.com/vi/rvX8cS-v2XM/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCF0zNNCUpNmTYhJxWG7VWjmvmybA",
                unit: "kg",
                farmerId: "farmer-1",
                quantity: 10,
                category: ProductCategory.vegetables,
                createdDate: DateTime.now(),
              ),
              quantity: 2,
              price: 12.50,
            ),
          ],
          totalAmount: 25.00,
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.pending,
          deliveryAddress: "123 Main St, City",
          paymentMethod: "cash_on_delivery",
          createdDate: DateTime.now().subtract(const Duration(days: 2)),
          updatedDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Order(
          id: "7a1ef8c5-5e9d-3b42-7027-b7ca11a66b23",
          buyerId: "user-123",
          items: [
            OrderItem(
              id: "item-2",
              productId: "prod-2",
              product: Product(
                id: "prod-2",
                title: "Fresh Apples",
                description: "Organic apples",
                price: 8.25,
                imageUrl:
                    "https://i.ytimg.com/vi/rvX8cS-v2XM/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCF0zNNCUpNmTYhJxWG7VWjmvmybA",
                unit: "kg",
                farmerId: "farmer-2",
                quantity: 20,
                category: ProductCategory.fruits,
                createdDate: DateTime.now(),
              ),
              quantity: 3,
              price: 8.25,
            ),
            OrderItem(
              id: "item-3",
              productId: "prod-3",
              product: Product(
                id: "prod-3",
                title: "Honey",
                description: "Pure honey",
                price: 15.00,
                imageUrl:
                    "https://i.ytimg.com/vi/rvX8cS-v2XM/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCF0zNNCUpNmTYhJxWG7VWjmvmybA",
                unit: "bottle",
                farmerId: "farmer-3",
                quantity: 5,
                category: ProductCategory.dairy,
                createdDate: DateTime.now(),
              ),
              quantity: 1,
              price: 15.00,
            ),
          ],
          totalAmount: 39.75,
          status: OrderStatus.confirmed,
          paymentStatus: PaymentStatus.paid,
          deliveryAddress: "456 Oak St, City",
          paymentMethod: "credit_card",
          createdDate: DateTime.now().subtract(const Duration(days: 5)),
          updatedDate: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];

      setState(() {
        _orders = mockOrders;
        _isLoading = false;
        _totalPages = 1; // Mock value
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch orders. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                : _orders.isEmpty
                ? const Center(child: Text('No orders found. Start shopping!'))
                : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(context, order);
                        },
                      ),
                    ),
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  _currentPage > 1
                                      ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                        _fetchOrders();
                                      }
                                      : null,
                            ),
                            Text(
                              'Page $_currentPage of $_totalPages',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed:
                                  _currentPage < _totalPages
                                      ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                        _fetchOrders();
                                      }
                                      : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Use router to navigate to order details
          context.push('/order-detail', extra: order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Placed on ${DateFormat('MMM dd, yyyy').format(order.createdDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Text('${order.totalItems} items'),
                  const Spacer(),
                  Text(
                    'B${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOrderItemsPreview(order),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment: ${_formatPaymentMethod(order.paymentMethod)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Status: ${order.paymentStatus.name[0].toUpperCase() + order.paymentStatus.name.substring(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPaymentStatusColor(order.paymentStatus),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemsPreview(Order order) {
    final maxItems = 2;
    final displayedItems = order.items.take(maxItems).toList();
    final remainingItems = order.items.length - maxItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayedItems.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage(item.product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.quantity} × ${item.product.title}',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'B${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        if (remainingItems > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ $remainingItems more item${remainingItems > 1 ? 's' : ''}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        break;
      case OrderStatus.preparing:
        color = Colors.indigo;
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    // Convert snake_case to Title Case
    return method
        .split('_')
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }
}
