import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/community_post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    if (authProvider.currentUser == null) return;

    final comment = PostComment(
      id: '${authProvider.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      authorId: authProvider.currentUser!.uid,
      authorName: authProvider.currentUser!.name,
      authorImageUrl: authProvider.currentUser!.profileImageUrl,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await communityProvider.createComment(comment);

    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isLiked = widget.post.likedBy.contains(currentUserId);
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post content
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: widget.post.authorImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      widget.post.authorImageUrl!)
                                  : null,
                              child: widget.post.authorImageUrl == null
                                  ? Text(
                                      widget.post.authorName[0].toUpperCase(),
                                      style: AppTextStyles.bodyLarge.copyWith(
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
                                    widget.post.authorName,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(widget.post.createdAt),
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Text(
                                widget.post.getCategoryDisplay(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          widget.post.title,
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 12),
                        // Content
                        Text(
                          widget.post.content,
                          style: AppTextStyles.bodyMedium,
                        ),
                        // Images
                        if (widget.post.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...widget.post.imageUrls.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadius,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        // Like button
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context
                                    .read<CommunityProvider>()
                                    .toggleLike(widget.post.id, currentUserId);
                              },
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : AppColors.textSecondary,
                              ),
                              label: Text(
                                '${widget.post.likes}',
                                style: TextStyle(
                                  color:
                                      isLiked ? Colors.red : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.comment_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.post.commentCount}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Comments section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<PostComment>>(
                          stream: _firestoreService.getPostComments(widget.post.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No comments yet. Be the first to comment!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return Column(
                              children: snapshot.data!.map((comment) {
                                return _CommentCard(comment: comment);
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Comment input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: AppSizes.paddingMedium,
              right: AppSizes.paddingMedium,
              top: AppSizes.paddingSmall,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  AppSizes.paddingSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final PostComment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: comment.authorImageUrl != null
                ? CachedNetworkImageProvider(comment.authorImageUrl!)
                : null,
            child: comment.authorImageUrl == null
                ? Text(
                    comment.authorName[0].toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
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
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(comment.createdAt),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
