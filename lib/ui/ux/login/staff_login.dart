import 'package:flutter/material.dart';
import 'package:otomoto/ui/ux/login/admin_login.dart';
import 'package:otomoto/ui/ux/login/helper/navigation_helpers.dart';
import 'package:otomoto/ui/ux/login/widgets/common_login_screen.dart';
import 'package:otomoto/ui/ux/main/staff/home/staff_home_screen.dart';

class StaffLogin extends StatelessWidget {
  const StaffLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLoginScreen(
      title: "Welcome back, Staff",
      subtitle: "Enter your staff credentials",
      isAdmin: false,
      buttonColor: Colors.amber,
      sideImageColor: Colors.amber,
      textColor: Colors.black,
      logoPath: "assets/icons/otomoto_logo.png",
      onSwitchUser: () {
        Navigator.of(context).pushReplacement(fadeRouteTo(const AdminLogin()));
      },
      onLoginSuccess: (user) {
        Navigator.of(context)
            .pushReplacement(fadeRouteTo(const StaffHomeScreen()));
      },
    );
  }
}
