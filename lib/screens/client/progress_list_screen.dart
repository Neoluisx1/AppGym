import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/progress_provider.dart';
import '../../models/progress_model.dart';
import 'package:intl/intl.dart';
import 'add_progress_screen.dart';

class ProgressListScreen extends StatefulWidget {
  const ProgressListScreen({super.key});

  @override
  State<ProgressListScreen> createState() => _ProgressListScreenState();
}

class _ProgressListScreenState extends State<ProgressListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().fetchProgress();
      context.read<ProgressProvider>().fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mediciones'),
            Tab(text: 'Metas'),
            Tab(text: 'Gráficas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressTab(provider),
          _buildGoalsTab(provider),
          _buildChartsTab(provider),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProgressScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ── Mediciones tab ────────────────────────────────────────────────────────────
  Widget _buildProgressTab(provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.progressList.isEmpty) {
      return _buildEmptyState('Sin mediciones', Icons.trending_up);
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchProgress(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: provider.progressList.length,
        itemBuilder: (context, index) {
          final progress = provider.progressList[index];
          return _buildProgressCard(progress);
        },
      ),
    );
  }

  Widget _buildProgressCard(progress) {
    final date = DateFormat('dd MMM yyyy').format(DateTime.parse(progress.date));

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
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryOrange),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                date,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing16),

          Wrap(
            spacing: AppTheme.spacing16,
            runSpacing: AppTheme.spacing12,
            children: [
              if (progress.weight != null)
                _buildMeasurement('Peso', '${progress.weight} kg', Icons.monitor_weight),
              if (progress.bodyFatPercentage != null)
                _buildMeasurement('Grasa', '${progress.bodyFatPercentage}%', Icons.pie_chart),
              if (progress.muscleMass != null)
                _buildMeasurement('Músculo', '${progress.muscleMass} kg', Icons.fitness_center),
              if (progress.waist != null)
                _buildMeasurement('Cintura', '${progress.waist} cm', Icons.straighten),
            ],
          ),

          if (progress.notes != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            Text(
              progress.notes!,
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurement(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.textSecondCol),
        const SizedBox(width: AppTheme.spacing4),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall,
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ── Metas tab ─────────────────────────────────────────────────────────────────
  Widget _buildGoalsTab(provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.goals.isEmpty) {
      return _buildEmptyGoalsState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchGoals(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: provider.goals.length,
        itemBuilder: (context, index) {
          final goal = provider.goals[index];
          return _buildGoalCard(goal);
        },
      ),
    );
  }

  Widget _buildGoalCard(goal) {
    final progress = goal.progressPercentage / 100;

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
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppTheme.successColor),
                      const SizedBox(width: 4),
                      Text(
                        'Completada',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (goal.description != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            Text(
              goal.description!,
              style: context.textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: AppTheme.spacing16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: context.borderCol,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? AppTheme.successColor : AppTheme.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentValue} / ${goal.targetValue} ${goal.unit ?? ""}',
                    style: context.textTheme.bodySmall,
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}%',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: goal.isCompleted ? AppTheme.successColor : AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (goal.deadline != null && !goal.isCompleted) ...[
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: goal.isOverdue ? AppTheme.errorColor : context.textSecondCol,
                ),
                const SizedBox(width: AppTheme.spacing4),
                Text(
                  goal.isOverdue
                      ? 'Vencida'
                      : 'Quedan ${goal.daysRemaining} días',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: goal.isOverdue ? AppTheme.errorColor : context.textSecondCol,
                  ),
                ),
                if (goal.pointsReward != null) ...[
                  const Spacer(),
                  Icon(Icons.stars, size: 14, color: AppTheme.warningColor),
                  const SizedBox(width: 4),
                  Text(
                    '${goal.pointsReward} pts',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],

          if (goal.isPending) ...[
            const SizedBox(height: AppTheme.spacing16),
            Container(
              padding: EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryOrange, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      'Meta asignada por tu entrenador',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleRejectGoal(goal),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAcceptGoal(goal),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aceptar Meta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (!goal.isCompleted && goal.isAccepted) ...[
            const SizedBox(height: AppTheme.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateProgressDialog(goal),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Actualizar Progreso'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Gráficas tab ──────────────────────────────────────────────────────────────
  Widget _buildChartsTab(ProgressProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = [...provider.progressList]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 72, color: context.textTertCol),
            const SizedBox(height: 16),
            Text('Pocas mediciones', style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Agrega al menos 2 mediciones para ver gráficas',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sorted.any((p) => p.weight != null))
            _buildChartCard(
              title: 'Peso',
              unit: 'kg',
              color: AppTheme.primaryOrange,
              icon: Icons.monitor_weight_outlined,
              data: sorted,
              getValue: (p) => p.weight,
            ),
          if (sorted.any((p) => p.bodyFatPercentage != null)) ...[
            const SizedBox(height: AppTheme.spacing16),
            _buildChartCard(
              title: 'Grasa Corporal',
              unit: '%',
              color: AppTheme.errorColor,
              icon: Icons.pie_chart_outline,
              data: sorted,
              getValue: (p) => p.bodyFatPercentage,
            ),
          ],
          if (sorted.any((p) => p.muscleMass != null)) ...[
            const SizedBox(height: AppTheme.spacing16),
            _buildChartCard(
              title: 'Masa Muscular',
              unit: 'kg',
              color: AppTheme.successColor,
              icon: Icons.fitness_center,
              data: sorted,
              getValue: (p) => p.muscleMass,
            ),
          ],
          if (sorted.any((p) => p.waist != null)) ...[
            const SizedBox(height: AppTheme.spacing16),
            _buildChartCard(
              title: 'Cintura',
              unit: 'cm',
              color: AppTheme.infoColor,
              icon: Icons.straighten,
              data: sorted,
              getValue: (p) => p.waist,
            ),
          ],
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String unit,
    required Color color,
    required IconData icon,
    required List<ProgressModel> data,
    required double? Function(ProgressModel) getValue,
  }) {
    final points = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < data.length; i++) {
      final val = getValue(data[i]);
      if (val != null) {
        points.add(FlSpot(points.length.toDouble(), val));
        try {
          final dt = DateTime.parse(data[i].date);
          labels.add(DateFormat('dd/MM').format(dt));
        } catch (_) {
          labels.add('');
        }
      }
    }

    if (points.length < 2) return const SizedBox();

    final minY = points.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;
    final chartMinY = (minY - padding).clamp(0, double.infinity).toDouble();
    final chartMaxY = maxY + padding;

    final latest = points.last.y;
    final first = points.first.y;
    final diff = latest - first;
    final diffText = diff >= 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1);
    final diffColor = diff == 0
        ? context.textSecondCol
        : (title == 'Grasa Corporal' || title == 'Cintura' || title == 'Peso')
            ? (diff < 0 ? AppTheme.successColor : AppTheme.errorColor)
            : (diff > 0 ? AppTheme.successColor : AppTheme.errorColor);

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${latest.toStringAsFixed(1)} $unit',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    diffText,
                    style: TextStyle(color: diffColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (chartMaxY - chartMinY) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.borderCol,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: (chartMaxY - chartMinY) / 4,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(fontSize: 10, color: context.textTertCol),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (points.length > 6) ? (points.length / 4).roundToDouble() : 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Text(
                          labels[idx],
                          style: TextStyle(fontSize: 9, color: context.textTertCol),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: chartMinY,
                maxY: chartMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: context.cardColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal actions ──────────────────────────────────────────────────────────────
  Future<void> _handleAcceptGoal(goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aceptar Meta'),
        content: Text('¿Deseas aceptar la meta "${goal.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<ProgressProvider>().acceptGoal(goal.id);
      if (success && mounted) {
        context.showSuccessSnackBar('Meta aceptada. ¡A trabajar!');
      } else if (mounted) {
        context.showErrorSnackBar('Error al aceptar la meta');
      }
    }
  }

  Future<void> _handleRejectGoal(goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Meta'),
        content: Text('¿Estás seguro de rechazar la meta "${goal.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<ProgressProvider>().rejectGoal(goal.id);
      if (success && mounted) {
        context.showSuccessSnackBar('Meta rechazada');
      } else if (mounted) {
        context.showErrorSnackBar('Error al rechazar la meta');
      }
    }
  }

  void _showUpdateProgressDialog(goal) {
    final controller = TextEditingController(text: goal.currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Progreso'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Valor actual', suffixText: goal.unit),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null) {
                Navigator.pop(context);
                final progressProvider = context.read<ProgressProvider>();
                final success = await progressProvider.updateGoalProgress(goal.id, value);
                if (success && context.mounted) {
                  context.showSuccessSnackBar('Progreso actualizado');
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: context.textTertCol),
          const SizedBox(height: 24),
          Text(message, style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Presiona + para agregar', style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, size: 80, color: context.textTertCol),
          const SizedBox(height: 24),
          Text('Sin metas asignadas', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tu entrenador te asignará metas personalizadas',
            style: context.textTheme.bodyMedium?.copyWith(color: context.textSecondCol),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
