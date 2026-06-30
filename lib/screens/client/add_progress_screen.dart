// 📈 Add Progress Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/progress_provider.dart';
import '../../models/progress_model.dart';
import 'package:intl/intl.dart';

class AddProgressScreen extends StatefulWidget {
  const AddProgressScreen({super.key});

  @override
  State<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends State<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _leftArmController = TextEditingController();
  final _rightArmController = TextEditingController();
  final _leftThighController = TextEditingController();
  final _rightThighController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Progreso'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            
            const Divider(),
            const SizedBox(height: AppTheme.spacing16),
            
            Text('Mediciones Generales', style: context.textTheme.headlineSmall),
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _bodyFatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Porcentaje de grasa corporal (%)',
                prefixIcon: Icon(Icons.pie_chart),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _muscleMassController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Masa muscular (kg)',
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            Text('Mediciones Corporales (cm)', style: context.textTheme.headlineSmall),
            const SizedBox(height: AppTheme.spacing16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _chestController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pecho',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: TextFormField(
                    controller: _waistController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cintura',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hipsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cadera',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: TextFormField(
                    controller: _leftArmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Brazo izq',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rightArmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Brazo der',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: TextFormField(
                    controller: _leftThighController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Muslo izq',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacing16),
            
            TextFormField(
              controller: _rightThighController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Muslo derecho',
                prefixIcon: Icon(Icons.straighten),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas',
                hintText: 'Cómo te sientes, observaciones...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Guardar Progreso'),
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

    final progress = ProgressModel(
      id: 0,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      weight: _parseDouble(_weightController.text),
      bodyFatPercentage: _parseDouble(_bodyFatController.text),
      muscleMass: _parseDouble(_muscleMassController.text),
      chest: _parseDouble(_chestController.text),
      waist: _parseDouble(_waistController.text),
      hips: _parseDouble(_hipsController.text),
      leftArm: _parseDouble(_leftArmController.text),
      rightArm: _parseDouble(_rightArmController.text),
      leftThigh: _parseDouble(_leftThighController.text),
      rightThigh: _parseDouble(_rightThighController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now().toIso8601String(),
    );

    final success = await context.read<ProgressProvider>().addProgress(progress);

    if (success && mounted) {
      context.showSuccessSnackBar('Progreso registrado correctamente');
      Navigator.pop(context);
    } else if (mounted) {
      context.showErrorSnackBar('Error al registrar progreso');
    }
  }

  double? _parseDouble(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _leftArmController.dispose();
    _rightArmController.dispose();
    _leftThighController.dispose();
    _rightThighController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
