import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/admin_model.dart';

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Clientes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange.shade700,
          tabs: [
            Tab(
              text:
                  'Por vencer (${provider.expiringClients.length})',
            ),
            const Tab(text: 'Buscar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ExpiringTab(provider: provider),
          _SearchTab(
            provider: provider,
            searchCtrl: _searchCtrl,
          ),
        ],
      ),
    );
  }
}

class _ExpiringTab extends StatelessWidget {
  final AdminProvider provider;

  const _ExpiringTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.loadingExpiring) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.expiringClients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text('Sin membresías por vencer en 7 días',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<AdminProvider>().fetchExpiringMemberships(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.expiringClients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) =>
            _ExpiringClientCard(client: provider.expiringClients[i]),
      ),
    );
  }
}

class _ExpiringClientCard extends StatelessWidget {
  final AdminExpiringClient client;

  const _ExpiringClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final isUrgent = client.daysRemaining <= 2;
    final color = isUrgent ? Colors.red : Colors.orange;

    String endDateStr = '';
    if (client.membershipEnd != null) {
      try {
        endDateStr = DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(client.membershipEnd!));
      } catch (_) {
        endDateStr = client.membershipEnd!;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundImage:
              client.photo != null ? NetworkImage(client.photo!) : null,
          backgroundColor: color.withValues(alpha: 0.15),
          child: client.photo == null
              ? Text(
                  client.name.isNotEmpty
                      ? client.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(client.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.phone != null)
              Text(client.phone!,
                  style: const TextStyle(fontSize: 12)),
            if (endDateStr.isNotEmpty)
              Text('Vence: $endDateStr',
                  style:
                      TextStyle(fontSize: 12, color: color.shade700)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${client.daysRemaining}d',
            style: TextStyle(
                color: color.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  final AdminProvider provider;
  final TextEditingController searchCtrl;

  const _SearchTab({required this.provider, required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, documento o teléfono...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        searchCtrl.clear();
                        context.read<AdminProvider>().clearSearch();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) =>
                context.read<AdminProvider>().searchClients(v),
          ),
        ),
        if (provider.loadingSearch)
          const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          )
        else if (provider.searchResults.isEmpty && searchCtrl.text.length >= 2)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Sin resultados', style: TextStyle(color: Colors.grey)),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: provider.searchResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _SearchClientCard(client: provider.searchResults[i]),
            ),
          ),
      ],
    );
  }
}

class _SearchClientCard extends StatelessWidget {
  final AdminSearchClient client;

  const _SearchClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    String endStr = '';
    if (client.membershipEnd != null) {
      try {
        endStr = DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(client.membershipEnd!));
      } catch (_) {
        endStr = client.membershipEnd!;
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              client.photo != null ? NetworkImage(client.photo!) : null,
          backgroundColor: Colors.orange.shade100,
          child: client.photo == null
              ? Text(
                  client.name.isNotEmpty
                      ? client.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.orange.shade700),
                )
              : null,
        ),
        title: Text(client.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (client.document != null) 'Doc: ${client.document}',
            if (client.phone != null) client.phone!,
          ].join(' · '),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: client.isActive
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                client.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 11,
                  color: client.isActive
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (endStr.isNotEmpty)
              Text(endStr,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
