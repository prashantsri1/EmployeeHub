import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET: Employees ki list fetch karna
  Future<List<Employee>> getEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return Employee(
          id: item['id'] as int,
          name: item['name'] as String,
          email: item['email'] as String,
          department: 'General',
        );
      }).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  // POST: Naya employee add karna
  Future<Employee> addEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': employee.name, 'email': employee.email}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Employee(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
        department: employee.department,
      );
    } else {
      throw Exception('Failed to add employee');
    }
  }

  // PUT: Existing employee update karna
  Future<Employee> updateEmployee(Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${employee.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': employee.name, 'email': employee.email}),
    );

    if (response.statusCode == 200) {
      return employee;
    } else {
      throw Exception('Failed to update employee');
    }
  }

  // DELETE: Employee delete karna

  Future<void> deleteEmployee(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete employee. Status: ${response.statusCode}',
      );
    }
  }
}
