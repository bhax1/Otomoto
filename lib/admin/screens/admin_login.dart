import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otomoto/staff/screens/staff_login.dart';
import 'package:otomoto/logic/connection_checker.dart';
import 'package:otomoto/admin/screens/home_screen.dart';
import 'package:provider/provider.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode(); // Add focus node
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    String adminId = _idController.text.trim();
    String password = _passwordController.text;

    bool isOffline =
        Provider.of<ConnectionChecker>(context, listen: false).isOffline;

    if (isOffline) {
      _showErrorMessage("No Internet Connection!");
      setState(() => _isLoading = false);
    } else {
      try {
        DocumentSnapshot staffDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(adminId)
            .get();

        setState(() => _isLoading = false);

        if (staffDoc.exists) {
          String storedPassword = staffDoc['password'];

          if (password == storedPassword) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          } else {
            _showErrorMessage("Invalid credentials");
          }
        } else {
          _showErrorMessage("Admin ID not found!");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorMessage("Login failed: ${e.toString()}");
      }
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _login();
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading
              ? Container(
                  key: const ValueKey(
                      1),
                  color: Colors.amber,
                  child: const Center(
                    child: SpinKitFadingCircle(color: Colors.white, size: 50.0),
                  ),
                )
              : Stack(
                  children: [
                    Row(
                      key: const ValueKey(
                          2),
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Header(),
                                    const SizedBox(height: 20),
                                    _buildTextField(_idController, 'Admin ID',
                                        false, theme),
                                    const SizedBox(height: 20),
                                    _buildTextField(_passwordController,
                                        'Password', true, theme),
                                    const SizedBox(height: 10),
                                    const _ForgotPass(),
                                    const SizedBox(height: 20),
                                    _buildSignInButton(theme),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildSideImage(theme),
                      ],
                    ),
                    _buildOfflineIndicator(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool isPassword, ThemeData theme) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      cursorColor: theme.primaryColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter your $label' : null,
    );
  }

  Widget _buildSignInButton(ThemeData theme) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Sign in", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSideImage(ThemeData theme) {
    return Expanded(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Image.asset("assets/icons/otomoto_logo.png", width: 500),
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Consumer<ConnectionChecker>(
      builder: (context, connection, child) {
        return Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: connection.isOffline ? Colors.red : Colors.green,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: connection.isOffline ? Colors.red : Colors.green,
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  connection.isOffline ? "Offline" : "Online",
                  style: TextStyle(
                    color: connection.isOffline ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome back, Admin",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Please enter your details",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

class _ForgotPass extends StatelessWidget {
  const _ForgotPass();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LoginScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
          ),
          child: const Text("Staff", style: TextStyle(color: Colors.black)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text("Forgot password?",
              style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }
}
