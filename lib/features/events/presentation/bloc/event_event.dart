import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import '../../domain/models/event_model.dart';

/// Base class for all event events
abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch all events
class FetchEventsEvent extends EventEvent {
  const FetchEventsEvent();
}

/// Event to fetch events created by the current user
class FetchMyCreatedEventsEvent extends EventEvent {
  const FetchMyCreatedEventsEvent();
}

/// Event to fetch events the current user is registered for
class FetchMyRegisteredEventsEvent extends EventEvent {
  const FetchMyRegisteredEventsEvent();
}

/// Event to create a new event
class CreateEventEvent extends EventEvent {
  final EventModel event;
  final Uint8List imageData;

  const CreateEventEvent({required this.event, required this.imageData});

  @override
  List<Object?> get props => [event, imageData];
}

/// Event to update an existing event
class UpdateEventEvent extends EventEvent {
  final EventModel event;

  const UpdateEventEvent({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Event to delete an event
class DeleteEventEvent extends EventEvent {
  final String eventId;

  const DeleteEventEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Event to register for an event
class RegisterForEventEvent extends EventEvent {
  final EventModel eventDetails;

  const RegisterForEventEvent({required this.eventDetails});

  @override
  List<Object?> get props => [eventDetails];
}

/// Event to unregister from an event
class UnregisterFromEventEvent extends EventEvent {
  final String eventId;

  const UnregisterFromEventEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Event to check if user is registered for an event
class CheckRegistrationEvent extends EventEvent {
  final String eventId;

  const CheckRegistrationEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Event to refresh events
class RefreshEventsEvent extends EventEvent {
  const RefreshEventsEvent();
}

/// Event to check if an event is paid
class CheckEventPaidEvent extends EventEvent {
  final String eventId;

  const CheckEventPaidEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class ApproveEvent extends EventEvent {
  final EventModel event;

  const ApproveEvent({required this.event});

  @override
  List<Object?> get props => [event];
}
