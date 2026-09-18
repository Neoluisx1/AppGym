import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminPushScreen extends StatefulWidget {
  const AdminPushScreen({super.key});

  @override
  State<AdminPushScreen> createState() => _AdminPushScreenState();
}

class _PushTarget {
  final String value;
  final String label;
  final IconData icon;

  const _PushTarget(this.value, this.label, this.icon);
}

const _pushTargets = [
  _PushTarget('all', 'Todos los clientes', Icons.groups_rounded),
  _PushTarget('expiring', 'Membresías por vencer', Icons.schedule_rounded),
  _PushTarget('expired', 'Membresías vencidas', Icons.event_busy_rounded),
  _PushTarget('instructors', 'Solo instructores', Icons.sports_gymnastics_rounded),
];

class _AdminPushScreenState extends State<AdminPushScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '7');

  String _target = 'all';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdminProvider>();
    final result = await provider.sendPushNotification(
      title: _titleCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      target: _target,
      days: _target == 'expiring' ? int.tryParse(_daysCtrl.text) ?? 7 : null,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ??
            (result.success ? 'Notificación enviada' : 'Error al enviar notificación')),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      _titleCtrl.clear();
      _messageCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final selected = _pushTargets.firstWhere((t) => t.value == _target);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Notificación Masiva',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign_rounded,
                        color: Colors.orange.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Envía una notificación push al grupo que elijas abajo.',
                        style: TextStyle(
                            color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Enviar a',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pushTargets.map((t) {
                  final isSelected = t.value == _target;
                  return ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) => setState(() => _target = t.value),
                    avatar: Icon(
                      t.icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.orange.shade700,
                    ),
                    label: Text(t.label),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: Colors.orange.shade700,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.orange.shade700 : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_target == 'expiring') ...[
                const SizedBox(height: 16),
                const Text('Vencen dentro de (días)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Ej: 7',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (_target != 'expiring') return null;
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Ingresa un número de días válido';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              const Text('Título',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                maxLength: 100,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: Promoción especial',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              const Text('Mensaje',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageCtrl,
                maxLength: 500,
                maxLines: 4,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Escribe el contenido de la notificación...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa un mensaje' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: provider.sendingPush ? null : _send,
                  icon: provider.sendingPush
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(provider.sendingPush
                      ? 'Enviando...'
                      : 'Enviar a: ${selected.label}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
