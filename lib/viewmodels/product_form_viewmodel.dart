import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../viewmodels/farmer_dashboard_viewmodel.dart';
import '../core/di/service_locator.dart';

enum ProductFormMode { create, edit }

class ProductFormViewModel extends ChangeNotifier {
  final ProductService _productService = serviceLocator<ProductService>();
  final UserService _userService = serviceLocator<UserService>();
  final FarmerDashboardViewModel _dashboardViewModel =
      serviceLocator<FarmerDashboardViewModel>();

  // Form controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();

  // Form state
  ProductFormMode _mode = ProductFormMode.create;
  Product? _originalProduct;
  String _selectedCategory = 'vegetables';
  String _selectedQuantityUnit = 'pcs';
  String? _imageUrl;
  bool _isLoading = false;
  String? _errorMessage;

  // Backend compatible categories
  final List<String> categories = [
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
  final Map<String, String> categoryDisplayNames = {
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
  final List<String> quantityUnits = [
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

  // Sample images for categories
  final Map<String, String> sampleImages = {
    'vegetables':
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
    'fruits': 'https://images.unsplash.com/photo-1557844352-761f2565b576?w=400',
    'rice':
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
    'herbs':
        'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=400',
    'handmade':
        'https://images.unsplash.com/photo-1505236732187-3d0d5c5e5daf?w=400',
    'dairy': 'https://images.unsplash.com/photo-1550989460-0adf9ea622e2?w=400',
    'meat':
        'https://images.unsplash.com/photo-1603048297172-c92544798d5a?w=400',
    'other':
        'https://images.unsplash.com/photo-1601599561213-832382fd07ba?w=400',
  };

  // Getters
  ProductFormMode get mode => _mode;
  Product? get originalProduct => _originalProduct;
  String get selectedCategory => _selectedCategory;
  String get selectedQuantityUnit => _selectedQuantityUnit;
  String? get imageUrl => _imageUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCreateMode => _mode == ProductFormMode.create;
  bool get isEditMode => _mode == ProductFormMode.edit;

  String get formTitle => isCreateMode ? 'Add New Product' : 'Edit Product';
  String get submitButtonText =>
      isCreateMode ? 'Add Product' : 'Update Product';
  IconData get submitButtonIcon => isCreateMode ? Icons.add : Icons.save;

  // Initialize for create mode
  void initializeForCreate() {
    _mode = ProductFormMode.create;
    _originalProduct = null;
    _clearForm();
    _setDefaultImage();
  }

  // Initialize for edit mode
  void initializeForEdit(Product product) {
    _mode = ProductFormMode.edit;
    _originalProduct = product;
    _populateFormWithProduct(product);
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    quantityController.clear();
    _selectedCategory = 'vegetables';
    _selectedQuantityUnit = 'pcs';
    _imageUrl = null;
    _errorMessage = null;
  }

  // Populate form with existing product data
  void _populateFormWithProduct(Product product) {
    nameController.text = product.title;
    priceController.text = product.price.toString();
    descriptionController.text = product.description;
    quantityController.text = product.quantity.toString();
    _selectedCategory = product.category.toString().split('.').last;
    _selectedQuantityUnit = product.unit;
    _imageUrl = product.imageUrl;
    _errorMessage = null;
    notifyListeners();
  }

  // Set default image based on category
  void _setDefaultImage() {
    _imageUrl = sampleImages[_selectedCategory];
    notifyListeners();
  }

  // Update category
  void updateCategory(String category) {
    _selectedCategory = category;
    if (_imageUrl == null || sampleImages.containsValue(_imageUrl)) {
      _imageUrl = sampleImages[category];
    }
    notifyListeners();
  }

  // Update quantity unit
  void updateQuantityUnit(String unit) {
    _selectedQuantityUnit = unit;
    notifyListeners();
  }

  // Pick new image (for now, cycle through category images)
  void pickImage() {
    _imageUrl = sampleImages[_selectedCategory] ?? sampleImages['vegetables']!;
    notifyListeners();
  }

  // Validate form
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a product name';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    return null;
  }

  // Submit form
  Future<bool> submitForm() async {
    // Validate user is farmer
    final currentUser = _userService.currentUser;
    if (currentUser == null ||
        _userService.currentUserRole != UserRole.farmer) {
      _errorMessage = 'You must be logged in as a farmer to manage products';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      if (isCreateMode) {
        return await _createProduct();
      } else {
        return await _updateProduct();
      }
    } catch (e) {
      _errorMessage =
          'Error ${isCreateMode ? 'creating' : 'updating'} product: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create new product
  Future<bool> _createProduct() async {
    final farmerId = _userService.farmerData!.id;

    final newProduct = Product(
      id: '', // Will be generated by backend
      farmerId: farmerId,
      title: nameController.text,
      description: descriptionController.text,
      price: double.parse(priceController.text),
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedCategory,
      ),
      quantity: int.parse(quantityController.text),
      unit: _selectedQuantityUnit,
      imageUrl: _imageUrl ?? sampleImages['vegetables']!,
      status: ProductStatus.available,
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      orderCount: 0,
    );

    debugPrint('Creating product: ${newProduct.toCreateJson()}');

    final success = await _productService.addProduct(newProduct);

    if (success) {
      await _dashboardViewModel.onProductUploaded();
    }

    return success;
  }

  // Update existing product
  Future<bool> _updateProduct() async {
    if (_originalProduct == null) {
      _errorMessage = 'Original product data not found';
      return false;
    }

    final updatedProduct = Product(
      id: _originalProduct!.id,
      farmerId: _originalProduct!.farmerId,
      title: nameController.text,
      description: descriptionController.text,
      price: double.parse(priceController.text),
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedCategory,
      ),
      quantity: int.parse(quantityController.text),
      unit: _selectedQuantityUnit,
      imageUrl: _imageUrl ?? sampleImages['vegetables']!,
      status: _originalProduct!.status,
      createdDate: _originalProduct!.createdDate,
      lastUpdated: DateTime.now(),
      orderCount: _originalProduct!.orderCount,
    );

    debugPrint('Updating product: ${updatedProduct.toJson()}');

    final success = await _productService.updateProduct(updatedProduct);

    if (success) {
      await _dashboardViewModel.onProductUploaded();
    }

    return success;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }
}
