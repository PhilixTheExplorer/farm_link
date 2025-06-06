import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../core/theme/app_colors.dart';
import '../services/user_service.dart';
import '../services/cart_service.dart';
import '../core/di/service_locator.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final UserService _userService = serviceLocator<UserService>();
  final CartService _cartService = serviceLocator<CartService>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _deliveryAddressController;
  late TextEditingController _notesController;

  String? _selectedPaymentMethod;
  bool _isLoading = false;

  // Common payment methods
  static const List<String> _paymentMethods = [
    'Cash on Delivery',
    'Bank Transfer',
    'Mobile Banking',
    'Credit Card',
    'PromptPay',
    'QR Code Payment',
  ];
  @override
  void initState() {
    super.initState();
    _initializeForm();
    // Load cart data when checkout view opens
    _cartService.loadCart();
  }

  void _initializeForm() {
    final buyer = _userService.buyerData;

    // Pre-fill delivery address if available
    _deliveryAddressController = TextEditingController(
      text: buyer?.deliveryAddress ?? '',
    );
    _notesController = TextEditingController();

    // Pre-select the first preferred payment method if available
    if (buyer?.preferences != null && buyer!.preferences!.isNotEmpty) {
      _selectedPaymentMethod = buyer.preferences!.first;
    }
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppColors.chilliRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _cartService.checkout(
        deliveryAddress: _deliveryAddressController.text.trim(),
        paymentMethod: _selectedPaymentMethod!,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      if (mounted) {
        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: AppColors.ricePaddyGreen,
            ),
          );
          context.go('/order-confirmation');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Checkout failed'),
              backgroundColor: AppColors.chilliRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buyer = _userService.buyerData;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ), // Cart summary will be loaded from CartService
                      ListenableBuilder(
                        listenable: _cartService,
                        builder: (context, child) {
                          final cart = _cartService.cart;
                          final items = cart?.items ?? [];
                          final total = cart?.total ?? 0.0;

                          if (_cartService.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Items (${items.length})'),
                                  Text('฿${total.toStringAsFixed(2)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '฿${total.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ricePaddyGreen,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Information
              Text(
                'Delivery Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ThaiTextField(
                label: 'Delivery Address',
                controller: _deliveryAddressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter delivery address';
                  }
                  return null;
                },
              ),

              if (buyer?.deliveryAddress != null &&
                  buyer!.deliveryAddress!.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    _deliveryAddressController.text = buyer.deliveryAddress!;
                  },
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Use saved address'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ricePaddyGreen,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Show preferred payment methods first if available
              if (buyer?.preferences != null &&
                  buyer!.preferences!.isNotEmpty) ...[
                Text(
                  'Your Preferred Methods',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ricePaddyGreen,
                  ),
                ),
                const SizedBox(height: 8),
                ...buyer.preferences!.map(
                  (method) => RadioListTile<String>(
                    title: Text(method),
                    subtitle: const Text('Preferred'),
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    activeColor: AppColors.ricePaddyGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

              Text(
                'Other Payment Methods',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Show other payment methods
              ..._paymentMethods
                  .where(
                    (method) => buyer?.preferences?.contains(method) != true,
                  )
                  .map(
                    (method) => RadioListTile<String>(
                      title: Text(method),
                      value: method,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                      activeColor: AppColors.ricePaddyGreen,
                    ),
                  ),

              const SizedBox(height: 24),

              // Additional Notes
              ThaiTextField(
                label: 'Additional Notes (Optional)',
                controller: _notesController,
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
                hintText: 'Any special instructions for delivery...',
              ),

              const SizedBox(height: 32),

              // Place Order Button
              ThaiButton(
                label: 'Place Order',
                onPressed: _isLoading ? null : _processCheckout,
                isFullWidth: true,
                icon: Icons.shopping_cart_checkout,
              ),

              const SizedBox(height: 16),

              // Update Payment Preferences Link
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/profile-edit');
                  },
                  child: const Text('Update payment preferences'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tamarindBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
