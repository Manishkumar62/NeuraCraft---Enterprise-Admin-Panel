import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_loader.dart';
import './bloc/auth_bloc.dart';
import './bloc/auth_event.dart';
import './bloc/auth_state.dart';

const _bg = Color(0xFF0B0E17);
const _cardBg = Color(0x0DFFFFFF);
const _cardBorder = Color(0x17FFFFFF);
const _accentA = Color(0xFF7C4DFF);
const _accentB = Color(0xFF5A6EFF);
const _accentC = Color(0xFF4C9BE8);
const _appName = Color(0xFFE8F0FF);
const _appSub = Color(0x80B4C8F0);
const _inputBg = Color(0x0EFFFFFF);
const _inputBorder = Color(0x13FFFFFF);
const _inputFocus = Color(0x997C4DFF);
const _inputText = Color(0xFFDCE8FF);
const _inputHint = Color(0x7278A0C8);
const _inputIcon = Color(0x7278A0C8);
const _divLine = Color(0x12FFFFFF);
const _signupText = Color(0xB382A0D2);
const _signupLink = Color(0xFF9370FF);

const _grad = LinearGradient(
  colors: [_accentA, _accentB, _accentC],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1430),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _submitSignup() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all required fields');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    context.read<AuthBloc>().add(
          SignupRequested(
            username: username,
            email: email,
            password: password,
            passwordConfirm: confirmPassword,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          _showMessage(state.message);
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const AppLoader(
            message: "Creating your account...",
            fullscreen: true,
          );
        }
        return _buildPage(context);
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: const _BlobPainter(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _buildCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: _cardBorder),
          ),
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardTop(),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _InputField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      hint: 'First name',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: _inputIcon),
                      focusedIcon: const Icon(Icons.badge_outlined, size: 20, color: _accentA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InputField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      hint: 'Last name',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 20, color: _inputIcon),
                      focusedIcon: const Icon(Icons.badge_rounded, size: 20, color: _accentA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                hint: 'Username',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.person_outline_rounded, size: 20, color: _accentA),
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _emailController,
                focusNode: _emailFocus,
                hint: 'Email address',
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.alternate_email_rounded, size: 20, color: _accentA),
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                hint: 'Phone number',
                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.phone_outlined, size: 20, color: _accentA),
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'Password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: _accentA),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      key: ValueKey(_obscurePassword),
                      size: 20,
                      color: _inputIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                hint: 'Confirm password',
                obscureText: _obscureConfirmPassword,
                prefixIcon: const Icon(Icons.verified_user_outlined, size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.verified_user_outlined, size: 20, color: _accentA),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(_obscureConfirmPassword),
                      size: 20,
                      color: _inputIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildSignupButton(),
              const SizedBox(height: 18),
              const Divider(color: _divLine, thickness: 1),
              const SizedBox(height: 18),
              _buildLoginRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTop() {
    return const Column(
      children: [
        _LogoBox(),
        SizedBox(height: 18),
        Text(
          "Create account",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: _appName,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Get started with your Viewer workspace",
          style: TextStyle(fontSize: 13, color: _appSub),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _grad,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white24,
            onTap: _submitSignup,
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Create account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
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

  Widget _buildLoginRow(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(fontSize: 13.5, color: _signupText),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.go('/login'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              "Sign in",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _signupLink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: _grad,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0x4DFFFFFF), Colors.transparent],
                begin: Alignment(-0.8, -0.8),
                end: Alignment(0.5, 0.5),
              ),
            ),
          ),
          Center(
            child: CustomPaint(
              size: const Size(44, 44),
              painter: _SparklesPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _star(canvas, cx: 22, cy: 21, outer: 15, inner: 5, color: Colors.white.withOpacity(0.95));
    _star(canvas, cx: 33, cy: 15, outer: 7, inner: 2.5, color: Colors.white.withOpacity(0.70));
    _star(canvas, cx: 12, cy: 30, outer: 4, inner: 1.5, color: Colors.white.withOpacity(0.60));
  }

  void _star(
    Canvas canvas, {
    required double cx,
    required double cy,
    required double outer,
    required double inner,
    required Color color,
  }) {
    const pts = 4;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (math.pi / pts) * i - math.pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final Widget prefixIcon;
  final Widget focusedIcon;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.prefixIcon,
    required this.focusedIcon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _inputText,
          height: 1.4,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ).copyWith(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: _inputHint,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFocused ? _inputFocus : _inputBorder,
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: _accentA.withOpacity(0.10),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isFocused
                      ? KeyedSubtree(key: const ValueKey('f'), child: focusedIcon)
                      : KeyedSubtree(key: const ValueKey('u'), child: prefixIcon),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: child!),
              if (suffix != null) ...[const SizedBox(width: 8), suffix!],
            ],
          ),
        );
      },
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _blob(
      canvas,
      center: Offset(
        -35,
        -55,
      ),
      radius: 180,
      color: const Color(0x487C4DFF),
    );

    _blob(
      canvas,
      center: Offset(
        size.width + 55,
        size.height + 55,
      ),
      radius: 150,
      color: const Color(0x334C9BE8),
    );
  }

  void _blob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => false;
}
