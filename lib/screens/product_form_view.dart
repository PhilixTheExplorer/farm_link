import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../components/image_picker_components.dart';
import '../core/theme/app_colors.dart';
import '../models/product.dart';
import '../viewmodels/product_form_viewmodel.dart';

class ProductFormView extends StatefulWidget {
  final Product? product; // null for create mode, non-null for edit mode

  const ProductFormView({super.key, this.product});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  late final ProductFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductFormViewModel();

    // Initialize viewmodel based on mode
    if (widget.product != null) {
      _viewModel.initializeForEdit(widget.product!);
    } else {
      _viewModel.initializeForCreate();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.submitForm();

      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _viewModel.isCreateMode
                    ? 'Product added successfully!'
                    : 'Product updated successfully!',
              ),
              backgroundColor: AppColors.ricePaddyGreen,
            ),
          );

          // Navigate back
          context.pop();
        } else {
          // Show error message
          String errorMessage =
              _viewModel.errorMessage ??
              'Failed to ${_viewModel.isCreateMode ? 'add' : 'update'} product. Please try again.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.chilliRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.formTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  _buildImagePicker(theme),

                  const SizedBox(height: 24),

                  // Product Name
                  ThaiTextField(
                    label: 'Product Name',
                    hintText: 'Enter product name',
                    controller: _viewModel.nameController,
                    validator: _viewModel.validateName,
                  ),

                  const SizedBox(height: 16),

                  // Price
                  ThaiTextField(
                    label: 'Price (THB)',
                    hintText: 'Enter price per unit',
                    controller: _viewModel.priceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.currency_exchange,
                    validator: _viewModel.validatePrice,
                  ),

                  const SizedBox(height: 16),

                  // Quantity with Unit
                  _buildQuantitySection(theme),

                  const SizedBox(height: 16),

                  // Category Dropdown
                  _buildCategorySection(theme),

                  const SizedBox(height: 16),

                  // Description
                  ThaiTextField(
                    label: 'Description',
                    hintText: 'Enter product description',
                    controller: _viewModel.descriptionController,
                    maxLines: 4,
                    validator: _viewModel.validateDescription,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  ThaiButton(
                    label: _viewModel.submitButtonText,
                    onPressed: _handleSubmit,
                    variant: ThaiButtonVariant.secondary,
                    icon: _viewModel.submitButtonIcon,
                    isLoading: _viewModel.isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return ImagePickerWidget(
      imageUrl: _viewModel.imageUrl,
      imageFile: _viewModel.selectedImage,
      height: 200,
      label: 'Product Image',
      isLoading: _viewModel.isLoading,
      onTap: () => _showImagePicker(context),
    );
  }

  void _showImagePicker(BuildContext context) async {
    final source = await ImagePickerModal.show(context);
    if (source != null) {
      if (source == ImageSource.gallery) {
        _viewModel.pickImageFromGallery();
      } else {
        _viewModel.pickImageFromCamera();
      }
    }
  }

  Widget _buildQuantitySection(ThemeData theme) {
    return Column(
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
                controller: _viewModel.quantityController,
                keyboardType: TextInputType.number,
                validator: _viewModel.validateQuantity,
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
                    value: _viewModel.selectedQuantityUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: theme.textTheme.bodyMedium,
                    onChanged: (String? value) {
                      if (value != null) {
                        _viewModel.updateQuantityUnit(value);
                      }
                    },
                    items:
                        _viewModel.quantityUnits.map<DropdownMenuItem<String>>((
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
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
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
            border: Border.all(color: AppColors.palmAshGray.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _viewModel.selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: theme.textTheme.bodyMedium,
              onChanged: (String? value) {
                if (value != null) {
                  _viewModel.updateCategory(value);
                }
              },
              items:
                  _viewModel.categories.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        _viewModel.categoryDisplayNames[value] ?? value,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
