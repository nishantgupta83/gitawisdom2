// lib/screens/modern_auth_screen.dart

import 'dart:math' show sin, cos, pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_auth_service.dart';
import '../core/app_config.dart';
import 'root_scaffold.dart';

class ModernAuthScreen extends StatefulWidget {
  const ModernAuthScreen({super.key});

  @override
  State<ModernAuthScreen> createState() => _ModernAuthScreenState();
}

class _ModernAuthScreenState extends State<ModernAuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0; // 0 = Sign In, 1 = Sign Up
  bool _rememberMe = false;

  // Test accounts for development - Create these accounts using sign up
  final List<Map<String, String>> _testAccounts = [
    {
      'email': 'test@gitawisdom.com',
      'password': 'Test123!',
      'name': 'Test User',
      'role': 'Regular User'
    },
    {
      'email': 'demo@gitawisdom.com',
      'password': 'Demo123!',
      'name': 'Demo User',
      'role': 'Demo Account'
    },
    {
      'email': 'developer@gitawisdom.com',
      'password': 'Dev123!',
      'name': 'Developer User',
      'role': 'Developer'
    },
    {
      'email': 'tester@gitawisdom.com',
      'password': 'Tester123!',
      'name': 'QA Tester',
      'role': 'QA Tester'
    },
    {
      'email': 'user@gitawisdom.com',
      'password': 'User123!',
      'name': 'Regular User',
      'role': 'Standard User'
    }
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Consumer<SupabaseAuthService>(
        builder: (context, authService, child) {
          return Stack(
            children: [
              // Animated background
              _buildAnimatedBackground(isDark, size),
              
              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 40),
                            _buildHeader(theme),
                            const SizedBox(height: 32),
                            Flexible(
                              child: _buildAuthCard(theme, authService),
                            ),
                            _buildFooter(theme, authService),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Loading overlay
              if (authService.isLoading)
                Container(
                  color: Colors.black.withValues(alpha:0.7),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Please wait...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE8F2FF),
                  const Color(0xFFDEE9FC),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Floating orbs animation
          Positioned(
            top: 100,
            right: -50,
            child: _buildFloatingOrb(120, isDark ? Colors.orange.withValues(alpha:0.1) : Colors.blue.withValues(alpha:0.1)),
          ),
          Positioned(
            bottom: 150,
            left: -30,
            child: _buildFloatingOrb(80, isDark ? Colors.blue.withValues(alpha:0.1) : Colors.orange.withValues(alpha:0.1)),
          ),
          Positioned(
            top: 300,
            left: 50,
            child: _buildFloatingOrb(40, isDark ? Colors.purple.withValues(alpha:0.1) : Colors.green.withValues(alpha:0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(double size, Color color) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(_fadeController.value * 2 * pi) * 10,
            cos(_fadeController.value * 2 * pi) * 15,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App logo with enhanced animation
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha:0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Welcome text
        Text(
          'Welcome to',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.8),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: Text(
            'GitaWisdom',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ancient wisdom for modern life',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthCard(ThemeData theme, SupabaseAuthService authService) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha:0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Tab indicator
            _buildTabIndicator(theme),
            const SizedBox(height: 32),
            
            // Show error if any
            if (authService.error != null) ...[
              _buildErrorBanner(theme, authService),
              const SizedBox(height: 20),
            ],
            
            // Auth form
            _buildAuthForm(theme, authService),
            
            // Test accounts section
            if (_currentPage == 0) _buildTestAccountsSection(theme),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTabIndicator(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _switchToPage(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 0
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _currentPage == 0
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentPage == 0
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha:0.7),
                    fontWeight: _currentPage == 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _switchToPage(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _currentPage == 1
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _currentPage == 1
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentPage == 1
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha:0.7),
                    fontWeight: _currentPage == 1 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, SupabaseAuthService authService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              authService.error!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: authService.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(ThemeData theme, SupabaseAuthService authService) {
    return Form(
      key: _formKey,
      child: SizedBox(
        height: 400, // Fixed height to prevent unbounded constraints
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          children: [
            _buildSignInForm(theme, authService),
            _buildSignUpForm(theme, authService),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(ThemeData theme, SupabaseAuthService authService) {
    return Column(
      children: [
        // Email field
        _buildModernTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        _buildModernTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Remember me and forgot password
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
              activeColor: theme.colorScheme.primary,
            ),
            Expanded(
              child: Text(
                'Remember me',
                style: theme.textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                'Forgot?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Sign in button
        _buildPrimaryButton(
          context: context,
          text: 'Sign In',
          onPressed: authService.isLoading ? null : _handleSignIn,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSignUpForm(ThemeData theme, SupabaseAuthService authService) {
    return Column(
      children: [
        // Name field
        _buildModernTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Email field
        _buildModernTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        _buildModernTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 20),
        
        // Confirm password field
        _buildModernTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
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
        
        const SizedBox(height: 32),
        
        // Sign up button
        _buildPrimaryButton(
          context: context,
          text: 'Create Account',
          onPressed: authService.isLoading ? null : _handleSignUp,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha:0.1),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: onPressed != null
              ? [theme.colorScheme.primary, theme.colorScheme.secondary]
              : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha:0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestAccountsSection(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha:0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Test Accounts',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha:0.3))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _testAccounts.map((account) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha:0.2),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                title: Text(account['name']!, style: const TextStyle(fontSize: 14)),
                subtitle: Text('${account['email']} • ${account['password']}', 
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha:0.6))),
                trailing: TextButton(
                  onPressed: () => _useTestAccount(account),
                  child: const Text('Use', style: TextStyle(fontSize: 12)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, SupabaseAuthService authService) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha:0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha:0.3))),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Continue as guest button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: authService.isLoading ? null : _continueAsGuest,
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'You can create an account later to sync your progress',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _switchToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Clear form when switching tabs
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _confirmPasswordController.clear();
  }

  void _useTestAccount(Map<String, String> account) {
    _emailController.text = account['email']!;
    _passwordController.text = account['password']!;
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = context.read<SupabaseAuthService>();
    final success = await authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootScaffold()),
      );
    }
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = context.read<SupabaseAuthService>();
    final success = await authService.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
    );
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootScaffold()),
      );
    }
  }

  void _continueAsGuest() async {
    final authService = context.read<SupabaseAuthService>();
    final success = await authService.continueAsAnonymous();
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootScaffold()),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: resetEmailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resetEmailController.text.trim().isEmpty) return;
              
              final authService = context.read<SupabaseAuthService>();
              final success = await authService.resetPassword(resetEmailController.text.trim());
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Password reset email sent!' 
                        : authService.error ?? 'Failed to send reset email'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}