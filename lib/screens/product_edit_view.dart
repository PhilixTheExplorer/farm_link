import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_form_view.dart';

class ProductEditView extends StatelessWidget {
  final Product product;

  const ProductEditView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Use the shared form view in edit mode
    return ProductFormView(product: product);
  }
}
