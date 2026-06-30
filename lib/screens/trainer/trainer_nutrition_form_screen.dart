import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class TrainerNutritionFormScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final Map<String, dynamic>? existingPlan;
  final bool editMode;

  const TrainerNutritionFormScreen({
    super.key,
    required this.clientId,
    required this.clientName,
    this.existingPlan,
    this.editMode = false,
  });

  @override
  State<TrainerNutritionFormScreen> createState() => _TrainerNutritionFormScreenState();
}

class _TrainerNutritionFormScreenState extends State<TrainerNutritionFormScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl  = TextEditingController();
  String? _goal;

  bool _saving  = false;
  bool _loading = false;

  int? _planId;
  List<Map<String, dynamic>> _meals = [];

  static const _goalOptions = [
    ('weight_loss',  'Pérdida de peso'),
    ('muscle_gain',  'Ganancia muscular'),
    ('maintenance',  'Mantenimiento'),
    ('health',       'Salud general'),
  ];

  static const _mealTypes = [
    ('breakfast',       '🌅 Desayuno'),
    ('morning_snack',   '🍎 Merienda mañana'),
    ('lunch',           '🍽️ Almuerzo'),
    ('afternoon_snack', '🥜 Merienda tarde'),
    ('dinner',          '🌙 Cena'),
    ('other',           '🍴 Otro'),
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingPlan;
    if (p != null) {
      _planId = p['id'];
      _nameCtrl.text = p['name'] ?? '';
      _descCtrl.text = p['description'] ?? '';
      _calCtrl.text  = p['target_calories']?.toString() ?? '';
      _goal = p['goal'];
      if (widget.editMode && _planId != null) _loadPlanDetail();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlanDetail() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(ApiConstants.trainerNutritionDetail(_planId!));
      if (res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        setState(() {
          _nameCtrl.text = data['name'] ?? '';
          _descCtrl.text = data['description'] ?? '';
          _calCtrl.text  = data['target_calories']?.toString() ?? '';
          _goal = data['goal'];
          _meals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final body = {
        'name':             _nameCtrl.text.trim(),
        'description':      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'goal':             _goal,
        'target_calories':  _calCtrl.text.trim().isEmpty ? null : int.tryParse(_calCtrl.text.trim()),
      };

      if (_planId == null) {
        final res = await _api.post(ApiConstants.trainerClientNutrition(widget.clientId), data: body);
        if (res.data['success'] == true) {
          final data = res.data['data'] as Map<String, dynamic>;
          setState(() {
            _planId = data['id'];
            _meals  = List<Map<String, dynamic>>.from(data['meals'] ?? []);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan creado exitosamente'), backgroundColor: AppTheme.successColor),
            );
          }
        }
      } else {
        await _api.put(ApiConstants.trainerNutritionDetail(_planId!), data: body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan actualizado'), backgroundColor: AppTheme.successColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _addMeal() async {
    if (_planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guarda el plan primero'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    String? selectedType = 'breakfast';
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final calCtrl  = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Agregar Comida'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: _mealTypes.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
                  onChanged: (v) => setS(() => selectedType = v),
                ),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre (ej: Desayuno proteico)')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
                const SizedBox(height: 8),
                TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calorías totales (opcional)'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim().isNotEmpty),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    try {
      final res = await _api.post(ApiConstants.trainerNutritionMeals(_planId!), data: {
        'meal_type':      selectedType,
        'name':           nameCtrl.text.trim(),
        'description':    descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        'total_calories': calCtrl.text.trim().isEmpty ? null : int.tryParse(calCtrl.text.trim()),
      });
      if (res.data['success'] == true) {
        setState(() => _meals.add(res.data['data'] as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  Future<void> _deleteMeal(int mealId) async {
    try {
      await _api.delete(ApiConstants.trainerNutritionMeal(_planId!, mealId));
      setState(() => _meals.removeWhere((m) => m['id'] == mealId));
    } catch (_) {}
  }

  Future<void> _addFood(int mealId) async {
    final foodCtrl   = TextEditingController();
    final amountCtrl = TextEditingController();
    final unitCtrl   = TextEditingController(text: 'g');
    final calCtrl    = TextEditingController();
    final protCtrl   = TextEditingController();
    final carbCtrl   = TextEditingController();
    final fatCtrl    = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Alimento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: foodCtrl,   decoration: const InputDecoration(labelText: 'Alimento *')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Cantidad *'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unidad *'))),
              ]),
              const SizedBox(height: 8),
              TextField(controller: calCtrl,  decoration: const InputDecoration(labelText: 'Calorías (kcal)'), keyboardType: TextInputType.number),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(child: TextField(controller: protCtrl, decoration: const InputDecoration(labelText: 'Proteína (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: carbCtrl, decoration: const InputDecoration(labelText: 'Carbos (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: fatCtrl,  decoration: const InputDecoration(labelText: 'Grasas (g)'), keyboardType: TextInputType.number)),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              foodCtrl.text.trim().isNotEmpty && amountCtrl.text.trim().isNotEmpty,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      final res = await _api.post(ApiConstants.trainerNutritionFoods(_planId!, mealId), data: {
        'food_name': foodCtrl.text.trim(),
        'amount':    double.tryParse(amountCtrl.text.trim()) ?? 0,
        'unit':      unitCtrl.text.trim(),
        'calories':  calCtrl.text.trim().isEmpty ? null : int.tryParse(calCtrl.text.trim()),
        'protein_g': protCtrl.text.trim().isEmpty ? null : double.tryParse(protCtrl.text.trim()),
        'carbs_g':   carbCtrl.text.trim().isEmpty ? null : double.tryParse(carbCtrl.text.trim()),
        'fats_g':    fatCtrl.text.trim().isEmpty  ? null : double.tryParse(fatCtrl.text.trim()),
      });
      if (res.data['success'] == true) {
        setState(() {
          final meal = _meals.firstWhere((m) => m['id'] == mealId);
          final foods = List<dynamic>.from(meal['foods'] ?? []);
          foods.add(res.data['data']);
          meal['foods'] = foods;
        });
      }
    } catch (_) {}
  }

  Future<void> _deleteFood(int mealId, int foodId) async {
    try {
      await _api.delete(ApiConstants.trainerNutritionFood(_planId!, mealId, foodId));
      setState(() {
        final meal = _meals.firstWhere((m) => m['id'] == mealId);
        final foods = List<dynamic>.from(meal['foods'] ?? []);
        foods.removeWhere((f) => f['id'] == foodId);
        meal['foods'] = foods;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_planId == null ? 'Nuevo Plan' : 'Editar Plan'),
        actions: [
          if (_saving)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(
              onPressed: _savePlan,
              child: const Text('Guardar', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoForm(),
                  if (_planId != null) ...[
                    const SizedBox(height: AppTheme.spacing24),
                    _buildMealsSection(),
                  ],
                  const SizedBox(height: AppTheme.spacing32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información del Plan', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacing16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del plan *'),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: AppTheme.spacing12),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(labelText: 'Objetivo'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin objetivo')),
                ..._goalOptions.map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2))),
              ],
              onChanged: (v) => setState(() => _goal = v),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextFormField(
              controller: _calCtrl,
              decoration: const InputDecoration(labelText: 'Calorías objetivo (kcal)', suffixText: 'kcal'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _savePlan,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                child: Text(_planId == null ? 'Crear Plan' : 'Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Comidas', style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _addMeal,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        if (_meals.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: context.borderCol),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_outlined, color: context.textTertCol),
                const SizedBox(width: 12),
                Text('Sin comidas. Toca "Agregar" para añadir.', style: context.textTheme.bodyMedium),
              ],
            ),
          )
        else
          ..._meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final mealId = meal['id'] as int;
    final foods  = List<dynamic>.from(meal['foods'] ?? []);

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
              Text(_mealEmoji(meal['meal_type'] ?? ''), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(meal['name'] ?? '', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              if (meal['total_calories'] != null)
                Text('${meal['total_calories']} kcal', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.warningColor)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.successColor),
                tooltip: 'Agregar alimento',
                onPressed: () => _addFood(mealId),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.errorColor),
                tooltip: 'Eliminar comida',
                onPressed: () => _deleteMeal(mealId),
              ),
            ],
          ),
          children: [
            if (foods.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Sin alimentos. Toca + para añadir.', style: context.textTheme.bodySmall),
              )
            else ...[
              const Divider(height: 1),
              ...foods.map((f) => _buildFoodRow(mealId, f as Map<String, dynamic>)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRow(int mealId, Map<String, dynamic> food) {
    final amount = food['amount'];
    final amountStr = amount is num
        ? amount.toDouble().toStringAsFixed(amount.toDouble() % 1 == 0 ? 0 : 1)
        : amount?.toString() ?? '';

    return Dismissible(
      key: Key('food_${food['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppTheme.errorColor.withValues(alpha: 0.15),
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: AppTheme.errorColor),
      ),
      onDismissed: (_) => _deleteFood(mealId, food['id'] as int),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 5, color: AppTheme.textTertiary),
            const SizedBox(width: 10),
            Expanded(child: Text(food['food_name'] ?? '', style: context.textTheme.bodyMedium)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$amountStr ${food['unit'] ?? ''}', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                if (food['calories'] != null)
                  Text('${food['calories']} kcal', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.warningColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'breakfast':       return '🌅';
      case 'morning_snack':   return '🍎';
      case 'lunch':           return '🍽️';
      case 'afternoon_snack': return '🥜';
      case 'dinner':          return '🌙';
      default:                return '🍴';
    }
  }
}
