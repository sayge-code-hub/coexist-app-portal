import 'package:coexist_app_portal/core/common_widgets/app_button.dart';
import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/core/utils/date_formatter.dart';
import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_state.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_bloc.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_event.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsSection extends StatelessWidget {
  final bool isWide;
  final String name; // Placeholder for admin name
  final double headingSize;
  final double subHeadingSize;
  const EventsSection({
    super.key,
    required this.isWide,
    required this.name,
    required this.headingSize,
    required this.subHeadingSize,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleanup':
        return Icons.cleaning_services;
      case 'Plantation':
        return Icons.park;
      case 'Workshop':
        return Icons.school;
      case 'Education':
        return Icons.menu_book;
      default:
        return Icons.event;
    }
  }

  Widget _eventCard(EventModel event, BuildContext context, bool isAdmin) {
    return InkWell(
      onTap: () {
        // Navigate to event details page when card is tapped
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.eventDetails, arguments: event.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        clipBehavior: Clip.antiAlias, // Ensures the image doesn't overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image with overlay gradient and category badge
            Stack(
              children: [
                // Image or placeholder
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: event.imageUrl.isNotEmpty
                      ? Image.network(
                          event.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primaryGreen,
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(event.category),
                                  size: 64,
                                  color: AppColors.neutralWhite,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.primaryGreen,
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(event.category),
                              size: 64,
                              color: AppColors.neutralWhite,
                            ),
                          ),
                        ),
                ),

                // Gradient overlay for better text visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Banner toggle (admin only)
                if (isAdmin)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Banner',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch.adaptive(
                            key: ValueKey('banner_switch_${event.id}'),
                            value: event.isBanner,
                            inactiveThumbColor: Colors.black54,
                            activeThumbColor: AppColors.primaryGreen,
                            activeTrackColor: AppColors.neutralWhite,
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  Set<WidgetState> states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppColors.primaryGreen;
                                  }
                                  return null; // Use the default color.
                                }),
                            thumbColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primaryGreen;
                                }
                                return null; // Use the default color.
                              },
                            ),
                            onChanged: event.isBanner
                                ? null
                                : (value) async {
                                    // Only proceed when switching ON
                                    if (!value) return;

                                    // Check if widget is still mounted before showing dialog
                                    if (!context.mounted) return;

                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: const Text('Set as banner?'),
                                          content: const Text(
                                            'Are you sure you want to set this event as the banner?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(true);
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // Check if widget is still mounted after dialog closes
                                    if (!context.mounted) return;

                                    if (confirmed == true) {
                                      context.read<EventBloc>().add(
                                        SetEventBannerStatusEvent(
                                          eventId: event.id,
                                          isBanner: true,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Price badge (if paid event)
                if (event.isPaid && event.price != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₹ ${event.price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Event title at the bottom of the image
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    event.title,
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    event.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralDarkerGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Info row with icons
                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.neutralDarkerGrey,
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatDate(event.date),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.neutralDarkerGrey,
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatTime(event.date),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.neutralDarkerGrey,
                                    ),
                                  ),
                                  Text(
                                    event.location,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isAdmin && event.status != 'Approved')
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: AppButton(
                            text: 'Approve',
                            onPressed: () {
                              context.read<EventBloc>().add(
                                ApproveEvent(event: event),
                              );
                            },
                            type: ButtonType.secondary,
                            size: ButtonSize.small,
                            icon: Icons.warning_amber_outlined,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<EventBloc>().add(FetchEventsEvent());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 150,
            height: 40,
            child: AppButton(
              text: 'Add Event',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.createEvent);
              },
              type: ButtonType.secondary,

              icon: Icons.add,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: BlocConsumer<EventBloc, EventState>(
                listener: (context, state) {
                  if (state is EventApproveError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } else if (state is EventUpdated) {
                    // Refresh events to reflect banner changes
                    context.read<EventBloc>().add(const FetchEventsEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event updated successfully.'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is EventsLoaded) {
                    final events = state.events;
                    // Wrap the events area in Flexible so it can scroll or size properly
                    return BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final bool isAdmin =
                            authState is Authenticated &&
                            authState.userProfile?.role == 'admin';
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(state.events.length, (index) {
                            final event = events[index];
                            return SizedBox(
                              width: 350,
                              child: _eventCard(event, context, isAdmin),
                            );
                          }),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.3,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
