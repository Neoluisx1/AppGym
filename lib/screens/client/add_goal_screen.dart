// 🎯 Add Goal Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/progress_provider.dart';
import '../../models/progress_model.dart';
import 'package:intl/intl.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _unitController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Meta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la meta *',
                hintText: 'Ej: Perder 5 kg',
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un título';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu meta...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            Text('Valores', style: context.textTheme.headlineSmall),
            const SizedBox(height: AppTheme.spacing16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor actual',
                      prefixIcon: Icon(Icons.start),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meta *',
                      prefixIcon: Icon(Icons.track_changes),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unidad',
                hintText: 'kg, cm, días, etc.',
                prefixIcon: Icon(Icons.straighten),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha límite (opcional)'),
              subtitle: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Sin fecha límite',
              ),
              trailing: _selectedDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDate = null),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            
            const Divider(),
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Puntos de recompensa (opcional)',
                hintText: '0',
                prefixIcon: Icon(Icons.stars),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Text(
                      'Tu progreso se calculará automáticamente según los valores ingresados',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Crear Meta'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = GoalModel(
      id: 0,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      targetValue: double.parse(_targetController.text),
      currentValue: double.parse(_currentController.text.isNotEmpty ? _currentController.text : '0'),
      unit: _unitController.text.isNotEmpty ? _unitController.text : null,
      progressPercentage: 0,
      status: 'in_progress',
      deadline: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      pointsReward: int.tryParse(_pointsController.text),
      completedAt: null,
      isCompleted: false,
      isOverdue: false,
      daysRemaining: null,
    );

    final success = await context.read<ProgressProvider>().addGoal(goal);

    if (success && mounted) {
      context.showSuccessSnackBar('Meta creada correctamente');
      Navigator.pop(context);
    } else if (mounted) {
      context.showErrorSnackBar('Error al crear meta');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _unitController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
}
