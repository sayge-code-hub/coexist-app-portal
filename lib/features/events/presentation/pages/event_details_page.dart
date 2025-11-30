import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_detail_info.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_utils.dart';
import 'package:flutter/material.dart';
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
      } catch (e) {
        // Event not found in current state, refresh events
        context.read<EventBloc>().add(const FetchEventsEvent());
      }
    } else {
      // If events aren't loaded yet, fetch them
      context.read<EventBloc>().add(const FetchEventsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = isEventAdmin(context, _event);
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventsLoaded) {
          try {
            _event = state.events.firstWhere((e) => e.id == widget.eventId);
            setState(() {
              _isLoading = false;
            });
          } catch (e) {
            // Event not found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event not found'),
                backgroundColor: AppColors.error,
              ),
            );
            Navigator.of(context).pushNamed(AppRoutes.events);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
          actions: [
            if (isAdmin)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAmber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
                    child: EventDetailsInfo(event: _event),
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
