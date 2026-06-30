// 🏋️ Group Classes Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_class_provider.dart';
import '../../models/group_class_model.dart';

class GroupClassesScreen extends StatefulWidget {
  const GroupClassesScreen({Key? key}) : super(key: key);

  @override
  State<GroupClassesScreen> createState() => _GroupClassesScreenState();
}

class _GroupClassesScreenState extends State<GroupClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupClassProvider>().fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<GroupClassProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases Grupales'),
      ),
      body: classProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => classProvider.fetchClasses(),
              child: classProvider.classes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      itemCount: classProvider.classes.length,
                      itemBuilder: (context, index) {
                        final groupClass = classProvider.classes[index];
                        return _buildClassCard(groupClass, classProvider);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: context.textTertCol,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No hay clases disponibles',
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(GroupClassModel groupClass, GroupClassProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (groupClass.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
              child: Image.network(
                groupClass.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: context.surfaceColor,
                  child: Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: context.textTertCol,
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        groupClass.name,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDifficultyBadge(groupClass.difficulty),
                  ],
                ),
                
                SizedBox(height: AppTheme.spacing8),
                
                if (groupClass.instructor != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: context.textSecondCol,
                      ),
                      SizedBox(width: AppTheme.spacing4),
                      Text(
                        groupClass.instructor!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.textSecondCol,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: AppTheme.spacing8),

                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: context.textSecondCol,
                    ),
                    SizedBox(width: AppTheme.spacing4),
                    Text(
                      groupClass.schedule,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondCol,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing16),
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: context.textSecondCol,
                    ),
                    SizedBox(width: AppTheme.spacing4),
                    Text(
                      '${groupClass.duration} min',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondCol,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppTheme.spacing12),
                
                Text(
                  groupClass.description,
                  style: context.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: AppTheme.spacing16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cupos disponibles',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondCol,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: groupClass.isFull 
                                    ? AppTheme.errorColor 
                                    : AppTheme.successColor,
                              ),
                              SizedBox(width: AppTheme.spacing4),
                              Text(
                                '${groupClass.availableSpots} de ${groupClass.capacity}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: groupClass.isFull 
                                      ? AppTheme.errorColor 
                                      : AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: groupClass.isFull || provider.isLoading
                          ? null
                          : () => _handleEnroll(groupClass, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing24,
                          vertical: AppTheme.spacing12,
                        ),
                      ),
                      child: Text(
                        groupClass.isFull ? 'Lleno' : 'Inscribirse',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = AppTheme.successColor;
        label = 'Fácil';
        break;
      case 'hard':
        color = AppTheme.errorColor;
        label = 'Difícil';
        break;
      default:
        color = AppTheme.warningColor;
        label = 'Medio';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleEnroll(GroupClassModel groupClass, GroupClassProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inscripción'),
        content: Text(
          '¿Deseas inscribirte en la clase "${groupClass.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await provider.enrollInClass(groupClass.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscripción exitosa'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al inscribirse'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
