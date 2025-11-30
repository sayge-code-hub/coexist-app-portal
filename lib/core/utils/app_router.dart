import 'package:coexist_app_portal/di/injection_container.dart' as di;
import 'package:coexist_app_portal/features/auth/presentation/pages/register_page.dart';
import 'package:coexist_app_portal/features/events/presentation/bloc/event_bloc.dart';
import 'package:coexist_app_portal/features/events/presentation/pages/event_details_page.dart';
import 'package:coexist_app_portal/features/events/presentation/widgets/web_form_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/dashboard/presentation/pages/dashboard.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/set_new_password_page.dart';

enum PageAnimationType { leftToRight, rightToLeft, fade, bottomToTop }

class AppRoutes {
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String forgotPassword = '/forgot-password';
  static const String setNewPassword = '/set-new-password';
  static const String events = '/events';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event';
  static const String eventDetails = '/event-details';
  static const String wastePickup = '/waste-pickup';
  static const String editPickup = '/edit-pickup';
  static const String plantTrees = '/plant-trees';
  static const String goHerbal = '/go-herbal';
  static const String avatarSelection = '/avatar-selection';
  static const String carbonFootprintDetails = '/carbon-footprint-details';
  static const String carbonFootprintCalculator =
      '/carbon-footprint-calculator';
  static const String carbonFootprintPieChart = '/carbon-footprint-pie-chart';
  static const String carbonFootprintResult = '/carbon-footprint-result';
  static const String carbonFootprintHistory = '/carbon-footprint-history';
  static const String ecoBlogs = '/eco-blogs';
  static const String ecoBlogDetail = '/eco-blog-detail';
  static const String challenges = '/challenges';
  static const String communityCreatedSuccessScreen =
      '/community-created-success';
  static const String communityDetail = '/community-detail';
  static const String createCommunity = '/create-community';
  static const String rewards = '/rewards';
  static const String rootScreen = '/root-screen';
  static const String challengeDetail = '/challenge-detail';
  static const String pickupSuccess = '/pickup-success';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String profileTwo = '/profile-two';
  static const String pickupHistory = '/pickup-history';
  static const String treesPlantedRecord = '/trees-planted-record';
  static const String noInternet = '/no-internet';
  static const String welcomePage = '/welcome-page';
  static const String treeOrderSuccessPage = '/tree-order-success-page';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    dashboard: (context) => const DashboardPage(),
    createEvent: (context) => const CreateEventForm(),
    editEvent: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      final eventId = args ?? '';
      return CreateEventForm(eventId: eventId);
    },
    forgotPassword: (context) => ForgotPasswordPage(),
    setNewPassword: (context) => const SetNewPasswordPage(),
    emailVerification: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      final email = args ?? '';
      return EmailVerificationPage(email: email);

      // Add other routes here as needed
    },
    register: (context) => const RegisterPage(),
    eventDetails: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      final eventId = args ?? '';
      return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => di.sl<EventBloc>())],
        child: EventDetailsPage(eventId: eventId),
      );
    },
  };

  static PageRouteBuilder<dynamic> buildPageRoute(
    Widget page, {
    PageAnimationType animationType = PageAnimationType.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        switch (animationType) {
          case PageAnimationType.leftToRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageAnimationType.rightToLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageAnimationType.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          case PageAnimationType.fade:
            return FadeTransition(opacity: curvedAnimation, child: child);
        }
      },
    );
  }

  /// Navigate using buildPageRoute; supports arguments by attaching RouteSettings.
  static void navigateWithAnimation(
    BuildContext context,
    String routeName, {
    PageAnimationType animationType = PageAnimationType.rightToLeft,
    bool removeAll = false,
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final routeBuilder = AppRoutes.routes[routeName];

    if (routeBuilder == null) {
      debugPrint("Route not found: $routeName");
      return;
    }

    // Build the page widget using the current context (so route builders that
    // read ModalRoute.of(context) will still work).
    final page = routeBuilder(context);

    // Attach RouteSettings (name + arguments) so ModalRoute.of(context)!.settings.arguments
    // inside target pages will contain the passed arguments.
    final settings = RouteSettings(name: routeName, arguments: arguments);

    final route = buildPageRoute(
      page,
      animationType: animationType,
      duration: duration,
      settings: settings,
    );

    if (removeAll) {
      Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
    } else {
      Navigator.of(context).push(route);
    }
  }
}
