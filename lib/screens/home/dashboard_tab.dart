import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dog_provider.dart';
import '../../providers/match_provider.dart';
import '../../models/match_request.dart';
import '../../utils/constants.dart';
import '../dogs/add_dog_screen.dart';
import '../requests/match_requests_screen.dart';

class DashboardTab extends StatelessWidget {
  final Function(int)? onNavigateToTab;
  
  const DashboardTab({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final dogProvider = context.watch<DogProvider>();
    final matchProvider = context.watch<MatchProvider>();

    final userName = authProvider.currentUser?.name ?? 'User';
    final myDogsCount = dogProvider.userDogs.length;
    final pendingRequestsCount = matchProvider.pendingReceivedRequests.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pawfect Match'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (pendingRequestsCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MatchRequestsScreen(),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$pendingRequestsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $userName!',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the perfect breeding partner for your dogs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pets,
                    title: 'My Dogs',
                    value: myDogsCount.toString(),
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.notifications_active,
                    title: 'Requests',
                    value: pendingRequestsCount.toString(),
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Quick Actions',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            if (myDogsCount == 0)
              _ActionCard(
                icon: Icons.add_circle_outline,
                title: 'Add Your First Dog',
                subtitle: 'Create a profile to start matching',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDogScreen()),
                  );
                },
              )
            else
              Column(
                children: [
                  _ActionCard(
                    icon: Icons.search,
                    title: 'Find Matches',
                    subtitle: 'Discover compatible breeding partners',
                    color: AppColors.primary,
                    onTap: () {
                      
                      onNavigateToTab?.call(1);
                    },
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Add Another Dog',
                    subtitle: 'Create profile for another dog',
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddDogScreen()),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final recentRequests = [
                  ...matchProvider.sentRequests,
                  ...matchProvider.receivedRequests,
                ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                final recentActivity = recentRequests.take(5).toList();

                if (recentActivity.isEmpty) {
                  return _buildEmptyActivity(context);
                }

                return Column(
                  children: recentActivity.map((request) {
                    final isReceived = request.targetOwnerId == authProvider.currentUser?.uid;
                    return _ActivityItem(
                      matchRequest: request,
                      isReceived: isReceived,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: theme.colorScheme.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyActivity(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: Text(
        'No recent activity',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

class _ActivityItem extends StatelessWidget {
  final MatchRequest matchRequest;
  final bool isReceived;

  const _ActivityItem({
    required this.matchRequest,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(matchRequest.createdAt);
    final statusColor = matchRequest.status == MatchStatus.accepted
        ? Colors.green
        : matchRequest.status == MatchStatus.rejected
            ? Colors.red
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Icon(
              isReceived ? Icons.arrow_downward : Icons.arrow_upward,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReceived
                      ? 'Received match request'
                      : 'Sent match request',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              matchRequest.status.name.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
