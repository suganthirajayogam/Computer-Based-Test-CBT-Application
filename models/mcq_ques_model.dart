class MCQQuestion {
  final int? id;
  final String question;
  final String? questionImagePath;
  final String optionA;
  final String? optionAImagePath;
  final String optionB;
  final String? optionBImagePath;
  final String optionC;
  final String? optionCImagePath;
  final String optionD;
  final String? optionDImagePath;
  final String correctAnswer;
  final String subject;

  MCQQuestion({
    this.id,
    required this.question,
    this.questionImagePath,
    required this.optionA,
    this.optionAImagePath,
    required this.optionB,
    this.optionBImagePath,
    required this.optionC,
    this.optionCImagePath,
    required this.optionD,
    this.optionDImagePath,
    required this.correctAnswer,
    required this.subject,
  });

factory MCQQuestion.fromMap(Map<String, dynamic> map) {
  return MCQQuestion(
    id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
    question: map['questionText'],
    questionImagePath: map['questionImagePath'],
    optionA: map['optionA'],
    optionAImagePath: map['optionAImagePath'],
    optionB: map['optionB'],
    optionBImagePath: map['optionBImagePath'],
    optionC: map['optionC'],
    optionCImagePath: map['optionCImagePath'],
    optionD: map['optionD'],
    optionDImagePath: map['optionDImagePath'],
    correctAnswer: map['correctAnswer'],
    subject: map['subject'],
  );
}


  Map<String, dynamic> toMap() {
    final map = {
      'questionText': question,
      'questionImagePath': questionImagePath,
      'optionA': optionA,
      'optionAImagePath': optionAImagePath,
      'optionB': optionB,
      'optionBImagePath': optionBImagePath,
      'optionC': optionC,
      'optionCImagePath': optionCImagePath,
      'optionD': optionD,
      'optionDImagePath': optionDImagePath,
      'correctAnswer': correctAnswer,
      'subject': subject,
    };
    if (id != null) {
  map['id'] = id.toString(); // ✅ convert int to string
}

    return map;
  }
}
