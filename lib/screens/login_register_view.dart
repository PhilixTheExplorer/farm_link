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
  double _currentHeight = 260;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Separate controllers for login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Separate controllers for register
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Farmer';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();

    // Dispose all controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentHeight = _tabController.index == 0 ? 260 : 460;
    });
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _handleSubmit() {
    final formKey = _tabController.index == 0 ? _loginFormKey : _registerFormKey;

    if (formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        final destination = _selectedRole == 'Farmer' ? 'Farmer Dashboard' : 'Buyer Marketplace';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to $destination')),
        );
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
            image: NetworkImage(
              'https://images.unsplash.com/photo-1464638681273-0962e9b53566?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
            ),
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
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    width: 200,
                    height: 200,
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
                            indicatorColor: AppColors.ricePaddyGreen,
                            labelColor: AppColors.ricePaddyGreen,
                            unselectedLabelColor: AppColors.palmAshGray,
                          ),
                          const SizedBox(height: 24),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _currentHeight,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Login Form
                                Form(
                                  key: _loginFormKey,
                                  child: Column(
                                    children: [
                                      ThaiTextField(
                                        label: 'Email',
                                        hintText: 'Enter your email',
                                        controller: _loginEmailController,
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined,
                                        validator: (value) =>
                                        value == null || value.isEmpty ? 'Please enter your email' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      ThaiTextField(
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        controller: _loginPasswordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        onSuffixIconPressed: _togglePasswordVisibility,
                                        validator: (value) =>
                                        value == null || value.isEmpty ? 'Please enter your password' : null,
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

                                // Register Form
                                Form(
                                  key: _registerFormKey,
                                  child: Column(
                                    children: [
                                      ThaiTextField(
                                        label: 'Email',
                                        hintText: 'Enter your email',
                                        controller: _registerEmailController,
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined,
                                        validator: (value) =>
                                        value == null || value.isEmpty ? 'Please enter your email' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      ThaiTextField(
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        controller: _registerPasswordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        suffixIcon: _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        onSuffixIconPressed: _togglePasswordVisibility,
                                        validator: (value) =>
                                        value == null || value.isEmpty ? 'Please enter your password' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      ThaiTextField(
                                        label: 'Confirm Password',
                                        hintText: 'Confirm your password',
                                        controller: _confirmPasswordController,
                                        obscureText: !_isPasswordVisible,
                                        prefixIcon: Icons.lock_outline,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Please confirm your password';
                                          if (value != _registerPasswordController.text) return 'Passwords do not match';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Role selection
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                                            child: Text('I am a:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  title: const Text('Farmer'),
                                                  value: 'Farmer',
                                                  groupValue: _selectedRole,
                                                  onChanged: (value) => setState(() => _selectedRole = value!),
                                                  activeColor: AppColors.ricePaddyGreen,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  title: const Text('Buyer'),
                                                  value: 'Buyer',
                                                  groupValue: _selectedRole,
                                                  onChanged: (value) => setState(() => _selectedRole = value!),
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
                                        isLoading: _isLoading,
                                        isFullWidth: true,
                                        variant: ThaiButtonVariant.secondary,
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
                  Text(
                    'Connecting Thai Farmers to Buyers',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.palmAshGray),
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
