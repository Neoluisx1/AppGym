import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';
import '../../models/trainer_model.dart';
import 'trainer_client_detail_screen.dart';

class TrainerClientsScreen extends StatefulWidget {
  const TrainerClientsScreen({super.key});

  @override
  State<TrainerClientsScreen> createState() => _TrainerClientsScreenState();
}

class _TrainerClientsScreenState extends State<TrainerClientsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().fetchClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerProvider>();
    final all      = provider.clients;
    final active   = all.where((c) => c.isActive).toList();
    final inactive = all.where((c) => !c.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clientes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Todos (${all.length})'),
            Tab(text: 'Activos (${active.length})'),
            Tab(text: 'Vencidos (${inactive.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o documento...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TrainerProvider>().fetchClients();
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                if (v.length >= 2 || v.isEmpty) {
                  context.read<TrainerProvider>().fetchClients(search: v);
                }
              },
            ),
          ),

          // Tab content
          Expanded(
            child: provider.loadingClients && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(context, all),
                      _buildList(context, active),
                      _buildList(context, inactive),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<TrainerClientModel> clients) {
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outlined, size: 56, color: context.textTertCol),
            const SizedBox(height: 12),
            Text('Sin clientes', style: context.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TrainerProvider>().refreshClients(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        itemCount: clients.length,
        itemBuilder: (context, index) => _buildClientCard(context, clients[index])
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 40), duration: 300.ms)
            .slideX(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, TrainerClientModel client) {
    final color = client.isActive ? AppTheme.successColor : AppTheme.errorColor;
    final statusLabel = client.isActive
        ? (client.daysRemaining != null ? '${client.daysRemaining} días' : 'Activa')
        : 'Vencida';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrainerClientDetailScreen(clientId: client.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
              backgroundImage: client.photo != null ? NetworkImage(client.photo!) : null,
              child: client.photo == null
                  ? Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spacing12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.membership ?? 'Sin membresía',
                    style: context.textTheme.bodySmall,
                  ),
                  if (client.document != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Doc: ${client.document}',
                      style: context.textTheme.bodySmall?.copyWith(color: context.textTertCol),
                    ),
                  ],
                ],
              ),
            ),

            // Status + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 12, color: AppTheme.warningColor),
                    const SizedBox(width: 3),
                    Text(
                      '${client.points} pts',
                      style: context.textTheme.bodySmall?.copyWith(color: AppTheme.warningColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertCol),
          ],
        ),
      ),
    );
  }
}
