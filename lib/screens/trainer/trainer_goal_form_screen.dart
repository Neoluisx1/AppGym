import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';

class TrainerGoalFormScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  const TrainerGoalFormScreen({super.key, required this.clientId, required this.clientName});

  @override
  State<TrainerGoalFormScreen> createState() => _TrainerGoalFormScreenState();
}

class _TrainerGoalFormScreenState extends State<TrainerGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  String _goalType = 'weight_loss';

  static const _goalTypes = [
    ('weight_loss', 'Pérdida de peso'),
    ('muscle_gain', 'Ganar músculo'),
    ('endurance', 'Resistencia'),
    ('flexibility', 'Flexibilidad'),
    ('strength', 'Fuerza'),
    ('custom', 'Personalizado'),
  ];

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _targetCtrl, _unitCtrl, _notesCtrl, _startCtrl, _endCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'goal_type': _goalType,
    };
    if (_descCtrl.text.isNotEmpty) data['description'] = _descCtrl.text.trim();
    if (_targetCtrl.text.isNotEmpty) data['target_value'] = double.tryParse(_targetCtrl.text);
    if (_unitCtrl.text.isNotEmpty) data['unit'] = _unitCtrl.text.trim();
    if (_notesCtrl.text.isNotEmpty) data['notes'] = _notesCtrl.text.trim();
    if (_startCtrl.text.isNotEmpty) data['start_date'] = _startCtrl.text;
    if (_endCtrl.text.isNotEmpty) data['end_date'] = _endCtrl.text;

    final ok = await context.read<TrainerProvider>().createGoal(widget.clientId, data);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta creada'), backgroundColor: AppTheme.successColor),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la meta'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<TrainerProvider>().submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Meta: ${widget.clientName}', style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            _field('Título de la meta', _titleCtrl, required: true),
            const SizedBox(height: AppTheme.spacing12),

            _sectionTitle('Tipo de Meta'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goalTypes.map((t) {
                final selected = _goalType == t.$1;
                return ChoiceChip(
                  label: Text(t.$2),
                  selected: selected,
                  onSelected: (_) => setState(() => _goalType = t.$1),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: context.cardColor,
                  side: BorderSide(color: selected ? AppTheme.primaryOrange : context.borderCol),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacing16),

            Row(
              children: [
                Expanded(child: _field('Valor objetivo', _targetCtrl, numeric: true)),
                const SizedBox(width: 8),
                Expanded(child: _field('Unidad (ej: kg, %)', _unitCtrl)),
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),

            _field('Descripción', _descCtrl, maxLines: 3),
            const SizedBox(height: AppTheme.spacing8),

            Row(
              children: [
                Expanded(child: _datePicker('Fecha inicio', _startCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _datePicker('Fecha límite', _endCtrl)),
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),

            _field('Notas para el cliente', _notesCtrl, maxLines: 3),
            const SizedBox(height: AppTheme.spacing32),

            ElevatedButton(
              onPressed: submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
              ),
              child: submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Crear Meta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: AppTheme.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
        child: Row(
          children: [
            Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: context.textTheme.headlineSmall),
          ],
        ),
      );

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, bool numeric = false, int maxLines = 1}) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: _decor(label),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null : null,
      );

  Widget _datePicker(String label, TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _pickDate(ctrl),
        decoration: _decor(label, suffix: const Icon(Icons.calendar_today, size: 18)),
      );

  InputDecoration _decor(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        filled: true,
        fillColor: context.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: context.borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: context.borderCol),
        ),
      );
}
