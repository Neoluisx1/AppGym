import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';

class TrainerProgressFormScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  const TrainerProgressFormScreen({super.key, required this.clientId, required this.clientName});

  @override
  State<TrainerProgressFormScreen> createState() => _TrainerProgressFormScreenState();
}

class _TrainerProgressFormScreenState extends State<TrainerProgressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _muscleMassCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _thighsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  File? _photoFront;
  File? _photoSide;
  File? _photoBack;

  final _picker = ImagePicker();

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
      _chestCtrl, _waistCtrl, _hipsCtrl, _armsCtrl, _thighsCtrl, _notesCtrl,
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

  Future<void> _pickPhoto(String slot) async {
    final source = await _showSourceDialog();
    if (source == null) return;

    final xfile = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (xfile == null) return;

    setState(() {
      final file = File(xfile.path);
      if (slot == 'front') _photoFront = file;
      if (slot == 'side') _photoSide = file;
      if (slot == 'back') _photoBack = file;
    });
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              title: Text('Cámara', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.infoColor),
              title: Text('Galería', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{'measurement_date': _dateCtrl.text};

    void addNum(String key, TextEditingController c) {
      if (c.text.isNotEmpty) data[key] = double.tryParse(c.text);
    }

    addNum('weight', _weightCtrl);
    addNum('height', _heightCtrl);
    addNum('body_fat_percentage', _bodyFatCtrl);
    addNum('muscle_mass', _muscleMassCtrl);
    addNum('chest', _chestCtrl);
    addNum('waist', _waistCtrl);
    addNum('hips', _hipsCtrl);
    addNum('arms', _armsCtrl);
    addNum('thighs', _thighsCtrl);
    if (_notesCtrl.text.isNotEmpty) data['notes'] = _notesCtrl.text;

    final ok = await context.read<TrainerProvider>().createProgress(
      widget.clientId,
      data,
      photoFrontPath: _photoFront?.path,
      photoSidePath: _photoSide?.path,
      photoBackPath: _photoBack?.path,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medidas registradas'), backgroundColor: AppTheme.successColor),
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
        title: Text('Medidas: ${widget.clientName}', style: const TextStyle(fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            _sectionTitle('Fecha'),
            TextFormField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: _decor('Fecha de medición', suffix: const Icon(Icons.calendar_today, size: 18)),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Composición Corporal'),
            _row([_numField('Peso (kg)', _weightCtrl), _numField('Talla (cm)', _heightCtrl)]),
            _row([_numField('Grasa corporal %', _bodyFatCtrl), _numField('Masa muscular (kg)', _muscleMassCtrl)]),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Medidas Corporales (cm)'),
            _row([_numField('Pecho', _chestCtrl), _numField('Cintura', _waistCtrl)]),
            _row([_numField('Caderas', _hipsCtrl), _numField('Brazos', _armsCtrl)]),
            _numField('Muslos', _thighsCtrl),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Fotos de Progreso'),
            Row(
              children: [
                Expanded(child: _photoSlot('Frontal', 'front', _photoFront)),
                const SizedBox(width: 8),
                Expanded(child: _photoSlot('Lateral', 'side', _photoSide)),
                const SizedBox(width: 8),
                Expanded(child: _photoSlot('Posterior', 'back', _photoBack)),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),

            _sectionTitle('Observaciones'),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: _decor('Notas'),
            ),
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
                  : const Text('Guardar Medidas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: AppTheme.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _photoSlot(String label, String slot, File? file) {
    return GestureDetector(
      onTap: () => _pickPhoto(slot),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: file != null ? AppTheme.primaryOrange : context.borderCol,
          ),
          image: file != null
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: context.textTertCol, size: 28),
                  const SizedBox(height: 6),
                  Text(label, style: context.textTheme.bodySmall, textAlign: TextAlign.center),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (slot == 'front') _photoFront = null;
                        if (slot == 'side') _photoSide = null;
                        if (slot == 'back') _photoBack = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
                    ),
                  ),
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

  Widget _row(List<Widget> children) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);

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
