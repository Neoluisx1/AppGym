import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';
import '../../widgets/fade_slide_in.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asistencia Hoy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              DateFormat('EEEE d MMMM', 'es').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AdminProvider>().fetchTodayAttendance(),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AdminProvider provider) {
    if (provider.loadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.attendanceError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.attendanceError!),
            TextButton(
              onPressed: () =>
                  context.read<AdminProvider>().fetchTodayAttendance(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.todayAttendance.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.how_to_reg_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Sin asistencias hoy',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().fetchTodayAttendance(),
      child: Column(
        children: [
          FadeSlideIn(child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.todayAttendance.length} registros',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: provider.todayAttendance.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => FadeSlideIn(
                delay: Duration(milliseconds: (index % 6) * 60),
                child: _AttendanceCard(record: provider.todayAttendance[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AdminAttendanceRecord record;

  const _AttendanceCard({required this.record});

  String _formatTime(String? dt) {
    if (dt == null) return '--:--';
    try {
      return DateFormat('HH:mm').format(DateTime.parse(dt).toLocal());
    } catch (_) {
      return dt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckOut = record.checkOut != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  record.photo != null ? NetworkImage(record.photo!) : null,
              backgroundColor: Colors.orange.shade100,
              child: record.photo == null
                  ? Text(
                      record.name.isNotEmpty
                          ? record.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TimeChip(
                          label: 'Entrada',
                          time: _formatTime(record.checkIn),
                          color: Colors.green),
                      const SizedBox(width: 8),
                      if (hasCheckOut)
                        _TimeChip(
                            label: 'Salida',
                            time: _formatTime(record.checkOut),
                            color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (record.duration != null)
                  Text('${record.duration} min',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasCheckOut
                        ? Colors.grey.shade100
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasCheckOut ? 'Finalizado' : 'Activo',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasCheckOut
                          ? Colors.grey.shade600
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _TimeChip(
      {required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $time',
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
