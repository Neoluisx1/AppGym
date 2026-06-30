// 💳 Membership Plans Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/membership_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/membership_plan_model.dart';

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({Key? key}) : super(key: key);

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MembershipProvider>().fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = context.watch<MembershipProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentMembership = authProvider.user?.client?.membership;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Membresía'),
      ),
      body: membershipProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => membershipProvider.fetchPlans(),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentMembership != null) ...[
                      _buildCurrentMembershipCard(currentMembership),
                      SizedBox(height: AppTheme.spacing24),
                    ],
                    
                    Text(
                      'Planes Disponibles',
                      style: context.textTheme.headlineSmall,
                    ),
                    SizedBox(height: AppTheme.spacing16),
                    
                    ...membershipProvider.plans.map((plan) => 
                      _buildPlanCard(plan, membershipProvider)
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentMembershipCard(membership) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership, color: Colors.white, size: 28),
              SizedBox(width: AppTheme.spacing12),
              Text(
                'TU MEMBRESÍA ACTUAL',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            membership.name,
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            membership.daysRemaining != null
                ? 'Vence en ${membership.daysRemaining} días'
                : 'Membresía activa',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MembershipPlanModel plan, MembershipProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: plan.isPopular ? AppTheme.primaryOrange : context.borderCol,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular ? AppTheme.glowShadow : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Text(
                '⭐ MÁS POPULAR',
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            plan.displayDuration,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.textSecondCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bs. ${plan.price.toStringAsFixed(2)}',
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (plan.type == 'business_days' && plan.availableDays != null)
                          Text(
                            '${plan.availableDays} días hábiles',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondCol,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: AppTheme.spacing16),
                
                Text(
                  plan.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondCol,
                  ),
                ),
                
                if (plan.features.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacing16),
                  ...plan.features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacing8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        SizedBox(width: AppTheme.spacing8),
                        Expanded(
                          child: Text(
                            feature,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                SizedBox(height: AppTheme.spacing16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showContactAdminDialog(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPopular
                          ? AppTheme.primaryOrange
                          : context.surfaceColor,
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: plan.isPopular ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(width: AppTheme.spacing8),
                        Text(
                          'Ver información del plan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: plan.isPopular ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactAdminDialog(MembershipPlanModel plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryOrange),
            SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text('${plan.name}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio: Bs. ${plan.price.toStringAsFixed(2)}',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              plan.description,
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: AppTheme.spacing16),
            Container(
              padding: EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppTheme.primaryOrange, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      'Para renovar tu membresía, contacta con la administración del gimnasio.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
