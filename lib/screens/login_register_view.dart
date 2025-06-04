import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/login_register_viewmodel.dart';
import '../models/auth_models.dart';

class LoginRegisterView extends StatefulWidget {
  const LoginRegisterView({super.key});

  @override
  State<LoginRegisterView> createState() => _LoginRegisterViewState();
}

class _LoginRegisterViewState extends State<LoginRegisterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LoginRegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = LoginRegisterViewModel();

    // Listen to view model changes
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    // Handle success navigation
    if (_viewModel.viewState.state == AuthState.success) {
      final destination =
          _tabController.index == 0
              ? _viewModel.getNavigationDestination()
              : _viewModel.getRegistrationDestination();
      context.go(destination);
    }

    // Handle error messages
    if (_viewModel.viewState.state == AuthState.error) {
      _showErrorMessage(
        _viewModel.viewState.errorMessage ?? 'An error occurred',
      );
    }
  }

  void _handleSubmit() async {
    _viewModel.clearError();

    if (_tabController.index == 0) {
      await _viewModel.login();
    } else {
      await _viewModel.register();
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      children: [_buildLoginForm(), _buildRegisterForm()],
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

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _viewModel.loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThaiTextField(
              label: 'Email',
              hintText: 'Enter your email',
              controller: _viewModel.loginEmailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: _viewModel.validateLoginEmail,
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                return ThaiTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _viewModel.loginPasswordController,
                  obscureText: !_viewModel.isLoginPasswordVisible,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon:
                      _viewModel.isLoginPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                  onSuffixIconPressed: _viewModel.toggleLoginPasswordVisibility,
                  validator: _viewModel.validateLoginPassword,
                );
              },
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                return ThaiButton(
                  label: 'Login',
                  onPressed: _handleSubmit,
                  isLoading: _viewModel.isLoading,
                  isFullWidth: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _viewModel.registerFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThaiTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _viewModel.registerEmailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: _viewModel.validateRegisterEmail,
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  return ThaiTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _viewModel.registerPasswordController,
                    obscureText: !_viewModel.isRegisterPasswordVisible,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon:
                        _viewModel.isRegisterPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                    onSuffixIconPressed:
                        _viewModel.toggleRegisterPasswordVisibility,
                    validator: _viewModel.validateRegisterPassword,
                  );
                },
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  return ThaiTextField(
                    label: 'Confirm Password',
                    hintText: 'Confirm your password',
                    controller: _viewModel.confirmPasswordController,
                    obscureText: !_viewModel.isRegisterPasswordVisible,
                    prefixIcon: Icons.lock_outline,
                    validator: _viewModel.validateConfirmPassword,
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildRoleSelector(),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _viewModel,
                builder: (context, child) {
                  return ThaiButton(
                    label: 'Register',
                    onPressed: _handleSubmit,
                    isLoading: _viewModel.isLoading,
                    isFullWidth: true,
                    variant: ThaiButtonVariant.secondary,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'I am a:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Farmer'),
                value: 'Farmer',
                groupValue: _viewModel.selectedRole,
                onChanged: (value) => _viewModel.setSelectedRole(value!),
                activeColor: AppColors.ricePaddyGreen,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Buyer'),
                value: 'Buyer',
                groupValue: _viewModel.selectedRole,
                onChanged: (value) => _viewModel.setSelectedRole(value!),
                activeColor: AppColors.ricePaddyGreen,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
