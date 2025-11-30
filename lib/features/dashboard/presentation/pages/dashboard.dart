import 'package:coexist_app_portal/core/utils/app_router.dart';
import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coexist_app_portal/features/auth/presentation/bloc/auth_event.dart';
import 'package:coexist_app_portal/features/dashboard/presentation/widgets/events_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection_container.dart' as di;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/dashboard_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _displayName;
  bool _loading = true;
  String _selectedMenu = 'Dashboard';
  Map<String, int> _stats = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final AuthRepository authRepo = di.sl<AuthRepository>();
      final user = await authRepo.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _displayName = user?.name ?? 'User';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _displayName = 'User';
        _loading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _statsLoading = true;
    });

    try {
      // Use Supabase client from DI to fetch live counts.
      final SupabaseClient client = di.sl<SupabaseClient>();

      // Run queries in parallel
      final results = await Future.wait([
        client.from('users').select(),
        client.from('events').select(),
        client.from('communities').select(),
        client.from('waste_pickups').select().eq('status', 'Completed'),
        client.from('tree_planting_orders').select('tree_count'),
        client.from('event_registrations').select(),
      ]);

      final usersList = results[0] as List? ?? [];
      final eventsList = results[1] as List? ?? [];
      final communitiesList = results[2] as List? ?? [];
      final pickupsCompletedList = results[3] as List? ?? [];
      final treeOrdersList = results[4] as List? ?? [];
      final registrationsList = results[5] as List? ?? [];

      // Sum tree_count from orders
      int treesPlanted = 0;
      for (final item in treeOrdersList) {
        try {
          final tc = item['tree_count'];
          if (tc is int) treesPlanted += tc;
          if (tc is String) treesPlanted += int.tryParse(tc) ?? 0;
          if (tc is double) treesPlanted += tc.toInt();
        } catch (_) {}
      }

      final totalEvents = eventsList.length;
      final totalRegistrations = registrationsList.length;
      final eventsPerVolunteer = totalEvents == 0
          ? 0
          : (totalRegistrations / totalEvents).round();

      final data = <String, int>{
        'Total Users': usersList.length,
        'Trees Planted': treesPlanted,
        'Pickups Completed': pickupsCompletedList.length,
        'Total Events': totalEvents,
        'Communities': communitiesList.length,
        'Events / Volunteer': eventsPerVolunteer,
      };

      if (!mounted) return;
      setState(() {
        _stats = data;
        _statsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stats = {};
        _statsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (_loading) {
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              );
            }

            // Wide layout: sidebar + content
            if (isWide) {
              return Row(
                children: [
                  // Sidebar
                  Container(
                    width: 260,
                    color: Colors.white,
                    child: _buildSidebar(
                      context,
                      isWide: isWide,
                      width: constraints.maxWidth,
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: _buildContent(
                        context,
                        isWide,
                        constraints.maxWidth,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Narrow layout: drawer + content stacked
            return Scaffold(
              backgroundColor: Colors.grey[50],
              drawer: Drawer(
                child: _buildSidebar(
                  context,
                  isWide: isWide,
                  width: constraints.maxWidth,
                  isInDrawer: true,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildContent(context, isWide, constraints.maxWidth),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load stats once dependencies are ready
    if (_statsLoading) {
      _loadStats();
    }
  }

  Widget _buildSidebar(
    BuildContext context, {
    bool isInDrawer = false,
    bool isWide = false,
    double width = 0,
  }) {
    // compute responsive sizes for sidebar based on width
    final t = ((width - 360) / (1200 - 360)).clamp(0.0, 1.0);
    final sidebarSmall = 12.0 + (16.0 - 12.0) * t; // 12..16
    final navLabelSize = 14.0 + (18.0 - 14.0) * t; // 14..18

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              // width: 40,
              height: 35,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Image.asset('assets/images/coexist-logo.png'),
            ),
            const SizedBox(height: 16),

            Text(
              'MENU',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutralDarkerGrey,
                fontSize: sidebarSmall,
              ),
            ),
            const SizedBox(height: 12),

            // Menu items
            _navItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              onTap: () => _onMenuTap('Dashboard', isInDrawer),
              selected: _selectedMenu == 'Dashboard',
              fontSize: navLabelSize,
            ),
            _navItem(
              icon: Icons.event,
              label: 'Events',
              onTap: () => _onMenuTap('Events', isInDrawer),
              selected: _selectedMenu == 'Events',
              fontSize: navLabelSize,
            ),

            // _navItem(icon: Icons.flash_on, label: 'Energy', onTap: () {}),
            // _navItem(icon: Icons.opacity, label: 'Water', onTap: () {}),
            // _navItem(icon: Icons.flag, label: 'Goals', onTap: () {}),
            // _navItem(icon: Icons.description, label: 'Reports', onTap: () {}),
            // _navItem(icon: Icons.bar_chart, label: 'Analytics', onTap: () {}),
            // _navItem(icon: Icons.people, label: 'Team', onTap: () {}),
            Spacer(),
            Text(
              'General',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutralDarkerGrey,
                fontSize: sidebarSmall,
              ),
            ),
            const SizedBox(height: 10),
            // _navItem(
            //   icon: Icons.settings,
            //   label: 'Settings',
            //   onTap: () => _onMenuTap('Settings', isInDrawer),
            //   fontSize: navLabelSize,
            // ),
            _navItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => _onMenuTap('Logout', isInDrawer),
              fontSize: navLabelSize,
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuTap(String label, bool isInDrawer) {
    setState(() {
      _selectedMenu = label;
    });
    if (isInDrawer) {
      // close the drawer
      Navigator.of(context).pop();
    }
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    String? badge,
    bool selected = false,
    required VoidCallback onTap,
    double? fontSize,
    double? badgeFontSize,
  }) {
    final bg = selected ? AppColors.primaryGreen : Colors.transparent;
    final textColor = selected ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.primaryDarkGreen,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white24
                        : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontSize: badgeFontSize,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isWide, double width) {
    final name = _displayName ?? 'User';
    // responsive font sizes based on width
    final t = ((width - 360) / (1200 - 360)).clamp(0.0, 1.0);
    final headingSize = 22.0 + (32.0 - 22.0) * t; // 22..32
    final subHeadingSize = 14.0 + (16.0 - 14.0) * t; // 14..16
    // build statistics section

    if (_selectedMenu == 'Events') {
      return EventsSection(
        isWide: isWide,
        name: name,
        headingSize: headingSize,
        subHeadingSize: subHeadingSize,
      );
    }
    if (_selectedMenu == 'Dashboard') {
      return DashboardSection(
        isWide: isWide,
        name: name,
        headingSize: headingSize,
        subHeadingSize: subHeadingSize,
        stats: _stats,
        onMenuTap: _onMenuTap,
      );
    }
    if (_selectedMenu == 'Logout') {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout, $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: Text('Logout'),
          ),
        ],
      );
    }
    // Default: show selected menu label centered
    return Center(
      child: Text(
        _selectedMenu,
        style: AppTextStyles.h1.copyWith(color: AppColors.primaryDarkGreen),
        textAlign: TextAlign.center,
      ),
    );
  }
}
