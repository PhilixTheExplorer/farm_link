import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../theme/app_colors.dart';

class ProductUploadView extends StatefulWidget {
  const ProductUploadView({Key? key}) : super(key: key);

  @override
  State<ProductUploadView> createState() => _ProductUploadViewState();
}

class _ProductUploadViewState extends State<ProductUploadView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  
  String _selectedCategory = 'Vegetables';
  bool _isLoading = false;
  String? _imageUrl;
  
  // Sample categories
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Rice',
    'Handmade',
    'Organic',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _pickImage() {
    // Simulate image picking
    setState(() {
      _imageUrl = 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80';
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product image')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product uploaded successfully!'),
            backgroundColor: AppColors.ricePaddyGreen,
          ),
        );
        
        // Navigate back to farmer dashboard
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                      image: _imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: AppColors.palmAshGray,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add product image',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.palmAshGray,
                                ),
                              ),
                            ],
                          )
                        : null,
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
              
              // Quantity
              ThaiTextField(
                label: 'Quantity Available',
                hintText: 'Enter available quantity',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.inventory_2_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
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
                label: 'Upload Product',
                onPressed: _handleSubmit,
                variant: ThaiButtonVariant.secondary,
                icon: Icons.upload,
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
