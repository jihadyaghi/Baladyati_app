import 'package:flutter/foundation.dart';
import '../models/citizen_model.dart';
import '../services/auth_service.dart';
enum AuthStatus { idle, loading, success, error }
class AuthProvider extends ChangeNotifier {
  AuthStatus   _status  = AuthStatus.idle;
  CitizenModel? _citizen;
  String?      _errorMessage;
  AuthStatus    get status       => _status;
  CitizenModel? get citizen      => _citizen;
  String?       get errorMessage => _errorMessage;
  bool          get isLoading    => _status == AuthStatus.loading;
  bool          get isLoggedIn   => _citizen != null;
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    final result = await AuthService.login(phone: phone, password: password);
    if (result.success) {
      _citizen = result.citizen;
      _status  = AuthStatus.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      _status       = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
    required int    zoneId,
    required String password,
    required String confirmPassword,
  }) async {
    setLoading();
    final result = await AuthService.register(
      firstName:       firstName,
      lastName:        lastName,
      phone:           phone,
      dateOfBirth:     dateOfBirth,
      zoneId:          zoneId,
      password:        password,
      confirmPassword: confirmPassword,
    );
    return _handleResult(result);
  }
  Future<void> logout() async {
    await AuthService.logout();
    _citizen = null;
    _status  = AuthStatus.idle;
    notifyListeners();
  }
  void clearError() {
    _errorMessage = null;
    _status       = AuthStatus.idle;
    notifyListeners();
  }
  bool _handleResult(AuthResult result) {
    if (result.success) {
      _citizen = result.citizen;
      _status  = AuthStatus.success;
    } else {
      _errorMessage = result.errorMessage;
      _status       = AuthStatus.error;
    }
    notifyListeners();
    return result.success;
  }
  void setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
