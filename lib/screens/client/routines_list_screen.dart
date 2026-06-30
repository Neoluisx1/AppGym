// 💪 Routines List Screen - Con datos reales
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/routine_provider.dart';
import 'routine_detail_screen.dart';

class RoutinesListScreen extends StatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  State<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends State<RoutinesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().fetchRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.routines.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.fetchRoutines(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    itemCount: provider.routines.length,
                    itemBuilder: (context, index) {
                      final routine = provider.routines[index];
                      return _buildRoutineCard(routine);
                    },
                  ),
                ),
    );
  }

  Widget _buildRoutineCard(routine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routineId: routine.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppTheme.primaryOrange,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (routine.description != null) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      routine.description!,
                      style: context.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacing8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: routine.isActive
                              ? AppTheme.successColor.withValues(alpha: 0.2)
                              : context.textTertCol.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          routine.isActive ? 'Activa' : 'Inactiva',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: routine.isActive
                                ? AppTheme.successColor
                                : context.textTertCol,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (routine.trainerName != null) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          '• ${routine.trainerName}',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.textTertCol,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: context.textTertCol,
          ),
          const SizedBox(height: 24),
          Text(
            'Sin rutinas asignadas',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Consulta con tu entrenador',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
