import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/community_post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../utils/constants.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().listenToCommunityPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh posts',
            onPressed: () {
              communityProvider.listenToCommunityPosts();
            },
          ),
          PopupMenuButton<PostCategory?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by category',
            onSelected: (category) {
              communityProvider.filterByCategory(category);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Posts'),
              ),
              ...PostCategory.values.map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Text(_getCategoryDisplay(category)),
                );
              }),
            ],
          ),
        ],
      ),
      body: communityProvider.posts.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                communityProvider.listenToCommunityPosts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: communityProvider.posts.length,
                itemBuilder: (context, index) {
                  final post = communityProvider.posts[index];
                  return _PostCard(
                    post: post,
                    currentUserId: authProvider.currentUser?.uid ?? '',
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text('No Posts Yet', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Be the first to share with the community!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplay(PostCategory category) {
    switch (category) {
      case PostCategory.general:
        return 'General';
      case PostCategory.breedingTips:
        return 'Breeding Tips';
      case PostCategory.healthCare:
        return 'Health Care';
      case PostCategory.training:
        return 'Training';
      case PostCategory.success:
        return 'Success Story';
      case PostCategory.question:
        return 'Question';
    }
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final String currentUserId;

  const _PostCard({
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');
    final isLiked = post.likedBy.contains(currentUserId);

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
              builder: (_) => PostDetailScreen(post: post),
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: post.authorImageUrl != null
                        ? CachedNetworkImageProvider(post.authorImageUrl!)
                        : null,
                    child: post.authorImageUrl == null
                        ? Text(
                            post.authorName[0].toUpperCase(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormat.format(post.createdAt),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(post.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(post.category),
                      ),
                    ),
                    child: Text(
                      post.getCategoryDisplay(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getCategoryColor(post.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                post.title,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              
              Text(
                post.content,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrls.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                if (post.imageUrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${post.imageUrls.length - 1} more',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: post.likes.toString(),
                    color: isLiked ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                    onTap: () {
                      context
                          .read<CommunityProvider>()
                          .toggleLike(post.id, currentUserId);
                    },
                  ),
                  const SizedBox(width: 24),
                  _ActionButton(
                    icon: Icons.comment_outlined,
                    label: post.commentCount.toString(),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  if (post.authorId == currentUserId)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () {
                        _showPostOptions(context, post);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(PostCategory category) {
    switch (category) {
      case PostCategory.general:
        return AppColors.primary;
      case PostCategory.breedingTips:
        return AppColors.accent;
      case PostCategory.healthCare:
        return Colors.red;
      case PostCategory.training:
        return AppColors.primary;
      case PostCategory.success:
        return AppColors.success;
      case PostCategory.question:
        return Colors.orange;
    }
  }

  void _showPostOptions(BuildContext context, CommunityPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Material(
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(context);
                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text(
                  'Delete Post',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text(
                        'Are you sure you want to delete this post? This action cannot be undone.',
                      ),
                      actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<CommunityProvider>().deletePost(post.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}



