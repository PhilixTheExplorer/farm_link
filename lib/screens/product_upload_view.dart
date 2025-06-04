import 'package:flutter/material.dart';
import 'product_form_view.dart';

class ProductUploadView extends StatelessWidget {
  const ProductUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the shared form view in create mode (product = null)
    return const ProductFormView(product: null);
  }
}
