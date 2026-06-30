import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trainer_provider.dart';
import '../../providers/chat_provider.dart';
import '../shared/exercise_list_screen.dart';
import 'trainer_dashboard_screen.dart';
import 'trainer_clients_screen.dart';
import 'trainer_chat_list_screen.dart';

class TrainerMainScreen extends StatefulWidget {
  const TrainerMainScreen({super.key});

  @override
  State<TrainerMainScreen> createState() => _TrainerMainScreenState();
}

class _TrainerMainScreenState extends State<TrainerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TrainerDashboardScreen(),
    TrainerClientsScreen(),
    ExerciseListScreen(isTrainer: true),
    TrainerChatListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().fetchDashboard();
      context.read<TrainerProvider>().fetchClients();
      context.read<ChatProvider>().fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<ChatProvider>().clients
        .fold<int>(0, (sum, c) => sum + c.unread);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clientes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books_rounded),
            label: 'Ejercicios',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
