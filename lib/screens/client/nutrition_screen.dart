import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/nutrition_provider.dart';
import '../../models/nutrition_model.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Nutricional')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: provider.plans.isEmpty
                  ? _buildEmptyState()
                  : provider.activePlan != null
                      ? _buildPlanDetail(provider.activePlan!)
                      : _buildPlanList(provider),
            ),
    );
  }

  Widget _buildPlanList(NutritionProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: provider.plans.length,
      itemBuilder: (context, index) {
        final plan = provider.plans[index];
        return _buildPlanCard(plan, provider);
      },
    );
  }

  Widget _buildPlanCard(NutritionPlanModel plan, NutritionProvider provider) {
    return GestureDetector(
      onTap: () => provider.fetchPlanDetail(plan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.restaurant_menu, color: AppTheme.successColor, size: 24),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(plan.goalLabel, style: context.textTheme.bodySmall?.copyWith(color: AppTheme.successColor)),
                  if (plan.trainerName != null)
                    Text('Por: ${plan.trainerName}', style: context.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertCol),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetail(NutritionPlanModel plan) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      children: [
        // Header
        _buildPlanHeader(plan),
        const SizedBox(height: AppTheme.spacing24),

        // Meals
        Text('Comidas del día', style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.spacing12),

        ...plan.meals.map((meal) => _buildMealCard(meal)),

        // Totals
        if (plan.meals.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacing16),
          _buildTotalsCard(plan),
        ],

        const SizedBox(height: AppTheme.spacing32),
      ],
    );
  }

  Widget _buildPlanHeader(NutritionPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.successColor, AppTheme.successColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
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
                child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 10),
            Text(plan.description!, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          ],
          const SizedBox(height: AppTheme.spacing12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _headerChip(Icons.flag_outlined, plan.goalLabel),
              if (plan.targetCalories != null)
                _headerChip(Icons.local_fire_department_outlined, '${plan.targetCalories} kcal objetivo'),
              if (plan.trainerName != null)
                _headerChip(Icons.person_outline, plan.trainerName!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMealCard(NutritionMealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing4),
          title: Row(
            children: [
              Text(_mealIcon(meal.mealType), style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.mealTypeLabel, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (meal.name != meal.mealTypeLabel)
                      Text(meal.name, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              if (meal.totalCalories != null)
                Text(
                  '${meal.totalCalories} kcal',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          children: [
            if (meal.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                child: Text(meal.description!, style: context.textTheme.bodySmall),
              ),
            if (meal.foods.isNotEmpty) ...[
              const Divider(height: 1),
              ...meal.foods.map((food) => _buildFoodRow(food)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRow(MealFoodModel food) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: context.textTertCol),
          const SizedBox(width: 10),
          Expanded(
            child: Text(food.foodName, style: context.textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.amount.toStringAsFixed(food.amount % 1 == 0 ? 0 : 1)} ${food.unit}',
                style: context.textTheme.bodySmall?.copyWith(color: context.textSecondCol),
              ),
              if (food.calories != null)
                Text(
                  '${food.calories} kcal',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(NutritionPlanModel plan) {
    final totalProt = plan.meals
        .expand((m) => m.foods)
        .fold(0.0, (sum, f) => sum + (f.proteinG ?? 0));
    final totalCarbs = plan.meals
        .expand((m) => m.foods)
        .fold(0.0, (sum, f) => sum + (f.carbsG ?? 0));
    final totalFats = plan.meals
        .expand((m) => m.foods)
        .fold(0.0, (sum, f) => sum + (f.fatsG ?? 0));

    if (totalProt == 0 && totalCarbs == 0 && totalFats == 0) {
      return const SizedBox();
    }

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
          Text('Macros totales', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(child: _macroTile('Proteína', '${totalProt.toStringAsFixed(1)}g', const Color(0xFF3B82F6))),
              Expanded(child: _macroTile('Carbos', '${totalCarbs.toStringAsFixed(1)}g', AppTheme.warningColor)),
              Expanded(child: _macroTile('Grasas', '${totalFats.toStringAsFixed(1)}g', AppTheme.errorColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }

  String _mealIcon(String type) {
    switch (type) {
      case 'breakfast':       return '🌅';
      case 'morning_snack':   return '🍎';
      case 'lunch':           return '🍽️';
      case 'afternoon_snack': return '🥜';
      case 'dinner':          return '🌙';
      default:                return '🍴';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined, size: 72, color: context.textTertCol),
          const SizedBox(height: 16),
          Text('Sin plan nutricional', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tu entrenador te asignará un plan nutricional',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
