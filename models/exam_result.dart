
class ExamResult {
  final int? id;
  final String empId;
  final String empName;
  final String subject;
  final String module;
  final int questionId;
  final String questionText;
  final String correctAnswer;
  final String attempted; // TEXT so we can store A/B/C/D or full answer
  final String imagePath;
  final int totalQuestions;
 
  ExamResult({
    this.id,
    required this.empId,
    required this.empName,
    required this.subject,
    required this.module,
    required this.questionId,
    required this.questionText,
    required this.correctAnswer,
    required this.attempted,
    required this.imagePath,
    required this.totalQuestions,
  });
 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empId': empId,
      'empName': empName,
      'subject': subject,
      'module': module,
      'questionId': questionId,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'attempted': attempted,
      'imagePath': imagePath,
      'totalQuestions': totalQuestions,
    };
  }
 
  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      empId: map['empId'],
      empName: map['empName'],
      subject: map['subject'],
      module: map['module'],
      questionId: map['questionId'],
      questionText: map['questionText'],
      correctAnswer: map['correctAnswer'],
      attempted: map['attempted'],
      imagePath: map['imagePath'],
      totalQuestions: map['totalQuestions'],
    );
  }
}
 
class ExamResultSummary {
  final String empId;
  final String empName;
  final String subject;
  final String module;
  final int totalQuestions;
  final int attempted;
  final int correct;
  final int score;
  final double percentage;
  final String status; // Pass / Fail
  final String date;
 
  ExamResultSummary({
    required this.empId,
    required this.empName,
    required this.subject,
    required this.module,
    required this.totalQuestions,
    required this.attempted,
    required this.correct,
    required this.score,
    required this.percentage,
    required this.status,
    required this.date,
  });
 
  Map<String, dynamic> toMap() => {
        'empId': empId,
        'empName':empName,
        'subject': subject,
        'module': module,
        'totalQuestions': totalQuestions,
        'attempted': attempted,
        'correct': correct,
        'score': score,
        'percentage': percentage,
        'status': status,
        'date': date,
      };
 
  factory ExamResultSummary.fromMap(Map<String, dynamic> map) {
    return ExamResultSummary(
        empId: map['empId'],
        empName: map['empName'],
        subject: map['subject'],
        totalQuestions: map['totalQuestions'],
        attempted: map['attempted'],
        correct: map['correct'],
        score: map['score'],
        percentage: map['percentage'],
        status: map['status'],
        date: map['date'],
        module: map['module']);
  }
}
 
 
