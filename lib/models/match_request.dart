import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled
}

class MatchRequest {
  final String id;
  final String requesterId;
  final String requesterDogId;
  final String targetOwnerId;
  final String targetDogId;
  final MatchStatus status;
  final double compatibilityScore;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;

  MatchRequest({
    required this.id,
    required this.requesterId,
    required this.requesterDogId,
    required this.targetOwnerId,
    required this.targetDogId,
    required this.status,
    required this.compatibilityScore,
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterDogId': requesterDogId,
      'targetOwnerId': targetOwnerId,
      'targetDogId': targetDogId,
      'status': status.name,
      'compatibilityScore': compatibilityScore,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory MatchRequest.fromMap(Map<String, dynamic> map) {
    return MatchRequest(
      id: map['id'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterDogId: map['requesterDogId'] ?? '',
      targetOwnerId: map['targetOwnerId'] ?? '',
      targetDogId: map['targetDogId'] ?? '',
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.pending,
      ),
      compatibilityScore: (map['compatibilityScore'] ?? 0.0).toDouble(),
      message: map['message'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  MatchRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterDogId,
    String? targetOwnerId,
    String? targetDogId,
    MatchStatus? status,
    double? compatibilityScore,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? completedAt,
  }) {
    return MatchRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterDogId: requesterDogId ?? this.requesterDogId,
      targetOwnerId: targetOwnerId ?? this.targetOwnerId,
      targetDogId: targetDogId ?? this.targetDogId,
      status: status ?? this.status,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
