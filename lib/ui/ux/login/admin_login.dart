import 'package:flutter/material.dart';
import 'package:otomoto/ui/ux/login/staff_login.dart';
import 'package:otomoto/ui/ux/login/widgets/common_login_screen.dart';
import 'package:otomoto/ui/ux/login/helper/navigation_helpers.dart';
import 'package:otomoto/ui/ux/main/admin/home/admin_home_screen.dart';

class AdminLogin extends StatelessWidget {
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLoginScreen(
      title: "Welcome back, Admin",
      subtitle: "Please enter your details",
      isAdmin: true,
      buttonColor: Colors.black,
      sideImageColor: Colors.black87,
      textColor: Colors.white,
      logoPath: "assets/icons/otomoto_logo.png",
      onSwitchUser: () {
        Navigator.of(context).pushReplacement(fadeRouteTo(const StaffLogin()));
      },
      onLoginSuccess: (user) {
        Navigator.of(context)
            .pushReplacement(fadeRouteTo(const AdminHomeScreen()));
      },
    );
  }
}
