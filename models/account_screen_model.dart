class EmployeeModel {
  final String empId;
  final String empName;
  final String mobileNo;
  final String department;
  final String? imagePath;
 
 
  EmployeeModel({
    required this.empId,
    required this.empName,
    required this.mobileNo,
    required this.department,
    this.imagePath,
  });
 
  Map<String, dynamic> toMap() {
    return {
      'employee_id': empId,     // ✅ must match DB column
      'employee_name': empName, // ✅ must match DB column
      'mobile_no': mobileNo,
      'department': department,
      'image_path': imagePath,
    };
  }
 
factory EmployeeModel.fromMap(Map<String, dynamic> map) {
  return EmployeeModel(
    empId: map['employee_id']?.toString() ?? '',
    empName: map['employee_name']?.toString() ?? '',
    mobileNo: map['mobile_no']?.toString() ?? '',
    department: map['department']?.toString() ?? '',
    imagePath: map['image_path']?.toString(),
  );
}
 
}
 
 