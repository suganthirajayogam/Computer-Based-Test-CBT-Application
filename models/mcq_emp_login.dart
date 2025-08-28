class MCQEmployee {
  final String empId;
  final String name;
  final String department;
  final String dob;
  final String subject;
  final String email;
  final String phone;

  MCQEmployee({
    required this.empId,
    required this.name,
    required this.department,
    required this.dob,
    required this.subject,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'empId': empId,
      'name': name,
      'department': department,
      'dob': dob,
      'subject': subject,
      'email': email,
      'phone': phone,
    };
  }

  factory MCQEmployee.fromMap(Map<String, dynamic> map) {
    return MCQEmployee(
      empId: map['empId'],
      name: map['name'],
      department: map['department'],
      dob: map['dob'],
      subject: map['subject'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}
// 