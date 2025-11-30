import 'package:coexist_app_portal/core/common_widgets/app_button.dart';
import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/core/utils/date_formatter.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_bloc.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_event.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_image_header.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_info_row.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/event_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDetailsInfo extends StatelessWidget {
  final EventModel? event;
  const EventDetailsInfo({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventImageHeader(event: event!),
        const SizedBox(height: 16),
        Text(event!.title, style: AppTextStyles.h1),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: EventInfoRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormatter.formatDate(event!.date),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EventInfoRow(
                icon: Icons.access_time,
                label: 'Time',
                value: DateFormatter.formatTime(event!.date),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EventInfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value: event!.location,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: EventInfoRow(
                icon: Icons.person,
                label: 'Organizer',
                value: event!.organizer,
              ),
            ),
            if (event!.organizerEmail.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: EventInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: event!.organizerEmail,
                ),
              ),
            ],
            if (event!.organizerPhone.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: EventInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: event!.organizerPhone,
                ),
              ),
            ],
            const SizedBox(width: 8),
            if (event!.isPaid && event!.price != null)
              Expanded(
                child: EventInfoRow(
                  icon: Icons.payment,
                  label: 'Price',
                  value: '₹ ${event!.price!.toStringAsFixed(2)}',
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),
        Text('About this event', style: AppTextStyles.h3),
        const SizedBox(height: 8),
        Text(event!.description, style: AppTextStyles.bodyMedium),
        SizedBox(height: 100),
        if (isEventAdmin(context, event!)) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (event!.status != 'Approved')
                Expanded(
                  child: SizedBox(
                    width: 350,
                    height: 40,
                    child: AppButton(
                      text: 'Approve',
                      onPressed: () {
                        context.read<EventBloc>().add(
                          ApproveEvent(event: event!),
                        );
                      },
                      type: ButtonType.secondary,
                      size: ButtonSize.small,
                      icon: Icons.warning_amber_outlined,
                    ),
                  ),
                ),
              if (event!.status != 'Approved') const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  width: 350,
                  height: 40,
                  child: AppButton(
                    text: 'Edit Event',
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.editEvent, arguments: event!.id);
                    },
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                    icon: Icons.edit_outlined,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
