import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../core/theme/app_colors.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../viewmodels/farmer_dashboard_viewmodel.dart';
import '../core/di/service_locator.dart';

class ProductEditView extends StatefulWidget {
  final Product product;

  const ProductEditView({super.key, required this.product});

  @override
  State<ProductEditView> createState() => _ProductEditViewState();
}

class _ProductEditViewState extends State<ProductEditView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;

  final ProductService _productService = serviceLocator<ProductService>();
  final UserService _userService = serviceLocator<UserService>();

  late String _selectedCategory;
  late String _selectedQuantityUnit;
  bool _isLoading = false;
  late String _imageUrl;

  // Backend compatible categories
  final List<String> _categories = [
    'vegetables',
    'fruits',
    'rice',
    'herbs',
    'handmade',
    'dairy',
    'meat',
    'other',
  ];

  // Backend compatible category display names
  final Map<String, String> _categoryDisplayNames = {
    'vegetables': 'Vegetables',
    'fruits': 'Fruits',
    'rice': 'Rice',
    'herbs': 'Herbs',
    'handmade': 'Handmade',
    'dairy': 'Dairy',
    'meat': 'Meat',
    'other': 'Other',
  };

  // Quantity units
  final List<String> _quantityUnits = [
    'kg',
    'g',
    'pcs',
    'pack',
    'bag',
    'box',
    'bottle',
    'bunch',
    'dozen',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );

    // Initialize dropdowns with existing values
    _selectedCategory = widget.product.category.toString().split('.').last;
    _selectedQuantityUnit = widget.product.unit;
    _imageUrl = widget.product.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _pickImage() {
    // For now, provide sample images based on category
    final sampleImages = {
      'vegetables':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
      'fruits':
          'https://images.unsplash.com/photo-1557844352-761f2565b576?w=400',
      'rice':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      'herbs':
          'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=400',
      'handmade':
          'https://images.unsplash.com/photo-1505236732187-3d0d5c5e5daf?w=400',
      'dairy':
          'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=400',
      'meat':
          'https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=400',
      'other':
          'https://images.unsplash.com/photo-1601599561213-832382fd07ba?w=400',
    };

    setState(() {
      _imageUrl =
          sampleImages[_selectedCategory] ?? sampleImages['vegetables']!;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get current farmer ID from user service
        final currentUser = _userService.currentUser;
        if (currentUser == null ||
            _userService.currentUserRole != UserRole.farmer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You must be logged in as a farmer to edit products',
              ),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Create updated product
        final updatedProduct = Product(
          id: widget.product.id,
          farmerId: widget.product.farmerId,
          title: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: ProductCategory.values.firstWhere(
            (e) => e.toString().split('.').last == _selectedCategory,
          ),
          quantity: int.parse(_quantityController.text),
          unit: _selectedQuantityUnit,
          imageUrl: _imageUrl,
          status: widget.product.status,
          createdDate: widget.product.createdDate,
          lastUpdated: DateTime.now(),
          orderCount: widget.product.orderCount,
        );

        print('Updating product: ${updatedProduct.toJson()}');

        // Call API to update product
        final success = await _productService.updateProduct(updatedProduct);

        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: AppColors.ricePaddyGreen,
            ),
          );

          // Notify the dashboard to refresh
          serviceLocator<FarmerDashboardViewModel>().onProductUploaded();

          // Navigate back
          context.pop();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update product. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        print('Error updating product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.bambooCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.palmAshGray.withOpacity(0.3),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(_imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change image',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product Name
              ThaiTextField(
                label: 'Product Name',
                hintText: 'Enter product name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price
              ThaiTextField(
                label: 'Price (THB)',
                hintText: 'Enter price per unit',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_exchange,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Quantity with Unit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Quantity Available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Quantity input field
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter quantity',
                            prefixIcon: const Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.palmAshGray,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.bambooCream,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            errorStyle: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Unit dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bambooCream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.palmAshGray.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedQuantityUnit,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              style: theme.textTheme.bodyMedium,
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedQuantityUnit = value;
                                  });
                                }
                              },
                              items:
                                  _quantityUnits.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Category',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bambooCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.palmAshGray.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        elevation: 16,
                        style: theme.textTheme.bodyMedium,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        items:
                            _categories.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  _categoryDisplayNames[value] ?? value,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              ThaiTextField(
                label: 'Description',
                hintText: 'Enter product description',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              ThaiButton(
                label: 'Update Product',
                onPressed: _handleSubmit,
                variant: ThaiButtonVariant.secondary,
                icon: Icons.save,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
