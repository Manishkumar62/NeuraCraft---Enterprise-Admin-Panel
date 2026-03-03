import 'package:flutter/foundation.dart';
import '../../features/menu/domain/models/module_model.dart';

class SessionManager extends ChangeNotifier {
  Map<String, dynamic>? _user;
  List<AppModule> _modules = [];

  bool _isBootstrapped = false; 

  bool get isAuthenticated => _user != null;
  bool get isBootstrapped => _isBootstrapped;

  Map<String, dynamic>? get user => _user;

  List<AppModule> get modules => _modules;

  void setSession({
    required Map<String, dynamic> user,
    required List<AppModule> modules,
  }) {
    _user = user;
    _modules = modules;
    notifyListeners();
  }

  void clearSession() {
    _user = null;
    _modules = [];
    notifyListeners();
  }

  void markBootstrapped() {
    _isBootstrapped = true;
    notifyListeners();
  }
}