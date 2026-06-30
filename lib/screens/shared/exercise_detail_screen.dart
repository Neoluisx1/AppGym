import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/exercise_model.dart';
import 'exercise_form_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isTrainer;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.isTrainer = false,
  });

  Color get _diffColor => switch (exercise.difficulty) {
        'beginner'     => AppTheme.successColor,
        'intermediate' => AppTheme.warningColor,
        'advanced'     => AppTheme.errorColor,
        _              => AppTheme.textTertiary,
      };

  Future<void> _openVideo(BuildContext context) async {
    final url = Uri.tryParse(exercise.videoUrl ?? '');
    if (url == null) return;
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar con imagen ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: isTrainer
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseFormScreen(exercise: exercise),
                        ),
                      ),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: exercise.imageUrl != null
                  ? Image.network(
                      exercise.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _heroFallback(),
                    )
                  : _heroFallback(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nombre + dificultad ───────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _diffColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          exercise.difficultyLabel,
                          style: TextStyle(
                            color: _diffColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Categoría ─────────────────────────────────────────────
                  Text(
                    exercise.category,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Chips de info ─────────────────────────────────────────
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (exercise.muscleGroup != null)
                        _infoChip(Icons.accessibility_new_rounded, exercise.muscleGroup!),
                      if (exercise.equipment != null)
                        _infoChip(Icons.sports_gymnastics_rounded, exercise.equipment!),
                      if (exercise.caloriesPerRep != null)
                        _infoChip(
                          Icons.local_fire_department_rounded,
                          '${exercise.caloriesPerRep!.toStringAsFixed(1)} kcal/rep',
                          color: AppTheme.errorColor,
                        ),
                    ],
                  ),

                  if (exercise.description != null && exercise.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Descripción',
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      exercise.description!,
                      style: context.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],

                  // ── Botón de video ────────────────────────────────────────
                  if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openVideo(context),
                        icon: const Icon(Icons.play_circle_filled_rounded, size: 22),
                        label: const Text('Ver video en YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryOrange.withValues(alpha: 0.8),
            AppTheme.primaryOrange.withValues(alpha: 0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(Icons.fitness_center_rounded, size: 80, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {Color? color}) {
    final c = color ?? AppTheme.primaryOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
