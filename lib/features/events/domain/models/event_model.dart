import 'package:equatable/equatable.dart';

/// Model representing an event
class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final String organizerEmail;
  final String organizerPhone;
  final String imageUrl;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final String status;
  final bool isRegistered;
  final bool isPaid;
  final double? price;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    this.organizerEmail = '',
    this.organizerPhone = '',
    this.imageUrl = '',
    required this.category,
    required this.createdBy,
    required this.createdAt,
    this.status = 'Needs Approval',
    this.isRegistered = false,
    this.isPaid = false,
    this.price,
  });

  /// Create an EventModel from Supabase data
  factory EventModel.fromSupabase(
    Map<String, dynamic> data, {
    bool isRegistered = false,
  }) {
    return EventModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date:
          data['date'] != null
              ? DateTime.parse(data['date'].toString())
              : DateTime.now(),
      location: data['location'] ?? '',
      organizer: data['organizer'] ?? '',
      organizerEmail: data['organizer_email'] ?? '',
      organizerPhone: data['organizer_phone'] ?? '',
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      createdBy: data['created_by'] ?? '',
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'].toString())
              : DateTime.now(),
      status: data['status'] ?? 'Needs Approval',
      isRegistered: isRegistered,
      isPaid: data['is_paid'] ?? false,
      price: data['price'] != null ? (data['price'] as num).toDouble() : null,
    );
  }

  /// Convert to a map for Supabase insert/update
  Map<String, dynamic> toSupabase() {
    final map = {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'organizer_email': organizerEmail,
      'organizer_phone': organizerPhone,
      'image_url': imageUrl,
      'category': category,
      'created_by': createdBy,
      'status': status,
      'is_paid': isPaid,
    };

    // Only include price if the event is paid
    if (isPaid && price != null) {
      map['price'] = price!;
    }

    return map;
  }

  /// Create a copy of this EventModel with modified fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? organizer,
    String? organizerEmail,
    String? organizerPhone,
    String? imageUrl,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    String? status,
    bool? isRegistered,
    bool? isPaid,
    double? price,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      organizerPhone: organizerPhone ?? this.organizerPhone,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isRegistered: isRegistered ?? this.isRegistered,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    location,
    organizer,
    organizerEmail,
    organizerPhone,
    imageUrl,
    category,
    createdBy,
    createdAt,
    status,
    isRegistered,
    isPaid,
    price,
  ];
}
