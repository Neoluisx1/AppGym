import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../models/exercise_model.dart';

class ExerciseFormScreen extends StatefulWidget {
  final ExerciseModel? exercise;
  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _api      = ApiService();
  final _formKey  = GlobalKey<FormState>();
  bool  _saving   = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _equipCtrl;
  late final TextEditingController _videoCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _calCtrl;

  String  _category   = 'Fuerza';
  String? _muscle;
  String  _difficulty = 'beginner';

  static const _categories = [
    'Cardio', 'Fuerza', 'Flexibilidad', 'Balance', 'HIIT', 'Funcional', 'Yoga', 'Pilates',
  ];
  static const _muscles = [
    'Pecho', 'Espalda', 'Hombros', 'Bíceps', 'Tríceps', 'Abdomen',
    'Glúteos', 'Cuádriceps', 'Isquiotibiales', 'Pantorrillas', 'Cuerpo completo',
  ];
  static const _difficulties = [
    ('beginner',     'Principiante'),
    ('intermediate', 'Intermedio'),
    ('advanced',     'Avanzado'),
  ];

  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _nameCtrl  = TextEditingController(text: ex?.name ?? '');
    _descCtrl  = TextEditingController(text: ex?.description ?? '');
    _equipCtrl = TextEditingController(text: ex?.equipment ?? '');
    _videoCtrl = TextEditingController(text: ex?.videoUrl ?? '');
    _imageCtrl = TextEditingController(text: ex?.imageUrl ?? '');
    _calCtrl   = TextEditingController(text: ex?.caloriesPerRep?.toString() ?? '');
    if (ex != null) {
      _category   = ex.category;
      _muscle     = ex.muscleGroup;
      _difficulty = ex.difficulty;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _equipCtrl.dispose();
    _videoCtrl.dispose();
    _imageCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final body = <String, dynamic>{
      'name':             _nameCtrl.text.trim(),
      'description':      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'category':         _category,
      'muscle_group':     _muscle,
      'difficulty':       _difficulty,
      'equipment':        _equipCtrl.text.trim().isEmpty ? null : _equipCtrl.text.trim(),
      'video_url':        _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
      'image_url':        _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      'calories_per_rep': _calCtrl.text.trim().isEmpty ? null : double.tryParse(_calCtrl.text.trim()),
    };

    try {
      if (_isEditing) {
        await _api.put(ApiConstants.exerciseDetail(widget.exercise!.id), data: body);
      } else {
        await _api.post(ApiConstants.exercises, data: body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el ejercicio'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Guardar', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Nombre ───────────────────────────────────────────────────────
            _label('Nombre del Ejercicio *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _decor('Ej: Press de Banca'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),

            const SizedBox(height: 16),

            // ── Descripción ───────────────────────────────────────────────────
            _label('Descripción'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: _decor('Instrucciones, postura, técnica...'),
            ),

            const SizedBox(height: 16),

            // ── Categoría ─────────────────────────────────────────────────────
            _label('Categoría *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((c) {
                final sel = _category == c;
                return ChoiceChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : AppTheme.textPrimary,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  side: BorderSide(color: sel ? AppTheme.primaryOrange : context.borderCol),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Dificultad ────────────────────────────────────────────────────
            _label('Dificultad *'),
            const SizedBox(height: 8),
            Row(
              children: _difficulties.map((d) {
                final sel = _difficulty == d.$1;
                final color = _diffColor(d.$1);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? color.withValues(alpha: 0.15) : context.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: sel ? color : context.borderCol),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.signal_cellular_alt_rounded, color: sel ? color : AppTheme.textTertiary, size: 20),
                          const SizedBox(height: 4),
                          Text(d.$2,
                              style: TextStyle(
                                fontSize: 11,
                                color: sel ? color : AppTheme.textTertiary,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Grupo Muscular ────────────────────────────────────────────────
            _label('Grupo Muscular'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _muscles.map((m) {
                final sel = _muscle == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: sel,
                  onSelected: (_) => setState(() => _muscle = sel ? null : m),
                  selectedColor: AppTheme.primaryOrange,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : AppTheme.textPrimary,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  side: BorderSide(color: sel ? AppTheme.primaryOrange : context.borderCol),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Equipo ────────────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Equipo Necesario'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _equipCtrl,
                      decoration: _decor('Ej: Mancuernas, Barra'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Calorías por Rep'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _calCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _decor('0.5'),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // ── URLs ──────────────────────────────────────────────────────────
            _label('URL del Video (YouTube)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _videoCtrl,
              keyboardType: TextInputType.url,
              decoration: _decor('https://youtube.com/...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasScheme) return 'URL inválida';
                return null;
              },
            ),

            const SizedBox(height: 12),

            _label('URL de la Imagen'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _imageCtrl,
              keyboardType: TextInputType.url,
              decoration: _decor('https://...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasScheme) return 'URL inválida';
                return null;
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isEditing ? 'Guardar Cambios' : 'Crear Ejercicio',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      );

  InputDecoration _decor(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: context.borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: context.borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
      );

  Color _diffColor(String d) => switch (d) {
        'beginner'     => AppTheme.successColor,
        'intermediate' => AppTheme.warningColor,
        'advanced'     => AppTheme.errorColor,
        _              => AppTheme.textTertiary,
      };
}
