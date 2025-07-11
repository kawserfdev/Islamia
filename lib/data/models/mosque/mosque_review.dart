import 'dart:convert';

class MosqueReview {
  final String id;
  final String mosqueId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final int helpfulCount;
  final Map<String, dynamic> metadata;

  const MosqueReview({
    required this.id,
    required this.mosqueId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.helpfulCount = 0,
    this.metadata = const {},
  });

  factory MosqueReview.fromJson(Map<String, dynamic> json) {
    return MosqueReview(
      id: json['id'],
      mosqueId: json['mosque_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userPhoto: json['user_photo'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      photos: json['photos'] is String 
          ? List<String>.from(jsonDecode(json['photos']))
          : List<String>.from(json['photos'] ?? []),
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'])
          : DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? (json['updated_at'] is String 
              ? DateTime.parse(json['updated_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['updated_at']))
          : null,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      helpfulCount: json['helpful_count'] ?? 0,
      metadata: json['metadata'] is String 
          ? Map<String, dynamic>.from(jsonDecode(json['metadata']))
          : Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mosque_id': mosqueId,
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'rating': rating,
      'comment': comment,
      'photos': jsonEncode(photos),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'is_verified': isVerified ? 1 : 0,
      'helpful_count': helpfulCount,
      'metadata': jsonEncode(metadata),
    };
  }
} 