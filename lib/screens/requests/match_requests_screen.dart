import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/dog_profile.dart';
import '../../models/match_request.dart';
import '../../providers/dog_provider.dart';
import '../../providers/match_provider.dart';
import '../../services/compatibility_service.dart';
import '../../utils/constants.dart';
import 'request_detail_screen.dart';

class MatchRequestsScreen extends StatefulWidget {
  const MatchRequestsScreen({super.key});

  @override
  State<MatchRequestsScreen> createState() => _MatchRequestsScreenState();
}

class _MatchRequestsScreenState extends State<MatchRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Match Requests'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReceivedRequestsTab(),
          _SentRequestsTab(),
        ],
      ),
    );
  }
}

class _ReceivedRequestsTab extends StatelessWidget {
  const _ReceivedRequestsTab();

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final receivedRequests = matchProvider.receivedRequests;

    if (receivedRequests.isEmpty) {
      return _buildEmptyState(context, 'No received requests', Icons.inbox_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: receivedRequests.length,
      itemBuilder: (context, index) {
        final request = receivedRequests[index];
        return _RequestCard(
          request: request,
          isReceived: true,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentRequestsTab extends StatelessWidget {
  const _SentRequestsTab();

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final sentRequests = matchProvider.sentRequests;

    if (sentRequests.isEmpty) {
      return _buildEmptyState(context, 'No sent requests', Icons.send_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        final request = sentRequests[index];
        return _RequestCard(
          request: request,
          isReceived: false,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final MatchRequest request;
  final bool isReceived;

  const _RequestCard({
    required this.request,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final dogProvider = context.watch<DogProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    
    final dogId = isReceived ? request.requesterDogId : request.targetDogId;
    final dog = dogProvider.allDogs.firstWhere(
      (d) => d.id == dogId,
      orElse: () => DogProfile(
        id: dogId,
        ownerId: '',
        name: 'Unknown',
        breed: '',
        ageInMonths: 0,
        sex: Sex.male,
        size: '',
        color: '',
        temperaments: [],
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestDetailScreen(
                request: request,
                isReceived: isReceived,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    child: dog.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: dog.imageUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 30),
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dog.name,
                                style: AppTextStyles.heading3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusBadge(status: request.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dog.breed,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(request.createdAt),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: _getCompatibilityColor(request.compatibilityScore),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Compatibility: ${CompatibilityService.getCompatibilityPercentage(request.compatibilityScore)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getCompatibilityColor(request.compatibilityScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CompatibilityService.getCompatibilityRating(
                      request.compatibilityScore,
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              if (request.message != null && request.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.message!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              
              if (isReceived && request.status == MatchStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleReject(context, request),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleAccept(context, request),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (request.status == MatchStatus.accepted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleComplete(context, request),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark as Completed'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCompatibilityColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.65) return AppColors.primary;
    if (score >= 0.5) return AppColors.accent;
    return AppColors.error;
  }

  Future<void> _handleAccept(BuildContext context, MatchRequest request) async {
    final matchProvider = context.read<MatchProvider>();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Match Request'),
        content: const Text(
          'Are you sure you want to accept this breeding match request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await matchProvider.updateMatchRequestStatus(
        request,
        MatchStatus.accepted,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match request accepted!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, MatchRequest request) async {
    final matchProvider = context.read<MatchProvider>();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Match Request'),
        content: const Text(
          'Are you sure you want to reject this breeding match request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await matchProvider.updateMatchRequestStatus(
        request,
        MatchStatus.rejected,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match request rejected')),
        );
      }
    }
  }

  Future<void> _handleComplete(
    BuildContext context,
    MatchRequest request,
  ) async {
    final matchProvider = context.read<MatchProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
          'Mark this breeding match as completed? You can then leave a review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await matchProvider.updateMatchRequestStatus(
      request,
      MatchStatus.completed,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match marked as completed!')),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case MatchStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        text = 'Pending';
        break;
      case MatchStatus.accepted:
        color = AppColors.success;
        icon = Icons.check_circle;
        text = 'Accepted';
        break;
      case MatchStatus.rejected:
        color = AppColors.error;
        icon = Icons.cancel;
        text = 'Rejected';
        break;
      case MatchStatus.completed:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        text = 'Completed';
        break;
      case MatchStatus.cancelled:
        color = Colors.grey;
        icon = Icons.block;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
