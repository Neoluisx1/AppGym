import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';

class TrainerEvaluationFormScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  const TrainerEvaluationFormScreen({super.key, required this.clientId, required this.clientName});

  @override
  State<TrainerEvaluationFormScreen> createState() => _TrainerEvaluationFormScreenState();
}

class _TrainerEvaluationFormScreenState extends State<TrainerEvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _muscleMassCtrl = TextEditingController();
  final _visceralFatCtrl = TextEditingController();

  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _thighLCtrl = TextEditingController();
  final _thighRCtrl = TextEditingController();
  final _calfLCtrl = TextEditingController();
  final _calfRCtrl = TextEditingController();

  final _pushUpsCtrl = TextEditingController();
  final _sitUpsCtrl = TextEditingController();
  final _flexCtrl = TextEditingController();
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();

  final _notesCtrl = TextEditingController();
  final _goalsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final c in [
      _dateCtrl, _weightCtrl, _heightCtrl, _bodyFatCtrl, _muscleMassCtrl,
      _visceralFatCtrl, _chestCtrl, _waistCtrl, _hipsCtrl, _armsCtrl,
      _thighLCtrl, _thighRCtrl, _calfLCtrl, _calfRCtrl, _pushUpsCtrl,
      _sitUpsCtrl, _flexCtrl, _bpSysCtrl, _bpDiaCtrl, _hrCtrl,
      _notesCtrl, _goalsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'measurement_date': _dateCtrl.text,
    };

    void addNum(String key, TextEditingController c, {bool isInt = false}) {
      if (c.text.isNotEmpty) {
        data[key] = isInt ? int.tryParse(c.text) : double.tryParse(c.text);
      }
    }

    addNum('weight', _weightCtrl);
    addNum('height', _heightCtrl);
    addNum('body_fat_percentage', _bodyFatCtrl);
    addNum('muscle_mass', _muscleMassCtrl);
    addNum('visceral_fat', _visceralFatCtrl);
    addNum('chest', _chestCtrl);
    addNum('waist', _waistCtrl);
    addNum('hips', _hipsCtrl);
    addNum('arms', _armsCtrl);
    addNum('thigh_left', _thighLCtrl);
    addNum('thigh_right', _thighRCtrl);
    addNum('calf_left', _calfLCtrl);
    addNum('calf_right', _calfRCtrl);
    addNum('push_ups', _pushUpsCtrl, isInt: true);
    addNum('sit_ups', _sitUpsCtrl, isInt: true);
    addNum('flexibility', _flexCtrl);
    addNum('blood_pressure_systolic', _bpSysCtrl, isInt: true);
    addNum('blood_pressure_diastolic', _bpDiaCtrl, isInt: true);
    addNum('resting_heart_rate', _hrCtrl, isInt: true);
    if (_notesCtrl.text.isNotEmpty) data['notes'] = _notesCtrl.text;
    if (_goalsCtrl.text.isNotEmpty) data['goals'] = _goalsCtrl.text;

    final ok = await context.read<TrainerProvider>().createEvaluation(widget.clientId, data);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evaluación guardada'), backgroundColor: AppTheme.successColor),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<TrainerProvider>().submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluar: ${widget.clientName}', style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            _sectionTitle('Fecha de Evaluación'),
            _dateField(),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Composición Corporal'),
            _row([
              _numField('Peso (kg)', _weightCtrl),
              _numField('Talla (cm)', _heightCtrl),
            ]),
            _row([
              _numField('Grasa corporal %', _bodyFatCtrl),
              _numField('Masa muscular (kg)', _muscleMassCtrl),
            ]),
            _row([_numField('Grasa visceral', _visceralFatCtrl)]),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Medidas (cm)'),
            _row([_numField('Pecho', _chestCtrl), _numField('Cintura', _waistCtrl)]),
            _row([_numField('Caderas', _hipsCtrl), _numField('Brazos', _armsCtrl)]),
            _row([_numField('Muslo Izq.', _thighLCtrl), _numField('Muslo Der.', _thighRCtrl)]),
            _row([_numField('Pantorrilla Izq.', _calfLCtrl), _numField('Pantorrilla Der.', _calfRCtrl)]),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Condición Física'),
            _row([_intField('Flexiones', _pushUpsCtrl), _intField('Abdominales', _sitUpsCtrl)]),
            _row([_numField('Flexibilidad (cm)', _flexCtrl)]),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Signos Vitales'),
            _row([
              _intField('Presión Sistólica', _bpSysCtrl),
              _intField('Presión Diastólica', _bpDiaCtrl),
            ]),
            _row([_intField('Frecuencia cardíaca en reposo', _hrCtrl)]),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Observaciones'),
            _textArea('Objetivos del cliente', _goalsCtrl),
            const SizedBox(height: AppTheme.spacing8),
            _textArea('Notas adicionales', _notesCtrl),
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
                  : const Text('Guardar Evaluación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _dateField() => TextFormField(
        controller: _dateCtrl,
        readOnly: true,
        onTap: _pickDate,
        decoration: _decor('Fecha', suffix: const Icon(Icons.calendar_today, size: 18)),
        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
      );

  Widget _numField(String label, TextEditingController ctrl) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing8, right: 4, left: 4),
          child: TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decor(label),
          ),
        ),
      );

  Widget _intField(String label, TextEditingController ctrl) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacing8, right: 4, left: 4),
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: _decor(label),
          ),
        ),
      );

  Widget _textArea(String label, TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        maxLines: 3,
        decoration: _decor(label),
      );

  Widget _row(List<Widget> children) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);

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
