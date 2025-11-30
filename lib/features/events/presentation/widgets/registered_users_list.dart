import 'package:coexist_app_portal/core/theme/app_colors.dart';
import 'package:coexist_app_portal/features/events/domain/models/registered_user_model.dart';
import 'package:flutter/material.dart';

/// Widget to display the list of users registered for an event
class RegisteredUsersList extends StatelessWidget {
  final List<RegisteredUserModel> registeredUsers;

  const RegisteredUsersList({super.key, required this.registeredUsers});

  @override
  Widget build(BuildContext context) {
    if (registeredUsers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No users registered for this event yet.',
            style: TextStyle(
              color: AppColors.neutralTextGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.people, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Registered Users (${registeredUsers.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: registeredUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final registeredUser = registeredUsers[index];
              return _RegisteredUserTile(registeredUser: registeredUser);
            },
          ),
        ],
      ),
    );
  }
}

/// Widget for a single registered user tile
class _RegisteredUserTile extends StatelessWidget {
  final RegisteredUserModel registeredUser;

  const _RegisteredUserTile({required this.registeredUser});

  @override
  Widget build(BuildContext context) {
    final user = registeredUser.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            child: user != null
                ? Text(
                    user.name?.isNotEmpty == true
                        ? user.name![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Unknown User',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? registeredUser.userId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutralTextGrey,
                  ),
                ),
                if (user?.mobileNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user!.mobileNumber!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutralTextGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Registration date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Registered',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutralTextGrey,
                ),
              ),
              Text(
                _formatDate(registeredUser.registeredAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutralTextGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
