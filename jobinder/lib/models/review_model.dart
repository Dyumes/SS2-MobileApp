import 'package:cloud_firestore/cloud_firestore.dart';


class Review {
  final String id;
  final String reviewer_user;
  final String reviewee_user;
  final String comment;
  final int note;
  final DateTime timestamp;

  Review({
    this.id = '',
    required this.reviewer_user,
    required this.reviewee_user,
    required this.comment,
    required this.note,
    required this.timestamp
  });

  factory Review.fromMap(Map<String, dynamic> data, String docId) {
    return Review(
      id: docId,
      reviewer_user: (data['reviewer_user'] as DocumentReference?)?.id ?? '',
      reviewee_user: (data['reviewee_user'] as DocumentReference?)?.id ?? '',
      comment: data['comment'] ?? '',
      note: data['note'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewer_user': reviewer_user,
      'reviewee_user': reviewee_user,
      'comment': comment,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  Review copyWith({
    String? id,
    String? reviewer_user,
    String? reviewee_user,
    String? comment,
    int? note,
    DateTime? timestamp,
  }) {
    return Review(
      id: id ?? this.id,
      reviewer_user: reviewer_user ?? this.reviewer_user,
      reviewee_user: reviewee_user ?? this.reviewee_user,
      comment: comment ?? this.comment,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}