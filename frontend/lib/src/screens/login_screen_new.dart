import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_builder.dart';
import '../providers/auth_provider.dart';
import 'dart:ui';

/// Modern login/signup screen with glassmorphism - Fully responsive
class LoginScreenNew extends ConsumerStatefulWidget {
  const LoginScreenNew({super.key});

  @override
  ConsumerState<LoginScreenNew> createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends ConsumerState<LoginScreenNew> with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _confirm = TextEditingController();
  late final AnimationController _animController;
  bool _isLogin = true;
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _confirm.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
  }

  void _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }

    // Call the auth provider to login
    final success = await ref.read(authProvider.notifier).login(email, password);

    if (success && mounted) {
      final authState = ref.read(authProvider);
      
      if (authState.needsVerification) {
        // User needs to verify CIN
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your identity to continue')),
        );
        context.go('/register'); // Go to registration to upload CIN
      } else if (authState.isAuthenticated) {
        // Fully authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome back!')),
        );
        context.go('/user/home');
      }
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Login failed')),
      );
    }
  }

  void _signup() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();
    final confirm = _confirm.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (confirm != password) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }

    // Call the auth provider to register
    final success = await ref.read(authProvider.notifier).register(email, name, password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please verify your identity.')),
      );
      // Navigate to CIN verification screen
      context.go('/register');
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, deviceType, constraints) {
            final horizontalPadding = ResponsiveValue<double>(
              mobile: 24.0,
              tablet: 48.0,
              desktop: 64.0,
            ).getValue(deviceType);

            final verticalPadding = ResponsiveValue<double>(
              mobile: 32.0,
              tablet: 48.0,
              desktop: 64.0,
            ).getValue(deviceType);

            return Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: deviceType == DeviceType.desktop ? 600 : double.infinity,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(deviceType),
                      SizedBox(height: ResponsiveValue<double>(mobile: 40, tablet: 48, desktop: 56).getValue(deviceType)),
                      _buildGlassLoginCard(deviceType),
                      const SizedBox(height: 24),
                      _buildFooterText(),
                      const SizedBox(height: 16),
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(DeviceType deviceType) {
    final iconSize = ResponsiveValue<double>(
      mobile: 60,
      tablet: 72,
      desktop: 80,
    ).getValue(deviceType);

    final iconInnerSize = ResponsiveValue<double>(
      mobile: 32,
      tablet: 38,
      desktop: 42,
    ).getValue(deviceType);

    final titleSize = ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 32,
    ).getValue(deviceType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryCyan.withOpacity(0.2),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: AppColors.primaryCyan,
            size: iconInnerSize,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Secure, Ethical Finance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGlassLoginCard(DeviceType deviceType) {
    final cardPadding = ResponsiveValue<double>(
      mobile: 28,
      tablet: 36,
      desktop: 44,
    ).getValue(deviceType);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: AppColors.glassLight.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isLogin = true);
                      },
                      child: Column(
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              color: _isLogin ? Colors.white : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_isLogin) ...[
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primaryCyan,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isLogin = false);
                      },
                      child: Column(
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: !_isLogin ? AppColors.primaryCyan : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 8),
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primaryCyan,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (!_isLogin) ...[
                Text('Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _name,
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
              ],
              Text('Email', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _email,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                errorText: _emailError,
              ),
              const SizedBox(height: 20),
              Text('Password', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _password,
                hintText: 'Enter your password',
                obscureText: !_showPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
                onSuffixTap: () => setState(() => _showPassword = !_showPassword),
                errorText: _passwordError,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 20),
                Text('Confirm Password', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _confirm,
                  hintText: 'Confirm your password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),
              ],
              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primaryCyan)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLogin ? _login : _signup,
                  child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(color: AppColors.primaryCyan),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(color: AppColors.primaryCyan),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: Text(
              'Create Account',
              style: TextStyle(
                color: AppColors.primaryCyan,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
