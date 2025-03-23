import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectionChecker with ChangeNotifier {
  bool _isOffline = false; // Start assuming online
  bool get isOffline => _isOffline;

  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  Timer? _timer; // Store the timer reference

  ConnectionChecker() {
    _initialize();
  }

  void _initialize() {
    _checkConnection(); // Initial check
    _startRealTimeMonitoring();
  }

  void _startRealTimeMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    bool newStatus;
    try {
      final result = await InternetAddress.lookup('google.com');
      newStatus = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      newStatus = false; // Offline if exception occurs
    }

    if (_isOffline != !newStatus) {
      _isOffline = !newStatus;
      _connectionStreamController.add(_isOffline);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when disposing
    _connectionStreamController.close();
    super.dispose();
  }
}
