class Employee {
  int? id;
  String employeeId;
  String employeeName;
  String module;
 
  Employee({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.module,
  });
 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'module': module,
    };
  }
 
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      employeeId: map['employee_id'],
      employeeName: map['employee_name'],
      module: map['module'] ?? '',
    );
  }
 
  @override
  String toString() {
    return 'Employee(id: $id, employeeId: $employeeId, employeeName: $employeeName, module: $module)';
  }
}
 
 