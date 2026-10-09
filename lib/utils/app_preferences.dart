import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee.dart';

class AppPreferences {
  static const String _loginKey = 'is_logged_in';
  static const String _emailKey = 'user_email';
  static const String _employeesKey = 'saved_employees';

  // Login session save karna
  static Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_loginKey, true);
    await prefs.setString(_emailKey, email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_loginKey);
    await prefs.remove(_emailKey);
  }

  // Employee list permanently save karna
  static Future<void> saveEmployees(List<Employee> employees) async {
    final prefs = await SharedPreferences.getInstance();

    final employeeData = employees
        .map((employee) => employee.toJson())
        .toList();

    await prefs.setString(_employeesKey, jsonEncode(employeeData));
  }

  // Saved employee list load karna
  // null ka matlab: abhi tak koi list save nahi hui
  static Future<List<Employee>?> getSavedEmployees() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_employeesKey)) {
      return null;
    }

    final savedData = prefs.getString(_employeesKey);

    if (savedData == null) {
      return null;
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return Employee.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }
}
