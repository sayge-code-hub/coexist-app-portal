import 'package:equatable/equatable.dart';

/// Model representing an event registration
class EventRegistrationModel extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registeredAt;

  const EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
  });

  /// Create an EventRegistrationModel from Supabase data
  factory EventRegistrationModel.fromSupabase(Map<String, dynamic> data) {
    return EventRegistrationModel(
      id: data['id'] ?? '',
      eventId: data['event_id'] ?? '',
      userId: data['user_id'] ?? '',
      registeredAt: data['registered_at'] != null
          ? DateTime.parse(data['registered_at'])
          : DateTime.now(),
    );
  }

  /// Convert to a map for Supabase insert/update
  Map<String, dynamic> toSupabase() {
    return {
      'event_id': eventId,
      'user_id': userId,
    };
  }

  @override
  List<Object?> get props => [id, eventId, userId, registeredAt];
}
