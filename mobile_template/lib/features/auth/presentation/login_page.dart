import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/widgets/app_loader.dart';

import './bloc/auth_bloc.dart';
import './bloc/auth_event.dart';
import './bloc/auth_state.dart';

// ─────────────────────────────────────────────
//  Colour tokens (dark only)
// ─────────────────────────────────────────────
const _bg          = Color(0xFF0B0E17);
const _cardBg      = Color(0x0DFFFFFF);
const _cardBorder  = Color(0x17FFFFFF);
const _accentA     = Color(0xFF7C4DFF);
const _accentB     = Color(0xFF5A6EFF);
const _accentC     = Color(0xFF4C9BE8);
const _appName     = Color(0xFFE8F0FF);
const _appSub      = Color(0x80B4C8F0);
const _inputBg     = Color(0x0EFFFFFF);   // ← same for both states
const _inputBorder = Color(0x13FFFFFF);
const _inputFocus  = Color(0x997C4DFF);
const _inputText   = Color(0xFFDCE8FF);
const _inputHint   = Color(0x7278A0C8);
const _inputIcon   = Color(0x7278A0C8);
const _remText     = Color(0xBFA0B9E6);
const _checkBorder = Color(0x667C4DFF);
const _checkBg     = Color(0x147C4DFF);
const _divLine     = Color(0x12FFFFFF);
const _divText     = Color(0x6678A0C8);
const _googleBg    = Color(0x0EFFFFFF);
const _googleBdr   = Color(0x14FFFFFF);
const _googleText  = Color(0xD9B4D2FA);
const _signupText  = Color(0xB382A0D2);
const _signupLink  = Color(0xFF9370FF);

const _grad = LinearGradient(
  colors: [_accentA, _accentB, _accentC],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─────────────────────────────────────────────
//  LoginPage
// ─────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus      = FocusNode();
  final _passwordFocus      = FocusNode();

  bool _rememberMe      = false;
  bool _obscurePassword = true;

  late final AnimationController _blobCtrl;
  late final Animation<double>   _blobAnim;
  late final AnimationController _entranceCtrl;
  late final Animation<double>   _entranceFade;
  late final Animation<Offset>   _entranceSlide;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();

    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    _blobAnim = CurvedAnimation(parent: _blobCtrl, curve: Curves.easeInOut);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _entranceFade  = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _entranceCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUsername() async {
    final prefs    = await SharedPreferences.getInstance();
    final saved    = prefs.getString('username');
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember && saved != null) {
      _usernameController.text = saved;
      setState(() => _rememberMe = true);
    }
  }

  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', _usernameController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('username');
      await prefs.setBool('remember_me', false);
    }
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1C1430),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const AppLoader(
            message: "Setting up your workspace...",
            fullscreen: true,
          );
        }
        return _buildPage(context);
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Animated blobs
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _BlobPainter(_blobAnim.value),
            ),
          ),
          // Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: _buildCard(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Glass card ─────────────────────────────
  Widget _buildCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: _cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0xA6000000),
                blurRadius: 80,
                offset: Offset(0, 30),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardTop(),
              const SizedBox(height: 30),
              _InputField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                hint: 'Username',
                isFocused: _usernameFocus.hasFocus,
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.person_outline_rounded,
                    size: 20, color: _accentA),
              ),
              const SizedBox(height: 13),
              _InputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: 'Password',
                obscureText: _obscurePassword,
                isFocused: _passwordFocus.hasFocus,
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 20, color: _inputIcon),
                focusedIcon: const Icon(Icons.lock_outline_rounded,
                    size: 20, color: _accentA),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      key: ValueKey(_obscurePassword),
                      size: 20,
                      color: _inputIcon,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRememberRow(),
              const SizedBox(height: 20),
              _buildLoginButton(context),
              const SizedBox(height: 18),
              _buildDivider(),
              const SizedBox(height: 14),
              _buildGoogleButton(),
              const SizedBox(height: 20),
              _buildSignupRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card top ───────────────────────────────
  Widget _buildCardTop() {
    return const Column(
      children: [
        _LogoBox(),
        SizedBox(height: 18),
        Text(
          "NeuraCraft",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: _appName,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Enterprise RBAC System",
          style: TextStyle(fontSize: 13, color: _appSub),
        ),
      ],
    );
  }

  // ── Remember row  (no animation) ───────────
  Widget _buildRememberRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => setState(() => _rememberMe = !_rememberMe),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: _rememberMe ? _grad : null,
                color:    _rememberMe ? null : _checkBg,
                borderRadius: BorderRadius.circular(7),
                border: _rememberMe
                    ? null
                    : Border.all(color: _checkBorder, width: 2),
                boxShadow: _rememberMe
                    ? const [BoxShadow(color: Color(0x667C4DFF), blurRadius: 10)]
                    : null,
              ),
              child: _rememberMe
                  ? const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 13),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            const Text(
              "Remember me",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _remText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Login button ───────────────────────────
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _grad,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x737C4DFF),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x334C64FF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white24,
            onTap: () async {
              await _handleRememberMe();
              if (!context.mounted) return;
              context.read<AuthBloc>().add(
                    LoginRequested(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text.trim(),
                    ),
                  );
            },
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Login",
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

  // ── Divider ────────────────────────────────
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: _divLine, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "OR CONTINUE WITH",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _divText,
            ),
          ),
        ),
        Expanded(child: Divider(color: _divLine, thickness: 1)),
      ],
    );
  }

  // ── Google button ──────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: _googleBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _googleBdr, width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: const Color(0x1A7C4DFF),
                onTap: () {
                  // TODO: Google sign-in
                },
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GoogleLogo(),
                      SizedBox(width: 11),
                      Text(
                        "Continue with Google",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _googleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign-up row ────────────────────────────
  Widget _buildSignupRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontSize: 13.5, color: _signupText),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            // TODO: navigate to sign-up
          },
          child: const Text(
            "Create account",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _signupLink,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Animated logo box with pulse glow
// ─────────────────────────────────────────────
class _LogoBox extends StatefulWidget {
  const _LogoBox();
  @override
  State<_LogoBox> createState() => _LogoBoxState();
}

class _LogoBoxState extends State<_LogoBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: _grad,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(
                const Color(0x737C4DFF),
                const Color(0x997C4DFF),
                _pulse.value,
              )!,
              blurRadius: lerpDouble(36, 52, _pulse.value)!,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0x334C9BE8),
              blurRadius: lerpDouble(12, 22, _pulse.value)!,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
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
    _star(canvas, cx: 22, cy: 21, outer: 15, inner: 5,
        color: Colors.white.withOpacity(0.95));
    _star(canvas, cx: 33, cy: 15, outer: 7,  inner: 2.5,
        color: Colors.white.withOpacity(0.70));
    _star(canvas, cx: 12, cy: 30, outer: 4,  inner: 1.5,
        color: Colors.white.withOpacity(0.60));
  }

  void _star(Canvas canvas,
      {required double cx,
      required double cy,
      required double outer,
      required double inner,
      required Color color}) {
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

// ─────────────────────────────────────────────
//  Reusable input field
//  • background stays _inputBg regardless of focus
//  • only border colour and icon colour change on focus
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscureText;
  final bool isFocused;
  final Widget prefixIcon;
  final Widget focusedIcon;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.isFocused,
    required this.prefixIcon,
    required this.focusedIcon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: _inputBg,                          // ← always the same
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
          // Icon swaps colour on focus, size stays fixed
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
          Expanded(
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
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: _inputHint,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          if (suffix != null) ...[const SizedBox(width: 8), suffix!],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Background blob painter
// ─────────────────────────────────────────────
class _BlobPainter extends CustomPainter {
  final double t;
  const _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _blob(canvas,
        center: Offset(
          -60 + 25 * math.sin(t * math.pi),
          -80 + 30 * math.cos(t * math.pi * 0.7),
        ),
        radius: 220,
        color: const Color(0x487C4DFF));

    _blob(canvas,
        center: Offset(
          size.width  + 40 - 20 * math.cos(t * math.pi * 0.9),
          size.height + 40 - 30 * math.sin(t * math.pi * 1.1),
        ),
        radius: 190,
        color: const Color(0x334C9BE8));

    _blob(canvas,
        center: Offset(
          size.width  * 0.5 + 15 * math.sin(t * math.pi * 1.3),
          size.height * 0.38 + 20 * math.cos(t * math.pi * 0.8),
        ),
        radius: 150,
        color: const Color(0x247C4DFF));

    _blob(canvas,
        center: Offset(
          size.width  + 20 - 18 * math.cos(t * math.pi * 1.5),
          size.height * 0.12 + 12 * math.sin(t * math.pi),
        ),
        radius: 125,
        color: const Color(0x1F14B4A0));
  }

  void _blob(Canvas canvas,
      {required Offset center, required double radius, required Color color}) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.t != t;
}

// ─────────────────────────────────────────────
//  Google logo (four-colour sectors)
// ─────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;
    final cy   = size.height / 2;
    final r    = size.width  / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    const sectors = [
      [-45.0, 90.0, Color(0xFF4285F4)],
      [ 45.0, 90.0, Color(0xFF34A853)],
      [135.0, 90.0, Color(0xFFFBBC05)],
      [225.0, 90.0, Color(0xFFEA4335)],
    ];
    for (final s in sectors) {
      canvas.drawArc(
        rect,
        (s[0] as double) * math.pi / 180,
        (s[1] as double) * math.pi / 180,
        true,
        Paint()..color = s[2] as Color,
      );
    }

    // White donut cutout
    canvas.drawCircle(Offset(cx, cy), r * 0.62, Paint()..color = Colors.white);

    // Blue crossbar of the "G"
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.19, r * 0.98, r * 0.38),
      Paint()..color = const Color(0xFF4285F4),
    );

    // Restore inner hole
    canvas.saveLayer(rect, Paint());
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.62,
      Paint()
        ..color     = Colors.white
        ..blendMode = BlendMode.dstOut,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}