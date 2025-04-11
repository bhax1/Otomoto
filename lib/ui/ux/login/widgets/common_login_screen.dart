import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otomoto/auth/errors/auth_exceptions.dart';
import 'package:otomoto/core/models/user_model.dart';
import 'package:otomoto/auth/providers/auth_service_provider.dart';
import 'package:otomoto/ui/ux/login/widgets/auth_footer.dart';
import 'package:otomoto/ui/ux/login/widgets/auth_header.dart';
import 'package:otomoto/ui/ux/login/widgets/auth_text_field.dart';

class CommonLoginScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final bool isAdmin;
  final Color buttonColor;
  final Color sideImageColor;
  final Color textColor;
  final String logoPath;
  final VoidCallback onSwitchUser;
  final void Function(UserModel) onLoginSuccess;

  const CommonLoginScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isAdmin,
    required this.buttonColor,
    required this.sideImageColor,
    required this.textColor,
    required this.logoPath,
    required this.onSwitchUser,
    required this.onLoginSuccess,
  });

  @override
  ConsumerState<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends ConsumerState<CommonLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    try {
      final user = await authService.authenticateUser(
        _idController.text.trim(),
        _passwordController.text.trim(),
        isAdmin: widget.isAdmin,
      );

      widget.onLoginSuccess(user!);
    } on AuthException catch (e) {
      _showError(e.message);
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Firebase authentication error");
    } catch (e) {
      _showError("An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Opps"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _login();
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading ? _buildLoading() : _buildLoginFormLayout(context),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      key: const ValueKey(1),
      color: widget.buttonColor,
      child: const Center(
        child: SpinKitFadingCircle(color: Colors.white, size: 50),
      ),
    );
  }

  Widget _buildLoginFormLayout(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    if (isWideScreen) {
      return Row(
        key: const ValueKey(2),
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(32.0), child: _buildForm())),
          _buildSideImage(),
        ],
      );
    }

    return SingleChildScrollView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset(widget.logoPath, width: 200),
          const SizedBox(height: 20),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthHeader(title: widget.title, subtitle: widget.subtitle),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _idController,
            label: 'Email / Username',
            isPassword: false,
            obscureText: false,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            isPassword: true,
            obscureText: _obscurePassword,
            onVisibilityChanged: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 10),
          AuthFooter(
            primaryButtonText: widget.isAdmin ? "Staff" : "Admin",
            onPrimaryButtonPressed: widget.onSwitchUser,
            onForgotPasswordPressed: () {},
          ),
          const SizedBox(height: 20),
          _buildSignInButton(),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text("Sign in", style: TextStyle(color: widget.textColor)),
        ),
      ),
    );
  }

  Widget _buildSideImage() {
    return Expanded(
      child: Container(
        color: widget.sideImageColor,
        child: Center(child: Image.asset(widget.logoPath, width: 500)),
      ),
    );
  }
}
