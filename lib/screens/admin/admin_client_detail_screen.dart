import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/admin_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/fade_slide_in.dart';

class AdminClientDetailScreen extends StatefulWidget {
  final int clientId;
  const AdminClientDetailScreen({super.key, required this.clientId});

  @override
  State<AdminClientDetailScreen> createState() => _AdminClientDetailScreenState();
}

class _AdminClientDetailScreenState extends State<AdminClientDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchClientDetail(widget.clientId);
    });
  }

  @override
  void dispose() {
    context.read<AdminProvider>().clearClientDetail();
    super.dispose();
  }

  String _formatTime(String? dt) {
    if (dt == null) return '--:--';
    try {
      return DateFormat('HH:mm').format(DateTime.parse(dt).toLocal());
    } catch (_) {
      return dt;
    }
  }

  String _formatDate(String? dt) {
    if (dt == null) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dt).toLocal());
    } catch (_) {
      return dt;
    }
  }

  Future<void> _openAssignTrainerSheet(BuildContext context, AdminClientDetail client) async {
    final provider = context.read<AdminProvider>();
    await provider.fetchTrainers();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<AdminProvider>(
          builder: (ctx, provider, __) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Asignar Entrenador',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 16),
                    if (provider.loadingTrainers)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.close_rounded, color: Colors.white),
                        ),
                        title: const Text('Sin entrenador',
                            style: TextStyle(color: Colors.black87)),
                        onTap: provider.assigningTrainer
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                final ok = await provider.assignTrainer(widget.clientId, null);
                                _showResultSnackBar(ok, 'Entrenador removido');
                              },
                      ),
                      const Divider(height: 1),
                      ...provider.trainers.map((t) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                            title: Text(t.name,
                                style: const TextStyle(
                                    color: Colors.black87, fontWeight: FontWeight.w600)),
                            subtitle: t.specialty != null
                                ? Text(t.specialty!,
                                    style: const TextStyle(color: Colors.black54))
                                : null,
                            trailing: client.trainer?.id == t.id
                                ? Icon(Icons.check_circle_rounded, color: Colors.orange.shade700)
                                : null,
                            onTap: provider.assigningTrainer
                                ? null
                                : () async {
                                    Navigator.pop(ctx);
                                    final ok = await provider.assignTrainer(widget.clientId, t.id);
                                    _showResultSnackBar(ok, 'Entrenador asignado');
                                  },
                          )),
                      if (provider.trainers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No hay entrenadores activos',
                              style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResultSnackBar(bool ok, String successMessage) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? successMessage : 'No se pudo actualizar el entrenador'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final client = provider.clientDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(client?.name ?? 'Cliente',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: provider.loadingClientDetail
          ? const Center(child: CircularProgressIndicator())
          : provider.clientDetailError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(provider.clientDetailError!),
                      TextButton(
                        onPressed: () =>
                            context.read<AdminProvider>().fetchClientDetail(widget.clientId),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : client == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<AdminProvider>().fetchClientDetail(widget.clientId),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          FadeSlideIn(child: _buildProfileCard(client)),
                          const SizedBox(height: 16),
                          FadeSlideIn(delay: 100.ms, child: _buildTrainerCard(client)),
                          const SizedBox(height: 20),
                          const Text('Historial de Asistencias',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (client.attendances.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Sin asistencias registradas',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ...client.attendances.asMap().entries.map((entry) => FadeSlideIn(
                                  delay: Duration(milliseconds: 150 + (entry.key % 6) * 60),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: const Icon(Icons.how_to_reg_rounded,
                                          color: Colors.green),
                                      title: Text(_formatDate(entry.value.checkIn)),
                                      subtitle: Text(
                                          'Entrada: ${_formatTime(entry.value.checkIn)}   Salida: ${_formatTime(entry.value.checkOut)}'),
                                      trailing: entry.value.duration != null
                                          ? Text('${entry.value.duration} min',
                                              style: const TextStyle(fontWeight: FontWeight.bold))
                                          : null,
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileCard(AdminClientDetail client) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      client.photo != null ? NetworkImage(client.photo!) : null,
                  backgroundColor: Colors.orange.shade100,
                  child: client.photo == null
                      ? Text(
                          client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                          style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (client.document != null)
                        Text('Doc: ${client.document}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (client.phone != null)
                        Text(client.phone!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: client.isActive ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    client.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: client.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (client.membership != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.badge_rounded, size: 18, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${client.membership!.name} · vence ${client.membership!.endDate ?? '-'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (client.membership!.daysRemaining != null)
                    Text(
                      client.membership!.daysRemaining! >= 0
                          ? '${client.membership!.daysRemaining} días'
                          : 'Vencida',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: client.membership!.daysRemaining! >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 18, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text('${client.points} puntos', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard(AdminClientDetail client) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.sports_gymnastics_rounded, color: Colors.orange.shade700),
        title: Text(client.trainer != null ? 'Entrenador' : 'Sin entrenador asignado',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          client.trainer?.name ?? 'Toca para asignar uno',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: TextButton(
          onPressed: () => _openAssignTrainerSheet(context, client),
          child: Text(client.trainer != null ? 'Cambiar' : 'Asignar'),
        ),
      ),
    );
  }
}
