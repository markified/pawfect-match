import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetDogId;
  final String targetOwnerId;
  final double rating;
  final String comment;
  final String? matchRequestId;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetDogId,
    required this.targetOwnerId,
    required this.rating,
    required this.comment,
    this.matchRequestId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'targetDogId': targetDogId,
      'targetOwnerId': targetOwnerId,
      'rating': rating,
      'comment': comment,
      'matchRequestId': matchRequestId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      targetDogId: map['targetDogId'] ?? '',
      targetOwnerId: map['targetOwnerId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      matchRequestId: map['matchRequestId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
