class VisionQuestionModel {
  final int? id;
  final String module;
  final String? questionText;
  final String? imagePath;
  final String? videoPath;
  final String correctAnswer;
  final List<String> reasons;
  final List<String> allReasons; // ✅ NEW

  VisionQuestionModel({
    this.id,
    required this.module,
    this.questionText,
    this.imagePath,
    this.videoPath,
    required this.correctAnswer,
    required this.reasons,
    required this.allReasons, // ✅ NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module': module,
      'question_text': questionText,
      'image_path': imagePath,
      'video_path': videoPath,
      'correct_answer': correctAnswer,
      'reasons': reasons.join(','),        // Save selected
      'allreasons': allReasons.join(','),  // Save all
    };
  }

  factory VisionQuestionModel.fromMap(Map<String, dynamic> map) {
    return VisionQuestionModel(
      id: map['id'],
      module: map['module'],
      questionText: map['question_text'],
      imagePath: map['image_path'],
      videoPath: map['video_path'],
      correctAnswer: map['correct_answer'],
      reasons: map['reasons']?.toString().split(',') ?? [],
      allReasons: map['allreasons']?.toString().split(',') ?? [], // ✅ NEW
    );
  }
}
