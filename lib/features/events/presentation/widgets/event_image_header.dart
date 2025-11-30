import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/features/events/domain/models/event_model.dart';
import 'package:flutter/material.dart';

class EventImageHeader extends StatelessWidget {
  final EventModel event;

  const EventImageHeader({super.key, required this.event});

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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: event.imageUrl.isNotEmpty
          ? Image.network(
              event.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.primaryGreen,
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(event.category),
                      size: 80,
                      color: AppColors.neutralWhite,
                    ),
                  ),
                );
              },
            )
          : Container(
              height: 200,
              color: AppColors.primaryGreen,
              child: Center(
                child: Icon(
                  _getCategoryIcon(event.category),
                  size: 80,
                  color: AppColors.neutralWhite,
                ),
              ),
            ),
    );
  }
}
