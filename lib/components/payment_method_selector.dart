import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PaymentMethodSelector extends StatefulWidget {
  final List<String> selectedMethods;
  final Function(List<String>) onSelectionChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethods,
    required this.onSelectionChanged,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  static const List<String> _availablePaymentMethods = [
    'Cash on Delivery',
    'Bank Transfer',
    'Mobile Banking',
    'Credit Card',
    'PromptPay',
    'QR Code Payment',
  ];

  late List<String> _selectedMethods;

  @override
  void initState() {
    super.initState();
    _selectedMethods = List.from(widget.selectedMethods);
  }

  void _togglePaymentMethod(String method) {
    setState(() {
      if (_selectedMethods.contains(method)) {
        _selectedMethods.remove(method);
      } else {
        _selectedMethods.add(method);
      }
    });
    widget.onSelectionChanged(_selectedMethods);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Payment Methods',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your preferred payment methods for faster checkout',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.palmAshGray,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availablePaymentMethods.map((method) {
                final isSelected = _selectedMethods.contains(method);
                return FilterChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (_) => _togglePaymentMethod(method),
                  selectedColor: AppColors.ricePaddyGreen.withOpacity(0.2),
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? AppColors.ricePaddyGreen : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.ricePaddyGreen
                            : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
        ),
        if (_selectedMethods.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.ricePaddyGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.ricePaddyGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.ricePaddyGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected ${_selectedMethods.length} payment method${_selectedMethods.length > 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.ricePaddyGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
