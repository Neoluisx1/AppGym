class SurveyModel {
  final int id;
  final String title;
  final String? description;
  final int questionsCount;
  final bool isCompleted;
  final String? endDate;
  final String createdAt;

  const SurveyModel({
    required this.id,
    required this.title,
    this.description,
    required this.questionsCount,
    required this.isCompleted,
    this.endDate,
    required this.createdAt,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> j) => SurveyModel(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        questionsCount: j['questions_count'] ?? 0,
        isCompleted: j['is_completed'] == true,
        endDate: j['end_date'],
        createdAt: j['created_at'] ?? '',
      );
}

class SurveyQuestionModel {
  final int id;
  final String question;
  final String type; // text, multiple_choice, rating, yes_no, nps
  final List<String>? options;
  final bool required;
  final int order;
  final SurveyAnswerModel? myAnswer;

  const SurveyQuestionModel({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    required this.required,
    required this.order,
    this.myAnswer,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> j) => SurveyQuestionModel(
        id: j['id'],
        question: j['question'] ?? '',
        type: j['type'] ?? 'text',
        options: j['options'] != null
            ? List<String>.from(j['options'] as List)
            : null,
        required: j['required'] == true,
        order: j['order'] ?? 0,
        myAnswer: j['my_answer'] != null
            ? SurveyAnswerModel.fromJson(j['my_answer'])
            : null,
      );
}

class SurveyAnswerModel {
  final String? answerText;
  final int? answerRating;

  const SurveyAnswerModel({this.answerText, this.answerRating});

  factory SurveyAnswerModel.fromJson(Map<String, dynamic> j) => SurveyAnswerModel(
        answerText: j['answer_text'],
        answerRating: j['answer_rating'],
      );
}

class SurveyDetailModel {
  final int id;
  final String title;
  final String? description;
  final String? endDate;
  final List<SurveyQuestionModel> questions;

  const SurveyDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.endDate,
    required this.questions,
  });

  factory SurveyDetailModel.fromJson(Map<String, dynamic> j) => SurveyDetailModel(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        endDate: j['end_date'],
        questions: (j['questions'] as List)
            .map((q) => SurveyQuestionModel.fromJson(q))
            .toList(),
      );
}
