import 'package:equatable/equatable.dart';

import 'event_event.dart';

class FetchEventRegistrationsEvent extends EventEvent {
  final String eventId;

  const FetchEventRegistrationsEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
