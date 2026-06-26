class SawrniNotification {
  final String id;
  final String titleAr;
  final String bodyAr;
  final String type;
  final String audience;
  final bool isRead;
  final DateTime createdAt;

  const SawrniNotification({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.type,
    required this.audience,
    required this.isRead,
    required this.createdAt,
  });

  factory SawrniNotification.fromJson(Map<String, dynamic> json) {
    return SawrniNotification(
      id: '${json['id'] ?? ''}',
      titleAr: '${json['title_ar'] ?? ''}',
      bodyAr: '${json['body_ar'] ?? ''}',
      type: '${json['type'] ?? 'general'}',
      audience: '${json['audience'] ?? 'customer'}',
      isRead: json['read_at'] != null || json['is_read'] == true,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}
