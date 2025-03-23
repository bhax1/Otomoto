import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otomoto/admin/screens/admin_login.dart';
import 'package:otomoto/logic/connection_checker.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode(); // Add focus node
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    String staffId = _idController.text.trim();
    String password = _passwordController.text;

    bool isOffline =
        Provider.of<ConnectionChecker>(context, listen: false).isOffline;

    if (isOffline) {
      _showErrorMessage("No Internet Connection!");
      setState(() => _isLoading = false);
    } else {
      try {
        DocumentSnapshot staffDoc = await FirebaseFirestore.instance
            .collection('staffs')
            .doc(staffId)
            .get();

        setState(() => _isLoading = false);

        if (staffDoc.exists) {
          String storedPassword = staffDoc['password'];

          if (password == storedPassword) {
            _showSuccessMessage("Login Successful!");
          } else {
            _showErrorMessage("Invalid credentials");
          }
        } else {
          _showErrorMessage("Staff ID not found!");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorMessage("Login failed: ${e.toString()}");
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
            _login(); // Trigger login on Enter press
          }
        },
        child: Stack(
          children: [
            Row(
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
                            _buildTextField(
                                _idController, 'Staff ID', false, theme),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _passwordController, 'Password', true, theme),
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
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              ),
          ],
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
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Sign in", style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildSideImage(ThemeData theme) {
    return Expanded(
      child: Container(
        color: theme.primaryColor,
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
        Text("Welcome back",
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminLogin()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
          child: const Text("Admin", style: TextStyle(color: Colors.white)),
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
