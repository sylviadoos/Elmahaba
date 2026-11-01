import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/pages/attendance_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/add_children_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/otp_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/register_page.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/fees_page.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/notifications/presentation/pages/notifications_page.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/profile_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/splash/presentation/pages/splash_page.dart';
import 'package:al_mahhaba_school/features/about/presentation/pages/about_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/pages/contact_message_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/pages/contact_page.dart';
import 'package:al_mahhaba_school/features/explore/presentation/pages/explore_page.dart';
import 'package:al_mahhaba_school/features/news/presentation/pages/news_article_page.dart';
import 'package:al_mahhaba_school/features/news/presentation/pages/news_page.dart';

/// Screens that need a parent account (log in and everything after it).
const Set<String> _parentRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.otp,
  AppRoutes.addChildren,
  AppRoutes.home,
  AppRoutes.chat,
  AppRoutes.results,
  AppRoutes.attendance,
  AppRoutes.fees,
  AppRoutes.profile,
  AppRoutes.notifications,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: AppConfig.enableLogging,
  redirect: (context, state) {
    final location = state.matchedLocation;
    // While the app is visitor-only, parent screens can't be opened.
    if (!AppConfig.parentAccountEnabled && _parentRoutes.contains(location)) {
      return AppRoutes.explore;
    }
    // The contact form needs the API.
    if (AppConfig.useStaticData && location == AppRoutes.contactMessage) {
      return AppRoutes.contact;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.explore,
      builder: (context, state) => const ExplorePage(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: AppRoutes.news,
      builder: (context, state) => const NewsPage(),
    ),
    GoRoute(
      path: AppRoutes.newsArticle,
      builder: (context, state) => NewsArticlePage(
        slug: state.pathParameters['slug']!,
        // Passed from the news list; missing when opened from a link.
        preview: switch (state.extra) {
          final NewsEntity news => news,
          _ => null,
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.contact,
      builder: (context, state) => const ContactPage(),
    ),
    GoRoute(
      path: AppRoutes.contactMessage,
      builder: (context, state) => const ContactMessagePage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: AppRoutes.otp, builder: (context, state) => const OtpPage()),
    GoRoute(
      path: AppRoutes.addChildren,
      builder: (context, state) => const AddChildrenPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: AppRoutes.results,
      builder: (context, state) => const ResultsPage(),
    ),
    GoRoute(
      path: AppRoutes.attendance,
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(
      path: AppRoutes.fees,
      builder: (context, state) => const FeesPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
  ],
);
