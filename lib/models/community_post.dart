import 'package:cloud_firestore/cloud_firestore.dart';

enum PostCategory {
  general,
  breedingTips,
  healthCare,
  training,
  success,
  question,
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String title;
  final String content;
  final PostCategory category;
  final List<String> imageUrls;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrls = const [],
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'title': title,
      'content': content,
      'category': category.name,
      'imageUrls': imageUrls,
      'likes': likes,
      'likedBy': likedBy,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorImageUrl: map['authorImageUrl'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: PostCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => PostCategory.general,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    String? title,
    String? content,
    PostCategory? category,
    List<String>? imageUrls,
    int? likes,
    List<String>? likedBy,
    int? commentCount,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String getCategoryDisplay() {
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

class PostComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String content;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorImageUrl: map['authorImageUrl'],
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
