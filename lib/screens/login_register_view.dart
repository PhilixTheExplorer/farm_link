import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../theme/app_colors.dart';

class LoginRegisterView extends StatefulWidget {
  const LoginRegisterView({Key? key}) : super(key: key);

  @override
  State<LoginRegisterView> createState() => _LoginRegisterViewState();
}

class _LoginRegisterViewState extends State<LoginRegisterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'Farmer';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        // Navigate based on role
        if (_selectedRole == 'Farmer') {
          // Navigate to Farmer Dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigating to Farmer Dashboard')),
          );
        } else {
          // Navigate to Buyer Marketplace
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigating to Buyer Marketplace')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1464638681273-0962e9b53566?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and App Name
                  const Icon(
                    Icons.eco,
                    size: 64,
                    color: AppColors.tamarindBrown,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FarmLink',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.tamarindBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Thai Rural Simplicity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.palmAshGray,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Card with Login/Register Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Tab Bar
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Login'),
                              Tab(text: 'Register'),
                            ],
                            indicatorColor: AppColors.ricePaddyGreen,
                            labelColor: AppColors.ricePaddyGreen,
                            unselectedLabelColor: AppColors.palmAshGray,
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Form
                          SizedBox(
                            height: _tabController.index == 0 ? 220 : 340,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Login Tab
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      ThaiTextField(
                                        label: 'Email',
                                        hintText: 'Enter your email',
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      ThaiTextField(
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        onSuffixIconPressed: _togglePasswordVisibility,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      ThaiButton(
                                        label: 'Login',
                                        onPressed: _handleSubmit,
                                        isLoading: _isLoading,
                                        isFullWidth: true,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Register Tab
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      ThaiTextField(
                                        label: 'Email',
                                        hintText: 'Enter your email',
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      ThaiTextField(
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: _isPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        onSuffixIconPressed: _togglePasswordVisibility,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      ThaiTextField(
                                        label: 'Confirm Password',
                                        hintText: 'Confirm your password',
                                        controller: _confirmPasswordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Role Selector
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                                            child: Text(
                                              'I am a:',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  title: const Text('Farmer'),
                                                  value: 'Farmer',
                                                  groupValue: _selectedRole,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedRole = value!;
                                                    });
                                                  },
                                                  activeColor: AppColors.ricePaddyGreen,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  title: const Text('Buyer'),
                                                  value: 'Buyer',
                                                  groupValue: _selectedRole,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedRole = value!;
                                                    });
                                                  },
                                                  activeColor: AppColors.ricePaddyGreen,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      ThaiButton(
                                        label: 'Register',
                                        onPressed: _handleSubmit,
                                        variant: ThaiButtonVariant.secondary,
                                        isLoading: _isLoading,
                                        isFullWidth: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Text
                  Text(
                    'Connecting Thai Farmers to Buyers',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.palmAshGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
