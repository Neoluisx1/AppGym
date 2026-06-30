import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/routine_provider.dart';
import '../../models/routine_model.dart';

class RoutineDetailScreen extends StatefulWidget {
  final int routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RoutineProvider>();
      provider.fetchRoutineDetail(widget.routineId);
      provider.fetchTodayLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();
    final routine = provider.selectedRoutine;

    return Scaffold(
      appBar: AppBar(title: Text(routine?.name ?? 'Rutina')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : routine == null
              ? const Center(child: Text('Error al cargar rutina'))
              : ListView(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  children: [
                    // Header card
                    _buildHeader(routine),
                    const SizedBox(height: AppTheme.spacing24),

                    // Days
                    if (routine.days.isEmpty)
                      _buildEmptyExercises()
                    else
                      ...routine.days.map(
                        (day) => _buildDaySection(day, provider),
                      ),

                    const SizedBox(height: AppTheme.spacing32),
                  ],
                ),
    );
  }

  Widget _buildHeader(RoutineModel routine) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C38), Color(0xFFD4500A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  routine.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  routine.isActive ? 'ACTIVA' : 'INACTIVA',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (routine.description != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            Text(
              routine.description!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
            ),
          ],
          if (routine.trainerName != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Entrenador: ${routine.trainerName}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                const Spacer(),
                if (routine.trainerUserId != null)
                  GestureDetector(
                    onTap: () => _openChat(routine.trainerUserId!, routine.trainerName!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Chat', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '${routine.days.length} días · ${routine.exercises.length} ejercicios',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(RoutineDayModel day, RoutineProvider provider) {
    final completedCount = day.exercises.where((e) => provider.isLogged(e.id)).length;
    final allDone = completedCount == day.exercises.length && day.exercises.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: allDone
              ? AppTheme.successColor.withValues(alpha: 0.4)
              : context.borderCol,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing4,
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: allDone
                      ? AppTheme.successColor.withValues(alpha: 0.15)
                      : AppTheme.primaryOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: allDone
                      ? const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20)
                      : Text(
                          '${day.dayOrder}',
                          style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayName ?? 'Día ${day.dayOrder}',
                      style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (day.focus != null)
                      Text(day.focus!, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                '$completedCount/${day.exercises.length}',
                style: TextStyle(
                  color: allDone ? AppTheme.successColor : context.textTertCol,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...day.exercises.map((ex) => _buildExerciseTile(ex, provider)),
            if (day.notes != null)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: context.textTertCol),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(day.notes!, style: context.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(ExerciseModel exercise, RoutineProvider provider) {
    final isLogged = provider.isLogged(exercise.id);
    return InkWell(
      onTap: () => _showExerciseDetail(exercise, provider),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        child: Row(
          children: [
            // Order badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isLogged
                    ? AppTheme.successColor.withValues(alpha: 0.15)
                    : AppTheme.primaryOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLogged
                    ? const Icon(Icons.check, size: 16, color: AppTheme.successColor)
                    : Text(
                        '${exercise.order}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLogged ? context.textSecondCol : Theme.of(context).colorScheme.onSurface,
                      decoration: isLogged ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 10,
                    children: [
                      _statChip('${exercise.sets} series'),
                      _statChip('${exercise.reps} reps'),
                      if (exercise.weight != null) _statChip('${exercise.weight} kg'),
                      if (exercise.restSeconds != null) _statChip(exercise.restFormatted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Log/unlog checkbox
            GestureDetector(
              onTap: () => isLogged
                  ? provider.unlogExercise(exercise.id)
                  : _showLogDialog(exercise, provider),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLogged
                      ? AppTheme.successColor
                      : AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isLogged
                        ? AppTheme.successColor
                        : AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  isLogged ? Icons.check : Icons.add,
                  size: 18,
                  color: isLogged ? Colors.white : AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 11, color: context.textTertCol),
    );
  }

  void _showExerciseDetail(ExerciseModel exercise, RoutineProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(exercise.name, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _buildDetailStat('Series', '${exercise.sets}', Icons.repeat),
                _buildDetailStat('Reps', '${exercise.reps}', Icons.fitness_center),
                if (exercise.weight != null)
                  _buildDetailStat('Peso', '${exercise.weight} kg', Icons.line_weight),
                if (exercise.restSeconds != null)
                  _buildDetailStat('Descanso', exercise.restFormatted, Icons.timer),
              ],
            ),
            if (exercise.instructions != null) ...[
              const SizedBox(height: AppTheme.spacing16),
              Text('Instrucciones', style: context.textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(exercise.instructions!, style: context.textTheme.bodyMedium),
            ],
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLogged(exercise.id)
                    ? () { Navigator.pop(ctx); provider.unlogExercise(exercise.id); }
                    : () { Navigator.pop(ctx); _showLogDialog(exercise, provider); },
                icon: Icon(provider.isLogged(exercise.id) ? Icons.close : Icons.check),
                label: Text(provider.isLogged(exercise.id) ? 'Desmarcar' : 'Marcar como completado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.isLogged(exercise.id)
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryOrange),
        const SizedBox(width: 4),
        Text('$label: ', style: context.textTheme.bodySmall),
        Text(value, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  void _showLogDialog(ExerciseModel exercise, RoutineProvider provider) {
    final setsCtrl  = TextEditingController(text: '${exercise.sets}');
    final repsCtrl  = TextEditingController(text: '${exercise.reps}');
    final weightCtrl = TextEditingController(text: exercise.weight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exercise.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Registra lo que completaste hoy:', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Series'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)', suffixText: 'kg'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () async {
              final sets      = int.tryParse(setsCtrl.text);
              final reps      = int.tryParse(repsCtrl.text);
              final weight    = double.tryParse(weightCtrl.text);
              final provider  = context.read<RoutineProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await provider.logExercise(
                exercise.id,
                setsCompleted: sets,
                repsCompleted: reps,
                weightUsed: weight,
              );
              messenger.showSnackBar(const SnackBar(
                content: Text('¡Ejercicio completado!'),
                backgroundColor: AppTheme.successColor,
              ));
            },
            icon: const Icon(Icons.check),
            label: const Text('Completado'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
          ),
        ],
      ),
    );
  }

  void _openChat(int trainerUserId, String trainerName) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'trainerUserId': trainerUserId, 'trainerName': trainerName},
    );
  }

  Widget _buildEmptyExercises() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_outlined, size: 56, color: context.textTertCol),
          const SizedBox(height: 16),
          Text('Sin ejercicios aún', style: context.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('Tu entrenador aún no ha añadido ejercicios', style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  void dispose() {
    context.read<RoutineProvider>().clearSelectedRoutine();
    super.dispose();
  }
}
