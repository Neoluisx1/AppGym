import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../models/survey_model.dart';
import 'survey_response_screen.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  final _api = ApiService();
  List<SurveyModel> _surveys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.get(ApiConstants.surveys);
      if (res.data['success'] == true) {
        setState(() {
          _surveys = (res.data['data'] as List)
              .map((e) => SurveyModel.fromJson(e))
              .toList();
        });
      } else {
        setState(() => _error = res.data['message']?.toString() ?? 'Error del servidor');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuestas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _error != null ? _buildError() : (_surveys.isEmpty ? _buildEmpty() : _buildList()),
            ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: _surveys.length,
      itemBuilder: (_, i) => _buildCard(_surveys[i])
          .animate()
          .fadeIn(delay: (i * 60).ms, duration: 300.ms),
    );
  }

  Widget _buildCard(SurveyModel s) {
    final done = s.isCompleted;
    final color = done ? AppTheme.successColor : AppTheme.primaryOrange;

    return GestureDetector(
      onTap: done
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SurveyResponseScreen(surveyId: s.id, surveyTitle: s.title)),
              ).then((_) => _fetch()),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: done
              ? null
              : [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  done ? Icons.check_circle_rounded : Icons.assignment_outlined,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: done ? AppTheme.textTertiary : null,
                      ),
                    ),
                    if (s.description != null && s.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        s.description!,
                        style: context.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(children: [
                      _pill(
                        done ? 'Completada' : 'Pendiente',
                        done ? AppTheme.successColor : AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      _pill('${s.questionsCount} pregunta${s.questionsCount != 1 ? 's' : ''}', AppTheme.textTertiary),
                      if (s.endDate != null) ...[
                        const SizedBox(width: 8),
                        _pill('Hasta ${_fmtDate(s.endDate!)}', AppTheme.warningColor),
                      ],
                    ]),
                  ],
                ),
              ),
              if (!done)
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );

  String _fmtDate(String d) {
    try {
      return DateFormat('dd/MM/yy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Error al cargar encuestas', style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(_error!, style: context.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 72, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('Sin encuestas pendientes', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Aquí aparecerán las encuestas del gimnasio', style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
