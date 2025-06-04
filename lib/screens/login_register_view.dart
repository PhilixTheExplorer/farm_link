import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../core/theme/app_colors.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class LoginRegisterView extends StatefulWidget {
  const LoginRegisterView({super.key});

  @override
  State<LoginRegisterView> createState() => _LoginRegisterViewState();
}

class _LoginRegisterViewState extends State<LoginRegisterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Dispose all controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _toggleLoginPasswordVisibility() {
    setState(() => _isLoginPasswordVisible = !_isLoginPasswordVisible);
  }

  void _toggleRegisterPasswordVisibility() {
    setState(() => _isRegisterPasswordVisible = !_isRegisterPasswordVisible);
  }

  void _handleSubmit() async {
    final formKey =
        _tabController.index == 0 ? _loginFormKey : _registerFormKey;

    if (formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email =
          _tabController.index == 0
              ? _loginEmailController.text
              : _registerEmailController.text;
      final password =
          _tabController.index == 0
              ? _loginPasswordController.text
              : _registerPasswordController.text;

      if (_tabController.index == 0) {
        // Login
        final result = await UserService().login(email, password);
        setState(() => _isLoading = false);

        if (result.isSuccess) {
          // Navigate based on detected role
          final userService = UserService();
          final destination =
              userService.currentUserRole == UserRole.farmer
                  ? '/farmer-dashboard'
                  : '/buyer-marketplace';

          Navigator.pushNamedAndRemoveUntil(
            context,
            destination,
            (route) => false,
          );
        } else {
          _showErrorMessage(
            result.errorMessage ??
                'Login failed. Please check your credentials.',
          );
        }
      } else {
        // Register - collect additional info
        final result = await UserService().register(
          email,
          password,
          _selectedRole.toLowerCase(),
        );
        setState(() => _isLoading = false);

        if (result.isSuccess) {
          // Navigate based on selected role
          final destination =
              _selectedRole == 'Farmer'
                  ? '/farmer-dashboard'
                  : '/buyer-marketplace';

          Navigator.pushNamedAndRemoveUntil(
            context,
            destination,
            (route) => false,
          );
        } else {
          _showErrorMessage(
            result.errorMessage ?? 'Registration failed. Please try again.',
          );
        }
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Helps with keyboard appearance
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home.jpg'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Make content scrollable
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
                    indicatorColor: AppColors.ricePaddyGreen,
                    labelColor: AppColors.ricePaddyGreen,
                    unselectedLabelColor: AppColors.palmAshGray,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Login Form
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _loginFormKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Login form fields unchanged
                                ThaiTextField(
                                  label: 'Email',
                                  hintText: 'Enter your email',
                                  controller: _loginEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'Please enter your email'
                                              : null,
                                ),
                                const SizedBox(height: 10),
                                ThaiTextField(
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  controller: _loginPasswordController,
                                  obscureText: !_isLoginPasswordVisible,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon:
                                      _isLoginPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                  onSuffixIconPressed:
                                      _toggleLoginPasswordVisibility,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'Please enter your password'
                                              : null,
                                ),
                                const SizedBox(height: 20),
                                ThaiButton(
                                  label: 'Login',
                                  onPressed: _handleSubmit,
                                  isLoading: _isLoading,
                                  isFullWidth: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Register Form - structure remains the same
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _registerFormKey,
                            child: SingleChildScrollView(
                              // Extra scroll for registration
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Registration form fields - unchanged
                                  ThaiTextField(
                                    label: 'Email',
                                    hintText: 'Enter your email',
                                    controller: _registerEmailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Please enter your email'
                                                : null,
                                  ),
                                  const SizedBox(height: 10),
                                  ThaiTextField(
                                    label: 'Password',
                                    hintText: 'Enter your password',
                                    controller: _registerPasswordController,
                                    obscureText: !_isRegisterPasswordVisible,
                                    prefixIcon: Icons.lock_outline,
                                    suffixIcon:
                                        _isRegisterPasswordVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                    onSuffixIconPressed:
                                        _toggleRegisterPasswordVisibility,
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Please enter your password'
                                                : null,
                                  ),
                                  const SizedBox(height: 10),
                                  ThaiTextField(
                                    label: 'Confirm Password',
                                    hintText: 'Confirm your password',
                                    controller: _confirmPasswordController,
                                    obscureText: !_isRegisterPasswordVisible,
                                    prefixIcon: Icons.lock_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value !=
                                          _registerPasswordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Role selection
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          'I am a:',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('Farmer'),
                                          value: 'Farmer',
                                          groupValue: _selectedRole,
                                          onChanged:
                                              (value) => setState(
                                                () => _selectedRole = value!,
                                              ),
                                          activeColor: AppColors.ricePaddyGreen,
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('Buyer'),
                                          value: 'Buyer',
                                          groupValue: _selectedRole,
                                          onChanged:
                                              (value) => setState(
                                                () => _selectedRole = value!,
                                              ),
                                          activeColor: AppColors.ricePaddyGreen,
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
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
                          ),
                        ),
                      ],
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
