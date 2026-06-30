import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../models/exercise_model.dart';
import 'exercise_detail_screen.dart';
import 'exercise_form_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final bool isTrainer;
  const ExerciseListScreen({super.key, this.isTrainer = false});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final _api         = ApiService();
  final _searchCtrl  = TextEditingController();

  List<ExerciseModel> _exercises = [];
  bool   _loading    = true;
  int    _page       = 1;
  int    _lastPage   = 1;
  bool   _loadingMore = false;

  String? _filterCategory;
  String? _filterDifficulty;
  String? _filterMuscle;

  static const _categories = [
    'Cardio', 'Fuerza', 'Flexibilidad', 'Balance', 'HIIT', 'Funcional', 'Yoga', 'Pilates',
  ];
  static const _difficulties = [
    ('beginner', 'Principiante'),
    ('intermediate', 'Intermedio'),
    ('advanced', 'Avanzado'),
  ];
  static const _muscles = [
    'Pecho', 'Espalda', 'Hombros', 'Bíceps', 'Tríceps', 'Abdomen',
    'Glúteos', 'Cuádriceps', 'Isquiotibiales', 'Pantorrillas', 'Cuerpo completo',
  ];

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) {
      setState(() { _page = 1; _exercises = []; _loading = true; });
    } else {
      if (_loadingMore || _page >= _lastPage) return;
      setState(() => _loadingMore = true);
    }

    try {
      final params = <String, dynamic>{'page': _page};
      if (_searchCtrl.text.isNotEmpty) params['search'] = _searchCtrl.text.trim();
      if (_filterCategory != null)  params['category']    = _filterCategory;
      if (_filterDifficulty != null) params['difficulty']  = _filterDifficulty;
      if (_filterMuscle != null)    params['muscle_group'] = _filterMuscle;

      final res = await _api.get(ApiConstants.exercises, queryParameters: params);
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map((e) => ExerciseModel.fromJson(e))
            .toList();
        final meta = res.data['meta'];
        setState(() {
          _exercises = reset ? list : [..._exercises, ...list];
          _lastPage  = meta['last_page'] ?? 1;
          _page++;
        });
      }
    } catch (_) {}
    if (mounted) setState(() { _loading = false; _loadingMore = false; });
  }

  Future<void> _openForm({ExerciseModel? exercise}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExerciseFormScreen(exercise: exercise)),
    );
    if (result == true) _fetch(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilters,
            tooltip: 'Filtros',
          ),
        ],
      ),
      floatingActionButton: widget.isTrainer
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: AppTheme.primaryOrange,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: Column(
        children: [
          _buildSearch(),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onSubmitted: (_) => _fetch(reset: true),
        decoration: InputDecoration(
          hintText: 'Buscar ejercicio...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () { _searchCtrl.clear(); _fetch(reset: true); },
                )
              : null,
          filled: true,
          fillColor: context.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final hasFilter = _filterCategory != null || _filterDifficulty != null || _filterMuscle != null;
    if (!hasFilter) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 6,
        children: [
          if (_filterCategory != null)
            _chip(_filterCategory!, onRemove: () { setState(() => _filterCategory = null); _fetch(reset: true); }),
          if (_filterDifficulty != null)
            _chip(_diffLabel(_filterDifficulty!), onRemove: () { setState(() => _filterDifficulty = null); _fetch(reset: true); }),
          if (_filterMuscle != null)
            _chip(_filterMuscle!, onRemove: () { setState(() => _filterMuscle = null); _fetch(reset: true); }),
        ],
      ),
    );
  }

  Widget _chip(String label, {required VoidCallback onRemove}) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
      side: const BorderSide(color: AppTheme.primaryOrange, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined, size: 72, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text('Sin ejercicios', style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              widget.isTrainer ? 'Toca + para agregar el primero' : 'No hay ejercicios disponibles aún',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetch(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _exercises.length + (_page <= _lastPage ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _exercises.length) {
            _fetch();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _buildCard(_exercises[i])
              .animate()
              .fadeIn(delay: (i * 40).ms, duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildCard(ExerciseModel ex) {
    final diffColor = _diffColor(ex.difficulty);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(exercise: ex, isTrainer: widget.isTrainer),
        ),
      ).then((_) => _fetch(reset: true)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            // Imagen o ícono
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                bottomLeft: Radius.circular(AppTheme.radiusLarge),
              ),
              child: ex.imageUrl != null
                  ? Image.network(
                      ex.imageUrl!,
                      width: 90, height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconBox(diffColor),
                    )
                  : _iconBox(diffColor),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.name,
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(ex.category,
                        style: context.textTheme.bodySmall?.copyWith(color: AppTheme.primaryOrange)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(ex.difficultyLabel,
                            style: TextStyle(fontSize: 11, color: diffColor, fontWeight: FontWeight.w600)),
                      ),
                      if (ex.muscleGroup != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(ex.muscleGroup!,
                              style: context.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ),
            if (widget.isTrainer)
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _openForm(exercise: ex);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(Color color) {
    return Container(
      width: 90, height: 90,
      color: color.withValues(alpha: 0.12),
      child: Icon(Icons.fitness_center_rounded, color: color, size: 36),
    );
  }

  void _showFilters() {
    String? cat   = _filterCategory;
    String? diff  = _filterDifficulty;
    String? muscle = _filterMuscle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, sc) => ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text('Filtros', style: ctx.textTheme.headlineMedium),
              const SizedBox(height: 16),

              Text('Categoría', style: ctx.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((c) {
                  final sel = cat == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    onSelected: (_) => setModal(() => cat = sel ? null : c),
                    selectedColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textPrimary),
                    backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                    side: BorderSide(color: sel ? AppTheme.primaryOrange : ctx.borderCol),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Text('Dificultad', style: ctx.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _difficulties.map((d) {
                  final sel = diff == d.$1;
                  return ChoiceChip(
                    label: Text(d.$2),
                    selected: sel,
                    onSelected: (_) => setModal(() => diff = sel ? null : d.$1),
                    selectedColor: _diffColor(d.$1),
                    labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textPrimary),
                    backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                    side: BorderSide(color: sel ? _diffColor(d.$1) : ctx.borderCol),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Text('Grupo muscular', style: ctx.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _muscles.map((m) {
                  final sel = muscle == m;
                  return ChoiceChip(
                    label: Text(m),
                    selected: sel,
                    onSelected: (_) => setModal(() => muscle = sel ? null : m),
                    selectedColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textPrimary),
                    backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                    side: BorderSide(color: sel ? AppTheme.primaryOrange : ctx.borderCol),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setModal(() { cat = null; diff = null; muscle = null; });
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterCategory   = cat;
                        _filterDifficulty = diff;
                        _filterMuscle     = muscle;
                      });
                      Navigator.pop(ctx);
                      _fetch(reset: true);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                    child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Color _diffColor(String d) => switch (d) {
        'beginner'     => AppTheme.successColor,
        'intermediate' => AppTheme.warningColor,
        'advanced'     => AppTheme.errorColor,
        _              => AppTheme.textTertiary,
      };

  String _diffLabel(String d) => switch (d) {
        'beginner'     => 'Principiante',
        'intermediate' => 'Intermedio',
        'advanced'     => 'Avanzado',
        _              => d,
      };
}
