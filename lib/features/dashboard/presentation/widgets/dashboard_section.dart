import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class DashboardSection extends StatelessWidget {
  final bool isWide;
  final String name;
  final double headingSize;
  final double subHeadingSize;
  final bool statsLoading = false; // Placeholder for loading state
  final Map<String, int> stats;
  final void Function(String, bool) onMenuTap;
  const DashboardSection({
    super.key,
    required this.isWide,
    required this.name,
    required this.headingSize,
    required this.subHeadingSize,
    required this.stats,
    required this.onMenuTap,
  });

  Widget _statCard(String title, int? value, IconData icon, Color color) {
    final display = value == null ? '--' : value.toString();
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutralDarkerGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    display,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
            // IconButton(
            //   onPressed: () {
            //     // Quick action: when pressing on a stat, navigate to the related section
            //     if (title.toLowerCase().contains('event')) {
            //       onMenuTap('Events', false);
            //     } else if (title.toLowerCase().contains('user')) {
            //       onMenuTap('Dashboard', false);
            //     }
            //   },
            //   icon: const Icon(Icons.arrow_forward_ios, size: 16),
            // ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStat(String key) {
    if (key.toLowerCase().contains('user')) return Icons.people;
    if (key.toLowerCase().contains('tree')) return Icons.nature;
    if (key.toLowerCase().contains('pickup')) return Icons.shopping_bag;
    if (key.toLowerCase().contains('event')) return Icons.event;
    if (key.toLowerCase().contains('community')) return Icons.location_city;
    return Icons.insights;
  }

  Color _colorForStat(String key) {
    if (key.toLowerCase().contains('user')) return Colors.indigo;
    if (key.toLowerCase().contains('tree')) return Colors.green;
    if (key.toLowerCase().contains('pickup')) return Colors.orange;
    if (key.toLowerCase().contains('event')) return Colors.teal;
    if (key.toLowerCase().contains('community')) return Colors.purple;
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    Widget statsSection;
    if (statsLoading) {
      statsSection = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 24,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      final keys = [
        'Total Users',
        'Trees Planted',
        'Pickups Completed',
        'Total Events',
        'Communities',
        'Events / Volunteer',
      ];
      final cards = keys
          .map((k) => _statCard(k, stats[k], _iconForStat(k), _colorForStat(k)))
          .toList(growable: false);

      if (isWide) {
        statsSection = Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((c) => SizedBox(width: 260, child: c)).toList(),
        );
      } else {
        statsSection = GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.4,
          children: cards,
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primaryDarkGreen,
            fontSize: headingSize,
          ),
        ),
        Text(
          'Welcome to the COExist Portal Admin Dashboard.',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 36),
        // Stats
        //
        Text(
          'Statistics',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(height: 18),
        statsSection,
        const SizedBox(height: 18),
      ],
    );
  }
}
