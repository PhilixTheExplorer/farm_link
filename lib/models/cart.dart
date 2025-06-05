import 'product.dart';

class CartItem {
  final String id;
  final int quantity;
  final DateTime createdAt;
  final Product product;

  const CartItem({
    required this.id,
    required this.quantity,
    required this.createdAt,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      product: Product.fromCartJson(json['products']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'product': product.toJson(),
    };
  }

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    String? id,
    int? quantity,
    DateTime? createdAt,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }
}

class CartSummary {
  final int itemCount;
  final double subtotal;
  final double total;

  const CartSummary({
    required this.itemCount,
    required this.subtotal,
    required this.total,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      itemCount: json['itemCount'],
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'itemCount': itemCount, 'subtotal': subtotal, 'total': total};
  }
}

class Cart {
  final List<CartItem> items;
  final CartSummary summary;

  const Cart({required this.items, required this.summary});
  factory Cart.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Cart(
      items:
          (data['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
      summary: CartSummary(
        itemCount: data['itemCount'] ?? 0,
        subtotal: (data['subtotal'] ?? 0).toDouble(),
        total: (data['total'] ?? 0).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;
  double get total => summary.total;

  Cart copyWith({List<CartItem>? items, CartSummary? summary}) {
    return Cart(items: items ?? this.items, summary: summary ?? this.summary);
  }
}
