class Employee {
  final int id;
  final String name;
  final String email;
  final String department;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  // JSON data ko Employee object mein convert karna
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String? ?? 'General',
    );
  }

  // Employee object ko JSON mein convert karna
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'department': department};
  }
}
