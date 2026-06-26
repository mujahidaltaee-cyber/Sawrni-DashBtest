class SawrniDeliveryItem {
  final int id;
  final int bookingId;
  final String title;
  final String status;
  final String? fileName;
  final String? notes;
  final String? createdAt;

  const SawrniDeliveryItem({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.status,
    this.fileName,
    this.notes,
    this.createdAt,
  });

  factory SawrniDeliveryItem.fromJson(Map<String, dynamic> json) {
    return SawrniDeliveryItem(
      id: (json['id'] ?? 0) as int,
      bookingId: (json['booking_id'] ?? 0) as int,
      title: (json['title'] ?? 'ملفات التسليم').toString(),
      status: (json['status'] ?? '').toString(),
      fileName: json['original_filename']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
