import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../models/survey_model.dart';

class SurveyResponseScreen extends StatefulWidget {
  final int surveyId;
  final String surveyTitle;

  const SurveyResponseScreen({
    super.key,
    required this.surveyId,
    required this.surveyTitle,
  });

  @override
  State<SurveyResponseScreen> createState() => _SurveyResponseScreenState();
}

class _SurveyResponseScreenState extends State<SurveyResponseScreen> {
  final _api    = ApiService();
  SurveyDetailModel? _survey;
  bool _loading = true;
  bool _saving  = false;

  // Respuestas del usuario: questionId → answer
  final Map<int, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    _fetchSurvey();
  }

  Future<void> _fetchSurvey() async {
    try {
      final res = await _api.get(ApiConstants.surveyDetail(widget.surveyId));
      if (res.data['success'] == true) {
        final survey = SurveyDetailModel.fromJson(res.data['data']);
        setState(() {
          _survey = survey;
          // Precarga las respuestas ya guardadas (si existen)
          for (final q in survey.questions) {
            if (q.myAnswer != null) {
              if (q.type == 'rating' || q.type == 'nps') {
                _answers[q.id] = q.myAnswer!.answerRating;
              } else {
                _answers[q.id] = q.myAnswer!.answerText;
              }
            }
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  bool get _canSubmit {
    if (_survey == null) return false;
    for (final q in _survey!.questions) {
      if (q.required) {
        final a = _answers[q.id];
        if (a == null || (a is String && a.trim().isEmpty)) return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas obligatorias'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final answers = _survey!.questions.map((q) {
      final val = _answers[q.id];
      return {
        'question_id':   q.id,
        'answer_text':   (q.type == 'rating' || q.type == 'nps') ? null : val?.toString(),
        'answer_rating': (q.type == 'rating' || q.type == 'nps') ? val : null,
      };
    }).toList();

    try {
      final res = await _api.post(
        ApiConstants.surveyRespond(widget.surveyId),
        data: {'answers': answers},
      );
      if (!mounted) return;
      if (res.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por responder la encuesta!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surveyTitle, overflow: TextOverflow.ellipsis),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _survey == null
              ? const Center(child: Text('No se pudo cargar la encuesta'))
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    final questions = _survey!.questions;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: questions.length + 1,
      itemBuilder: (_, i) {
        if (i == questions.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar Respuestas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          );
        }

        return _buildQuestion(questions[i], i)
            .animate()
            .fadeIn(delay: (i * 60).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildQuestion(SurveyQuestionModel q, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26, height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q.question + (q.required ? ' *' : ''),
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInput(q),
        ],
      ),
    );
  }

  Widget _buildInput(SurveyQuestionModel q) {
    switch (q.type) {
      case 'text':
        return _buildTextInput(q);
      case 'multiple_choice':
        return _buildMultipleChoice(q);
      case 'rating':
        return _buildRating(q, max: 5);
      case 'nps':
        return _buildNps(q);
      case 'yes_no':
        return _buildYesNo(q);
      default:
        return _buildTextInput(q);
    }
  }

  Widget _buildTextInput(SurveyQuestionModel q) {
    return TextField(
      onChanged: (v) => setState(() => _answers[q.id] = v),
      controller: TextEditingController(text: _answers[q.id]?.toString() ?? ''),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta...',
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: context.borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: context.borderCol),
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(SurveyQuestionModel q) {
    if (q.options == null || q.options!.isEmpty) return const SizedBox();
    final selected = _answers[q.id] as String?;
    return Column(
      children: q.options!.map((opt) {
        final isSel = selected == opt;
        return GestureDetector(
          onTap: () => setState(() => _answers[q.id] = opt),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? AppTheme.primaryOrange.withValues(alpha: 0.12) : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: isSel ? AppTheme.primaryOrange : context.borderCol),
            ),
            child: Row(children: [
              Icon(isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20, color: isSel ? AppTheme.primaryOrange : AppTheme.textTertiary),
              const SizedBox(width: 10),
              Expanded(child: Text(opt, style: TextStyle(color: isSel ? AppTheme.primaryOrange : null, fontWeight: isSel ? FontWeight.w600 : FontWeight.normal))),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRating(SurveyQuestionModel q, {required int max}) {
    final rating = (_answers[q.id] as int?) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(max, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _answers[q.id] = star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
              size: 40,
              color: star <= rating ? const Color(0xFFF59E0B) : AppTheme.textTertiary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNps(SurveyQuestionModel q) {
    final sel = _answers[q.id] as int?;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Muy malo', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.errorColor)),
            Text('Excelente', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.successColor)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: List.generate(11, (i) {
            final isSel = sel == i;
            final color = i <= 6 ? AppTheme.errorColor : (i <= 8 ? AppTheme.warningColor : AppTheme.successColor);
            return GestureDetector(
              onTap: () => setState(() => _answers[q.id] = i),
              child: Container(
                width: 40, height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSel ? color : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSel ? color : color.withValues(alpha: 0.3)),
                ),
                child: Text('$i', style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.white : color, fontSize: 13)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildYesNo(SurveyQuestionModel q) {
    final sel = _answers[q.id] as String?;
    return Row(children: [
      Expanded(child: _yesNoBtn(q, 'Sí', AppTheme.successColor, sel == 'Sí')),
      const SizedBox(width: 12),
      Expanded(child: _yesNoBtn(q, 'No', AppTheme.errorColor, sel == 'No')),
    ]);
  }

  Widget _yesNoBtn(SurveyQuestionModel q, String label, Color color, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _answers[q.id] = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: selected ? color : context.borderCol, width: selected ? 2 : 1),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? color : AppTheme.textTertiary, fontSize: 16)),
      ),
    );
  }
}
