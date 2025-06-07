import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../services/image_upload_service.dart';
import '../viewmodels/farmer_dashboard_viewmodel.dart';
import '../core/di/service_locator.dart';

enum ProductFormMode { create, edit }

class ProductFormViewModel extends ChangeNotifier {
  final ProductService _productService = serviceLocator<ProductService>();
  final UserService _userService = serviceLocator<UserService>();
  final ImageUploadService _imageUploadService =
      serviceLocator<ImageUploadService>();
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
  PickedImage? _selectedImage;
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
  // Getters
  ProductFormMode get mode => _mode;
  Product? get originalProduct => _originalProduct;
  String get selectedCategory => _selectedCategory;
  String get selectedQuantityUnit => _selectedQuantityUnit;
  String? get imageUrl => _imageUrl;
  PickedImage? get selectedImage => _selectedImage;
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
    _selectedImage = null;
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
    // No default image - user must pick one
    _imageUrl = null;
    notifyListeners();
  }

  // Update category
  void updateCategory(String category) {
    _selectedCategory = category;
    // Don't automatically set images - user must pick one
    notifyListeners();
  }

  // Update quantity unit
  void updateQuantityUnit(String unit) {
    _selectedQuantityUnit = unit;
    notifyListeners();
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true); // Set loading state while picking image

      final imageFile = await _imageUploadService.pickImageFromGallery(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (imageFile != null) {
        // Verify the file exists before updating
        if (await imageFile.exists()) {
          _selectedImage = imageFile;
          _imageUrl = null; // Clear URL when selecting new image
          debugPrint('Gallery image selected: ${imageFile.path}');
        } else {
          debugPrint('Gallery image file does not exist: ${imageFile.path}');
          _errorMessage = 'Selected image file not found';
        }
      } else {
        debugPrint('No gallery image was selected');
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      debugPrint('Error picking image from gallery: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      _setLoading(true); // Set loading state while capturing image

      final imageFile = await _imageUploadService.pickImageFromCamera(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (imageFile != null) {
        // Verify the file exists before updating
        if (await imageFile.exists()) {
          _selectedImage = imageFile;
          _imageUrl = null; // Clear URL when selecting new image
          debugPrint('Camera image captured: ${imageFile.path}');
        } else {
          debugPrint('Camera image file does not exist: ${imageFile.path}');
          _errorMessage = 'Captured image file not found';
        }
      } else {
        debugPrint('No camera image was captured');
      }
    } catch (e) {
      _errorMessage = 'Failed to take photo: ${e.toString()}';
      debugPrint('Error taking photo: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Upload selected image to Cloudinary
  Future<String?> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return _imageUrl;

    try {
      final uploadedUrl = await _imageUploadService.uploadToCloudinary(
        _selectedImage!,
        folder: 'farm_link/products',
        transformations: {
          'width': 800,
          'height': 600,
          'crop': 'fill',
          'quality': 'auto',
          'format': 'auto',
        },
      );

      if (uploadedUrl != null) {
        debugPrint('Product image uploaded to Cloudinary: $uploadedUrl');
        return uploadedUrl;
      }
    } catch (e) {
      debugPrint('Error uploading image to Cloudinary: $e');
      _errorMessage = 'Failed to upload image: ${e.toString()}';
    }
    return null;
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
    final farmerId =
        _userService.farmerData!.id; // Upload image if one is selected
    String? finalImageUrl = _imageUrl;
    if (_selectedImage != null) {
      finalImageUrl = await _uploadImageToCloudinary();
      if (finalImageUrl == null) {
        _errorMessage = 'Failed to upload image. Please try again.';
        return false;
      }
    } else if (finalImageUrl == null) {
      _errorMessage = 'Please select an image for the product.';
      return false;
    }

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
      imageUrl: finalImageUrl,
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
    } // Upload image if one is selected
    String? finalImageUrl = _imageUrl;
    if (_selectedImage != null) {
      finalImageUrl = await _uploadImageToCloudinary();
      finalImageUrl ??= _originalProduct!.imageUrl;
    } else {
      finalImageUrl ??= _originalProduct!.imageUrl;
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
      imageUrl: finalImageUrl,
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
