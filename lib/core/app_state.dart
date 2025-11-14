import 'package:flutter/material.dart';
import '../models/test_result.dart';

// Lightweight global state holder using InheritedNotifier.

class AppState extends ChangeNotifier {
  bool isPremium;
  bool isLoggedIn;
  String? displayName;
  String? currentUserId;
  final List<TestResult> results;

  AppState({this.isPremium = false, this.isLoggedIn = false, this.displayName, this.currentUserId, List<TestResult>? seedResults})
      : results = List<TestResult>.from(seedResults ?? []);

  void togglePremium() {
    isPremium = !isPremium;
    notifyListeners();
  }

  void addResult(TestResult r) {
    results.insert(0, r);
    notifyListeners();
  }

  // Auth (mock)
  void login({required String email, required String? name, String? userId}) {
    isLoggedIn = true;
    displayName = name ?? email.split('@').first;
    currentUserId = userId;
    notifyListeners();
  }

  void register({required String name, required String email, String? userId}) {
    isLoggedIn = true;
    displayName = name;
    currentUserId = userId;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    currentUserId = null;
    isPremium = false;
    results.clear();
    notifyListeners();
  }

  void setPremium(bool v) {
    isPremium = v;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState notifier, required Widget child})
      : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
