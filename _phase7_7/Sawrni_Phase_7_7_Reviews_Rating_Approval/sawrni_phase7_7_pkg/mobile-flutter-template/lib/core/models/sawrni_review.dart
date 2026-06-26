class SawrniReview {
  final int id;
  final int providerId;
  final int rating;
  final String status;
  final String? comment;
  final DateTime? approvedAt;

  const SawrniReview({
    required this.id,
    required this.providerId,
    required this.rating,
    required this.status,
    this.comment,
    this.approvedAt,
  });

  factory SawrniReview.fromJson(Map<String, dynamic> json) {
    return SawrniReview(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      providerId: int.tryParse('${json['provider_id'] ?? 0}') ?? 0,
      rating: int.tryParse('${json['rating'] ?? 0}') ?? 0,
      status: '${json['status'] ?? 'pending_review'}',
      comment: json['comment']?.toString(),
      approvedAt: json['approved_at'] == null ? null : DateTime.tryParse('${json['approved_at']}'),
    );
  }
}
