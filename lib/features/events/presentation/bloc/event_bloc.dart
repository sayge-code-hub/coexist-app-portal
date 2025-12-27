import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

/// BLoC for handling event operations
class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _eventRepository;
  final SupabaseClient supabaseClient;

  EventBloc({
    required EventRepository eventRepository,
    required this.supabaseClient,
  }) : _eventRepository = eventRepository,
       super(const EventInitial()) {
    on<FetchEventsEvent>(_onFetchEvents);
    on<FetchMyCreatedEventsEvent>(_onFetchMyCreatedEvents);
    on<FetchMyRegisteredEventsEvent>(_onFetchMyRegisteredEvents);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<RegisterForEventEvent>(_onRegisterForEvent);
    on<UnregisterFromEventEvent>(_onUnregisterFromEvent);
    on<CheckRegistrationEvent>(_onCheckRegistration);
    on<RefreshEventsEvent>(_onRefreshEvents);
    on<CheckEventPaidEvent>(_onCheckEventPaid);
    on<ApproveEvent>(_onApproveEvent);
    on<FetchRegisteredUsersEvent>(_onFetchRegisteredUsers);
    on<SetEventBannerStatusEvent>(_onSetEventBannerStatus);
  }

  Future<void> _onSetEventBannerStatus(
    SetEventBannerStatusEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Setting event banner status');
    emit(const EventLoading());
    try {
      final success = await _eventRepository.setEventBannerStatus(
        event.eventId,
        event.isBanner,
      );
      if (success) {
        print('✅ EVENT BLOC: Event banner status updated successfully');
        add(FetchEventsEvent());
      } else {
        print('❌ EVENT BLOC: Failed to update event banner status');
        emit(const EventError(message: 'Failed to update event banner status'));
      }
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(
          message: 'Failed to update event banner status: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onApproveEvent(
    ApproveEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Approving event');
    emit(const EventLoading());
    // try {
    final success = await _eventRepository.approveEvent(event.event);
    if (success) {
      print('✅ EVENT BLOC: Event approved successfully');
      add(FetchEventsEvent());
    } else {
      print('❌ EVENT BLOC: Failed to approve event');
      emit(const EventApproveError(message: 'Failed to approve event'));
    }
    // } catch (e) {
    //   print('❌ EVENT BLOC ERROR: ${e.toString()}');
    //   emit(
    //     EventApproveError(message: 'Failed to approve event: ${e.toString()}'),
    //   );
    // }
  }

  /// Handle fetching all events
  Future<void> _onFetchEvents(
    FetchEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Fetching all events');
    emit(const EventLoading());
    try {
      final events = await _eventRepository.getEvents();
      print('✅ EVENT BLOC: Fetched ${events.length} events');
      emit(EventsLoaded(events: events));
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to fetch events'));
    }
  }

  /// Handle fetching events created by the current user
  Future<void> _onFetchMyCreatedEvents(
    FetchMyCreatedEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Fetching my created events');
    emit(const EventLoading());
    try {
      final events = await _eventRepository.getMyCreatedEvents();
      print('✅ EVENT BLOC: Fetched ${events.length} created events');
      emit(MyCreatedEventsLoaded(events: events));
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to fetch your created events'));
    }
  }

  /// Handle fetching events the current user is registered for
  Future<void> _onFetchMyRegisteredEvents(
    FetchMyRegisteredEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Fetching my registered events');
    emit(const EventLoading());
    try {
      final events = await _eventRepository.getMyRegisteredEvents();
      print('✅ EVENT BLOC: Fetched ${events.length} registered events');
      emit(MyRegisteredEventsLoaded(events: events));
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to fetch your registered events'));
    }
  }

  /// Handle creating a new event
  Future<void> _onCreateEvent(
    CreateEventEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Creating new event');
    emit(const EventLoading());
    // try {
    final createdEvent = await _eventRepository.createEvent(
      event.event,
      event.imageData,
    );
    if (createdEvent != null) {
      print('✅ EVENT BLOC: Event created successfully');
      emit(EventCreated(event: createdEvent));

      // Refresh events list
      final events = await _eventRepository.getEvents();
      emit(EventsLoaded(events: events));
    } else {
      print('❌ EVENT BLOC: Failed to create event');
      emit(const EventError(message: 'Failed to create event'));
    }
    // } catch (e) {
    //   print('❌ EVENT BLOC ERROR: ${e.toString()}');
    //   emit(EventError(message: 'Failed to create event: ${e.toString()}'));
    // }
  }

  /// Handle updating an existing event
  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Updating event');
    emit(const EventLoading());
    try {
      final updatedEvent = await _eventRepository.updateEvent(
        event.event,
        event.imageData,
      );
      if (updatedEvent != null) {
        print('✅ EVENT BLOC: Event updated successfully');
        emit(EventUpdated(event: updatedEvent));

        // Refresh events list
        final events = await _eventRepository.getEvents();
        emit(EventsLoaded(events: events));
      } else {
        print('❌ EVENT BLOC: Failed to update event');
        emit(const EventError(message: 'Failed to update event'));
      }
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to update event: ${e.toString()}'));
    }
  }

  /// Handle deleting an event
  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Deleting event');
    emit(const EventLoading());
    try {
      final success = await _eventRepository.deleteEvent(event.eventId);
      if (success) {
        print('✅ EVENT BLOC: Event deleted successfully');
        emit(EventDeleted(eventId: event.eventId));

        // Refresh events list
        final events = await _eventRepository.getEvents();
        emit(EventsLoaded(events: events));
      } else {
        print('❌ EVENT BLOC: Failed to delete event');
        emit(const EventError(message: 'Failed to delete event'));
      }
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to delete event: ${e.toString()}'));
    }
  }

  /// Handle registering for an event
  Future<void> _onRegisterForEvent(
    RegisterForEventEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Registering for event');
    emit(const EventLoading());
    try {
      final success = await _eventRepository.registerForEvent(
        event.eventDetails,
      );
      if (success) {
        print('✅ EVENT BLOC: Registered for event successfully');
        emit(RegisteredForEvent(eventId: event.eventDetails.id));

        // Refresh events list
        final events = await _eventRepository.getEvents();
        emit(EventsLoaded(events: events));
      } else {
        print('❌ EVENT BLOC: Failed to register for event');
        emit(const EventError(message: 'Failed to register for event'));
      }
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(message: 'Failed to register for event: ${e.toString()}'),
      );
    }
  }

  /// Handle unregistering from an event
  Future<void> _onUnregisterFromEvent(
    UnregisterFromEventEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Unregistering from event');
    emit(const EventLoading());
    try {
      final success = await _eventRepository.unregisterFromEvent(event.eventId);
      if (success) {
        print('✅ EVENT BLOC: Unregistered from event successfully');
        emit(UnregisteredFromEvent(eventId: event.eventId));

        // Refresh events list
        final events = await _eventRepository.getEvents();
        emit(EventsLoaded(events: events));
      } else {
        print('❌ EVENT BLOC: Failed to unregister from event');
        emit(const EventError(message: 'Failed to unregister from event'));
      }
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(message: 'Failed to unregister from event: ${e.toString()}'),
      );
    }
  }

  /// Handle checking if user is registered for an event
  Future<void> _onCheckRegistration(
    CheckRegistrationEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Checking registration status');
    emit(const EventLoading());
    try {
      final isRegistered = await _eventRepository.isRegisteredForEvent(
        event.eventId,
      );
      print('✅ EVENT BLOC: Registration status checked');
      emit(
        RegistrationStatusChecked(
          eventId: event.eventId,
          isRegistered: isRegistered,
        ),
      );
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(
          message: 'Failed to check registration status: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle refreshing events
  Future<void> _onRefreshEvents(
    RefreshEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Refreshing events');
    try {
      final events = await _eventRepository.getEvents();
      print('✅ EVENT BLOC: Refreshed ${events.length} events');
      emit(EventsLoaded(events: events));
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(EventError(message: 'Failed to refresh events'));
    }
  }

  /// Handle checking if an event is paid
  Future<void> _onCheckEventPaid(
    CheckEventPaidEvent event,
    Emitter<EventState> emit,
  ) async {
    print('🔄 EVENT BLOC: Checking if event is paid');
    emit(const EventLoading());
    try {
      final isPaid = await _eventRepository.isEventPaid(event.eventId);
      print('✅ EVENT BLOC: Event paid status checked');
      emit(EventPaidStatusChecked(eventId: event.eventId, isPaid: isPaid));
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(
          message: 'Failed to check event paid status: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle fetching registered users for an event
  Future<void> _onFetchRegisteredUsers(
    FetchRegisteredUsersEvent event,
    Emitter<EventState> emit,
  ) async {
    print(
      '🔄 EVENT BLOC: Fetching registered users for event: ${event.eventId}',
    );
    emit(const EventLoading());
    try {
      final registeredUsers = await _eventRepository.getRegisteredUsersForEvent(
        event.eventId,
      );
      print('✅ EVENT BLOC: Fetched ${registeredUsers.length} registered users');
      emit(
        RegisteredUsersLoaded(
          eventId: event.eventId,
          registeredUsers: registeredUsers,
        ),
      );
    } catch (e) {
      print('❌ EVENT BLOC ERROR: ${e.toString()}');
      emit(
        EventError(
          message: 'Failed to fetch registered users: ${e.toString()}',
        ),
      );
    }
  }
}
