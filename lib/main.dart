import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/ui/main/admin/home/admin_home_screen.dart';
import 'package:otomoto/ui/main/staff/home/staff_home_screen.dart';
import 'package:otomoto/core/models/user_model.dart';
import 'package:otomoto/auth/providers/auth_service_provider.dart';
import 'package:otomoto/firebase_options.dart';
import 'package:otomoto/ui/login/staff_login.dart';
import 'package:otomoto/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:window_manager/window_manager.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize window manager for non-web desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(1050, 600));
    windowManager.setSize(const Size(1050, 600)); // Set default size
    windowManager.setAlignment(Alignment.center); // Center the window
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late DateTime _exitTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to app lifecycle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up observer
    _timer?.cancel(); // Cancel timer if exists
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is moving to the background (about to exit or minimize)
      _startTimerOnExit();
    } else if (state == AppLifecycleState.resumed) {
      // App is coming back to the foreground
      _stopTimerOnResume();
    }
    super.didChangeAppLifecycleState(state);
  }

  void _startTimerOnExit() {
    _exitTime = DateTime.now(); // Capture the time when app exits
    print("App exited at: $_exitTime");

    // Start a timer, you could save session data or calculate duration here
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      print("Timer running while app is in background...");
      // Perform any background task like saving the session or tracking duration
    });
  }

  void _stopTimerOnResume() {
    if (_timer != null) {
      _timer?.cancel(); // Stop the timer when app comes to the foreground
      print("Timer stopped. App resumed at: ${DateTime.now()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otomoto Car Rental',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream to listen for authentication state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasData) {
          return const _UserAuthenticatedScreen();
        } else {
          return const StaffLogin(); // User is not authenticated
        }
      },
    );
  }
}

class _UserAuthenticatedScreen extends ConsumerWidget {
  const _UserAuthenticatedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return FutureBuilder<UserModel?>(
      future: authService.validateCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        return snapshot.hasData ? const _RoleBasedScreen() : const StaffLogin();
      },
    );
  }
}

class _RoleBasedScreen extends ConsumerWidget {
  const _RoleBasedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    return FutureBuilder<bool>(
      // FutureBuilder to check the user’s role
      future: authService.hasAdminRole(),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // Return the appropriate screen based on the user's role
        return roleSnapshot.data == true
            ? const AdminHomeScreen() // Admin role
            : const StaffHomeScreen(); // Staff/normal user screen
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust spinner size based on screen size
            double size = constraints.maxWidth < 600 ? 30.0 : 50.0;

            return SpinKitThreeBounce(
              color: Colors.white,
              size: size,
            );
          },
        ),
      ),
    );
  }
}
