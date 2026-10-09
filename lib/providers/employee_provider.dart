import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../services/api_service.dart';
import '../utils/app_preferences.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _isLocalEmployee(int id) => id > 10;

  Future<void> _persistEmployees() async {
    await AppPreferences.saveEmployees(_employees);
  }

  // Saved list available ho toh wahi load karo.
  // First launch par hi API se initial list fetch karo.
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedEmployees = await AppPreferences.getSavedEmployees();

      if (savedEmployees != null) {
        _employees = savedEmployees;
      } else {
        _employees = await _apiService.getEmployees();
        await _persistEmployees();
      }
    } catch (error) {
      _errorMessage = 'Employees load nahi ho paye.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // POST: Employee add karna
  Future<void> addEmployee(Employee employee) async {
    try {
      final created = await _apiService.addEmployee(employee);

      final maxId = _employees.fold<int>(
        10,
        (max, item) => item.id > max ? item.id : max,
      );

      final newEmployee = Employee(
        id: maxId + 1,
        name: created.name,
        email: created.email,
        department: employee.department,
      );

      _employees = [..._employees, newEmployee];

      await _persistEmployees();

      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Employee add nahi ho paya.';
      notifyListeners();
      rethrow;
    }
  }

  // PUT: Employee update karna
  Future<void> updateEmployee(Employee employee) async {
    try {
      if (!_isLocalEmployee(employee.id)) {
        await _apiService.updateEmployee(employee);
      }

      _employees = _employees.map((item) {
        return item.id == employee.id ? employee : item;
      }).toList();

      await _persistEmployees();

      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Employee update nahi ho paya.';
      notifyListeners();
      rethrow;
    }
  }

  // DELETE: Employee remove karna
  Future<void> deleteEmployee(int id) async {
    try {
      if (!_isLocalEmployee(id)) {
        await _apiService.deleteEmployee(id);
      }

      _employees.removeWhere((employee) => employee.id == id);

      await _persistEmployees();

      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Employee delete nahi ho paya.';
      notifyListeners();
      rethrow;
    }
  }
}
