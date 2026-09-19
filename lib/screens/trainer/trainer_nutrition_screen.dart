import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../widgets/fade_slide_in.dart';
import 'trainer_nutrition_form_screen.dart';

class _NutritionPlan {
  final int id;
  final String name;
  final String? description;
  final String? goal;
  final int? targetCalories;
  final bool isActive;
  final int mealsCount;

  _NutritionPlan({
    required this.id,
    required this.name,
    this.description,
    this.goal,
    this.targetCalories,
    required this.isActive,
    required this.mealsCount,
  });

  factory _NutritionPlan.fromJson(Map<String, dynamic> j) => _NutritionPlan(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        goal: j['goal'],
        targetCalories: j['target_calories'],
        isActive: j['is_active'] == true,
        mealsCount: j['meals_count'] ?? 0,
      );

  String get goalLabel {
    switch (goal) {
      case 'weight_loss':   return 'Pérdida de peso';
      case 'muscle_gain':   return 'Ganancia muscular';
      case 'maintenance':   return 'Mantenimiento';
      case 'health':        return 'Salud general';
      default:              return 'Sin objetivo';
    }
  }
}

class TrainerNutritionScreen extends StatefulWidget {
  final int clientId;
  final String clientName;

  const TrainerNutritionScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<TrainerNutritionScreen> createState() => _TrainerNutritionScreenState();
}

class _TrainerNutritionScreenState extends State<TrainerNutritionScreen> {
  final _api = ApiService();
  List<_NutritionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(ApiConstants.trainerClientNutrition(widget.clientId));
      if (res.data['success'] == true) {
        setState(() {
          _plans = (res.data['data'] as List)
              .map((e) => _NutritionPlan.fromJson(e))
              .toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deletePlan(int planId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _api.delete(ApiConstants.trainerNutritionDetail(planId));
      _fetchPlans();
    } catch (_) {}
  }

  Future<void> _openForm({_NutritionPlan? plan}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerNutritionFormScreen(
          clientId: widget.clientId,
          clientName: widget.clientName,
          existingPlan: plan != null
              ? {'id': plan.id, 'name': plan.name, 'description': plan.description, 'goal': plan.goal, 'target_calories': plan.targetCalories}
              : null,
        ),
      ),
    );
    if (result == true) _fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Planes Nutricionales'),
            Text(widget.clientName, style: context.textTheme.bodySmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppTheme.successColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Plan', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPlans,
              child: _plans.isEmpty ? _buildEmpty() : _buildList(),
            ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _plans.length,
      itemBuilder: (_, i) => FadeSlideIn(
        delay: Duration(milliseconds: (i % 6) * 60),
        child: _buildCard(_plans[i]),
      ),
    );
  }

  Widget _buildCard(_NutritionPlan plan) {
    final color = plan.isActive ? AppTheme.successColor : AppTheme.textTertiary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _openPlanDetail(plan),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
                child: Icon(Icons.restaurant_menu_rounded, color: color, size: 24),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(plan.goalLabel, style: context.textTheme.bodySmall?.copyWith(color: color)),
                    Text(
                      '${plan.mealsCount} comida${plan.mealsCount != 1 ? 's' : ''}${plan.targetCalories != null ? ' · ${plan.targetCalories} kcal objetivo' : ''}',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit')   _openForm(plan: plan);
                  if (v == 'delete') _deletePlan(plan.id);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit',   child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPlanDetail(_NutritionPlan plan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerNutritionFormScreen(
          clientId: widget.clientId,
          clientName: widget.clientName,
          existingPlan: {'id': plan.id, 'name': plan.name, 'description': plan.description, 'goal': plan.goal, 'target_calories': plan.targetCalories},
          editMode: true,
        ),
      ),
    );
    _fetchPlans();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined, size: 72, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('Sin planes nutricionales', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Crea el primer plan para ${widget.clientName}', style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
