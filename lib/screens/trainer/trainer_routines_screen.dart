import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';
import '../../models/trainer_model.dart';

class TrainerRoutinesScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  const TrainerRoutinesScreen({super.key, required this.clientId, required this.clientName});

  @override
  State<TrainerRoutinesScreen> createState() => _TrainerRoutinesScreenState();
}

class _TrainerRoutinesScreenState extends State<TrainerRoutinesScreen> {
  static const _dayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().fetchRoutines(widget.clientId);
    });
  }

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> pickDate(TextEditingController ctrl) async {
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nueva Rutina', style: ctx.textTheme.headlineMedium),
              const SizedBox(height: AppTheme.spacing16),
              TextFormField(
                controller: nameCtrl,
                decoration: _sheetDecor(ctx, 'Nombre de la rutina'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppTheme.spacing8),
              TextFormField(
                controller: descCtrl,
                maxLines: 2,
                decoration: _sheetDecor(ctx, 'Descripción (opcional)'),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: startCtrl,
                  readOnly: true,
                  onTap: () => pickDate(startCtrl),
                  decoration: _sheetDecor(ctx, 'Inicio', suffix: const Icon(Icons.calendar_today, size: 16)),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  controller: endCtrl,
                  readOnly: true,
                  onTap: () => pickDate(endCtrl),
                  decoration: _sheetDecor(ctx, 'Fin', suffix: const Icon(Icons.calendar_today, size: 16)),
                )),
              ]),
              const SizedBox(height: AppTheme.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final data = <String, dynamic>{'name': nameCtrl.text.trim()};
                    if (descCtrl.text.isNotEmpty) data['description'] = descCtrl.text.trim();
                    if (startCtrl.text.isNotEmpty) data['start_date'] = startCtrl.text;
                    if (endCtrl.text.isNotEmpty) data['end_date'] = endCtrl.text;
                    Navigator.of(ctx).pop();
                    final ok = await context.read<TrainerProvider>().createRoutine(widget.clientId, data);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Rutina creada' : 'Error al crear'),
                      backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
                  ),
                  child: const Text('Crear Rutina', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDayDialog(RoutineModel routine) async {
    String? selectedDay;
    final focusCtrl = TextEditingController();

    // Días ya configurados en esta rutina
    final usedDays = routine.days.map((d) => d.dayName).toSet();
    final availableDays = _dayNames.where((d) => !usedDays.contains(d)).toList();

    if (availableDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya están configurados todos los días'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar Día — ${routine.name}', style: ctx.textTheme.headlineMedium),
              const SizedBox(height: AppTheme.spacing16),
              Text('Día de la semana', style: ctx.textTheme.bodySmall),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableDays.map((day) {
                  final sel = selectedDay == day;
                  return ChoiceChip(
                    label: Text(day),
                    selected: sel,
                    onSelected: (_) => setModal(() => selectedDay = day),
                    selectedColor: AppTheme.primaryOrange,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : AppTheme.textPrimary,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
                    side: BorderSide(color: sel ? AppTheme.primaryOrange : ctx.borderCol),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing12),
              TextFormField(
                controller: focusCtrl,
                decoration: _sheetDecor(ctx, 'Enfoque (ej: Pecho y Tríceps)'),
              ),
              const SizedBox(height: AppTheme.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedDay == null
                      ? null
                      : () async {
                          final data = <String, dynamic>{'day_name': selectedDay!};
                          if (focusCtrl.text.isNotEmpty) data['focus'] = focusCtrl.text.trim();
                          Navigator.of(ctx).pop();
                          final ok = await context.read<TrainerProvider>()
                              .addRoutineDay(widget.clientId, routine.id, data);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Día agregado' : 'Error al agregar'),
                            backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
                          ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
                  ),
                  child: const Text('Agregar Día', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Rutinas: ${widget.clientName}', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchRoutines(widget.clientId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Rutina'),
      ),
      body: provider.loadingRoutines
          ? const Center(child: CircularProgressIndicator())
          : provider.routines.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.fetchRoutines(widget.clientId),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: provider.routines.length,
                    itemBuilder: (context, i) =>
                        _routineCard(provider.routines[i]).animate().fadeIn(delay: (i * 60).ms),
                  ),
                ),
    );
  }

  Widget _routineCard(RoutineModel r) {
    final provider = context.read<TrainerProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: r.isActive ? AppTheme.successColor.withValues(alpha: 0.4) : context.borderCol,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (r.isActive ? AppTheme.successColor : AppTheme.textTertiary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Icons.list_alt_rounded,
                    color: r.isActive ? AppTheme.successColor : AppTheme.textTertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15)),
                      if (r.description != null && r.description!.isNotEmpty)
                        Text(r.description!, style: context.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (r.startDate != null)
                        Text('${r.startDate} → ${r.endDate ?? 'Sin fin'}',
                            style: context.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
                Switch(
                  value: r.isActive,
                  activeColor: AppTheme.successColor,
                  onChanged: (_) => provider.toggleRoutine(widget.clientId, r.id),
                ),
              ],
            ),
          ),

          // Días
          if (r.days.isNotEmpty) ...[
            Divider(color: context.borderCol, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text('Días de entrenamiento', style: context.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: r.days.map((d) => _dayChip(d, r)).toList(),
              ),
            ),
          ],

          // Botón agregar día
          Divider(color: context.borderCol, height: 1),
          TextButton.icon(
            onPressed: () => _showAddDayDialog(r),
            icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryOrange),
            label: const Text('Agregar día', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayChip(RoutineDayModel day, RoutineModel routine) {
    return Chip(
      label: Text(
        day.focus != null ? '${day.dayName}: ${day.focus}' : day.dayName,
        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
      ),
      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.12),
      side: const BorderSide(color: AppTheme.primaryOrange, width: 0.5),
      deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.textTertiary),
      onDeleted: () async {
        final ok = await context.read<TrainerProvider>()
            .removeRoutineDay(widget.clientId, routine.id, day.id);
        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar día'), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt_outlined, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text('Sin rutinas asignadas', style: context.textTheme.bodyLarge?.copyWith(color: AppTheme.textTertiary)),
            const SizedBox(height: 8),
            Text('Toca + para crear una rutina', style: context.textTheme.bodySmall),
          ],
        ),
      );

  InputDecoration _sheetDecor(BuildContext ctx, String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        filled: true,
        fillColor: ctx.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: ctx.borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(color: ctx.borderCol),
        ),
      );
}
