import 'package:equatable/equatable.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/event_registration_model.dart';
import '../../domain/models/registered_user_model.dart';

/// Base class for all event states
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EventInitial extends EventState {
  const EventInitial();
}

/// Loading state
class EventLoading extends EventState {
  const EventLoading();
}

/// State when events are loaded
class EventsLoaded extends EventState {
  final List<EventModel> events;

  const EventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

/// State when my created events are loaded
class MyCreatedEventsLoaded extends EventState {
  final List<EventModel> events;

  const MyCreatedEventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

/// State when my registered events are loaded
class MyRegisteredEventsLoaded extends EventState {
  final List<EventModel> events;

  const MyRegisteredEventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

/// State when an event is created
class EventCreated extends EventState {
  final EventModel event;

  const EventCreated({required this.event});

  @override
  List<Object?> get props => [event];
}

/// State when an event is updated
class EventUpdated extends EventState {
  final EventModel event;

  const EventUpdated({required this.event});

  @override
  List<Object?> get props => [event];
}

/// State when an event is deleted
class EventDeleted extends EventState {
  final String eventId;

  const EventDeleted({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// State when user is registered for an event
class RegisteredForEvent extends EventState {
  final String eventId;

  const RegisteredForEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// State when user is unregistered from an event
class UnregisteredFromEvent extends EventState {
  final String eventId;

  const UnregisteredFromEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// State when registration status is checked
class RegistrationStatusChecked extends EventState {
  final String eventId;
  final bool isRegistered;

  const RegistrationStatusChecked({
    required this.eventId,
    required this.isRegistered,
  });

  @override
  List<Object?> get props => [eventId, isRegistered];
}

/// State when event registrations are loaded
class EventRegistrationsLoaded extends EventState {
  final String eventId;
  final List<EventRegistrationModel> registrations;

  const EventRegistrationsLoaded({
    required this.eventId,
    required this.registrations,
  });

  @override
  List<Object?> get props => [eventId, registrations];
}

/// Error state
class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class EventApproveError extends EventState {
  final String message;

  const EventApproveError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when event paid status is checked
class EventPaidStatusChecked extends EventState {
  final String eventId;
  final bool isPaid;

  const EventPaidStatusChecked({required this.eventId, required this.isPaid});

  @override
  List<Object?> get props => [eventId, isPaid];
}

/// State when registered users for an event are loaded
class RegisteredUsersLoaded extends EventState {
  final String eventId;
  final List<RegisteredUserModel> registeredUsers;

  const RegisteredUsersLoaded({
    required this.eventId,
    required this.registeredUsers,
  });

  @override
  List<Object?> get props => [eventId, registeredUsers];
}
