import 'dart:typed_data';

import '../models/event_model.dart';
import '../models/event_registration_model.dart';

/// Interface for event operations
abstract class EventRepository {
  /// Get all events
  Future<List<EventModel>> getEvents();

  /// Get events created by the current user
  Future<List<EventModel>> getMyCreatedEvents();

  /// Get events the current user is registered for
  Future<List<EventModel>> getMyRegisteredEvents();

  /// Create a new event
  Future<EventModel?> createEvent(EventModel event, Uint8List bytes);

  /// Update an existing event
  Future<EventModel?> updateEvent(EventModel event);

  /// Delete an event
  Future<bool> deleteEvent(String eventId);

  /// Register for an event
  Future<bool> registerForEvent(EventModel event);

  /// Unregister from an event
  Future<bool> unregisterFromEvent(String eventId);

  /// Check if user is registered for an event
  Future<bool> isRegisteredForEvent(String eventId);

  /// Get all registrations for an event
  Future<List<EventRegistrationModel>> getEventRegistrations(String eventId);

  /// Check if an event is paid
  Future<bool> isEventPaid(String eventId);

  Future<bool> approveEvent(EventModel event);
}
