import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;
    
    // In a real app, verify token validity with backend here
    // For now, we decode or just trust it. Better: fetch profile
    try {
      final data = await ApiClient().get('/auth/me');
      _user = User.fromJson(data);
      notifyListeners();
      return true;
    } catch (e) {
      // Token likely invalid
      logout();
      return false;
    }
  }

  Future<bool> login(String mobile, String otpId, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient().post('/auth/login/verify', {
        'mobile': mobile,
        'otpId': otpId,
        'otp': otp,
      });

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  // Start login (send OTP)
  Future<Map<String, dynamic>?> loginStart(String mobile) async {
    try {
       final response = await ApiClient().post('/auth/login/start', {'mobile': mobile});
       return response; // Contains otpId and otp (for demo)
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
