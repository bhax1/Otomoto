import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  final String primaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final VoidCallback onForgotPasswordPressed;

  const AuthFooter({
    super.key,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    required this.onForgotPasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: onPrimaryButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                primaryButtonText == "Admin" ? Colors.black : Colors.amber,
          ),
          child: Text(
            primaryButtonText,
            style: TextStyle(
              color: primaryButtonText == "Admin" ? Colors.white : Colors.black,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onForgotPasswordPressed,
          child: const Text(
            "Forgot password?",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
