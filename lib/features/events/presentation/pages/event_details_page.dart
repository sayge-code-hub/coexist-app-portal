import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:coexist_app_portal/features/events/domain/models/registered_user_model.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_detail_info.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/registered_users_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';

/// Page for displaying detailed information about an event (delegates to widgets EventDetailsView)
class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventModel? _event;
  bool _isLoading = true;
  List<RegisteredUserModel> _registeredUsers = [];
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  void _loadEventDetails() {
    final state = context.read<EventBloc>().state;
    if (state is EventsLoaded) {
      try {
        _event = state.events.firstWhere((e) => e.id == widget.eventId);
        setState(() {
          _isLoading = false;
        });
        // Load registered users after event is loaded
        _loadRegisteredUsers();
      } catch (e) {
        // Event not found in current state, refresh events
        context.read<EventBloc>().add(const FetchEventsEvent());
      }
    } else {
      // If events aren't loaded yet, fetch them
      context.read<EventBloc>().add(const FetchEventsEvent());
    }
  }

  void _loadRegisteredUsers() {
    if (_event != null) {
      context.read<EventBloc>().add(
        FetchRegisteredUsersEvent(eventId: _event!.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventsLoaded) {
          try {
            _event = state.events.firstWhere((e) => e.id == widget.eventId);
            setState(() {
              _isLoading = false;
            });
            // Load registered users after event is found
            _loadRegisteredUsers();
          } catch (e) {
            // Event not found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event not found'),
                backgroundColor: AppColors.error,
              ),
            );
            context.go(AppRoutes.dashboard);
          }
        } else if (state is RegisteredUsersLoaded) {
          if (state.eventId == widget.eventId) {
            setState(() {
              _registeredUsers = state.registeredUsers;
              _isLoadingUsers = false;
            });
          }
        } else if (state is EventError) {
          setState(() {
            _isLoadingUsers = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: _isLoading || _event == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EventDetailsInfo(event: _event),
                        RegisteredUsersList(registeredUsers: _registeredUsers),
                        if (_isLoadingUsers)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
        // bottomNavigationBar: _isLoading || _event == null
        //     ? null
        //     : isEventAdmin(context, _event)
        //     ? null
        //     : EventBottomAction(
        //         event: _event!,
        //         onPressed: () => toggleRegistration(context, _event),
        //       ),
      ),
    );
  }
}
