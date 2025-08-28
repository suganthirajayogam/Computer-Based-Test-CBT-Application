class VisionExamResultModel {
  final int? id;
  final String empId;
  final String empName;
  final String module;
  final int questionId;
  final String questionText;
  final String correctAnswer;
  final String selectedAnswer;
  final String selectedReasons;

  VisionExamResultModel({
    this.id,
    required this.empId,
    required this.empName,
    required this.module,
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.selectedReasons,
  });

  factory VisionExamResultModel.fromMap(Map<String, dynamic> map) {
    return VisionExamResultModel(
      id: map['id'],
      empId: map['empId'],
      empName: map['empName'],
      module: map['module'],
      questionId: map['questionId'],
      questionText: map['questionText'],
      correctAnswer: map['correctAnswer'],
      selectedAnswer: map['selectedAnswer'],
      selectedReasons: map['selectedReasons'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empId': empId,
      'empName': empName,
      'module': module,
      'questionId': questionId,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'selectedAnswer': selectedAnswer,
      'selectedReasons': selectedReasons,
    };
  }
}
class VisionExamResultSummaryModel {
  final int? id;
  final String empId;
  final String empName;
  final String module;
  final int score;
  final double percentage;
  final String status;
  final String date;

  VisionExamResultSummaryModel({
    this.id,
    required this.empId,
    required this.empName,
    required this.module,
    required this.score,
    required this.percentage,
    required this.status,
    required this.date,
  });

  factory VisionExamResultSummaryModel.fromMap(Map<String, dynamic> map) {
    return VisionExamResultSummaryModel(
      id: map['id'],
      empId: map['empId'],
      empName: map['empName'],
      module: map['module'],
      score: map['score'],
      percentage: map['percentage'],
      status: map['status'],
      date: map['date'],
    );
  }

  get dept => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empId': empId,
      'empName': empName,
      'module': module,
      'score': score,
      'percentage': percentage,
      'status': status,
      'date': date,
    };
  }
}
