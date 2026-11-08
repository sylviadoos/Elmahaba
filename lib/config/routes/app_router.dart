import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/routes/app_route_observer.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/pages/attendance_page.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/add_children_page.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/child_details_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/change_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/new_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/otp_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/register_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/reset_code_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_page.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/pages/complaint_details_page.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/pages/complaints_page.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/pages/new_complaint_page.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/checkout_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/fee_statement_preview_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/fees_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/pay_fees_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pdf/fee_statement_pdf_file.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/homework/presentation/pages/homework_page.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/profile_page.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/settings_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/shell/presentation/pages/parent_shell_page.dart';
import 'package:al_mahhaba_school/features/splash/presentation/pages/splash_page.dart';
import 'package:al_mahhaba_school/features/about/presentation/pages/about_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/pages/contact_message_page.dart';
import 'package:al_mahhaba_school/features/contact/presentation/pages/contact_page.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/excuse_args.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/pages/excuse_details_page.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/pages/new_excuse_page.dart';
import 'package:al_mahhaba_school/features/explore/presentation/pages/explore_page.dart';
import 'package:al_mahhaba_school/features/news/presentation/pages/news_article_page.dart';
import 'package:al_mahhaba_school/features/news/presentation/pages/news_page.dart';

/// Screens that need a parent account (log in and everything after it).
const Set<String> _parentRoutes = {
  AppRoutes.login,
  AppRoutes.forgotPassword,
  AppRoutes.resetCode,
  AppRoutes.newPassword,
  AppRoutes.register,
  AppRoutes.otp,
  AppRoutes.addChildren,
  AppRoutes.home,
  AppRoutes.chat,
  AppRoutes.results,
  AppRoutes.attendance,
  AppRoutes.homework,
  AppRoutes.fees,
  AppRoutes.feesPay,
  AppRoutes.feesCheckout,
  AppRoutes.feeStatementPreview,
  AppRoutes.settings,
  AppRoutes.profile,
  AppRoutes.changePassword,
  AppRoutes.childDetails,
  AppRoutes.complaints,
  AppRoutes.newComplaint,
  AppRoutes.complaintDetails,
  AppRoutes.newExcuse,
  AppRoutes.excuseDetails,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: AppConfig.enableLogging,
  observers: [appRouteObserver],
  redirect: (context, state) {
    final location = state.matchedLocation;
    // While the app is visitor-only, parent screens can't be opened. (The
    // route's pattern, for screens with an id in the path.)
    if (!AppConfig.parentAccountEnabled &&
        _parentRoutes.contains(state.fullPath ?? location)) {
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
      // After an account is made, `extra` is its mobile: Log in starts
      // empty, even when the one the parent typed in is still under it.
      builder: (context, state) => LoginPage(key: ValueKey(state.extra)),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetCode,
      // Needs the number typed on Forgot password; opened any other way,
      // start there.
      redirect: (context, state) =>
          state.extra is String ? null : AppRoutes.forgotPassword,
      builder: (context, state) => ResetCodePage(phone: state.extra! as String),
    ),
    GoRoute(
      path: AppRoutes.newPassword,
      // Needs the number and its proof from the code page; opened any other
      // way, start again.
      redirect: (context, state) =>
          state.extra is (String, String) ? null : AppRoutes.forgotPassword,
      builder: (context, state) {
        final (phone, firebaseIdToken) = state.extra! as (String, String);
        return NewPasswordPage(phone: phone, firebaseIdToken: firebaseIdToken);
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      // Needs the number Register checked; opened any other way, start there.
      redirect: (context, state) =>
          state.extra is PhoneEligible ? null : AppRoutes.register,
      builder: (context, state) {
        final eligible = state.extra! as PhoneEligible;
        return OtpPage(
          request: eligible.request,
          phoneMasked: eligible.eligibility.phoneMasked,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addChildren,
      builder: (context, state) => const AddChildrenPage(),
    ),
    // The tabs, under the nav bar; in `ParentShellPage.tabs`' order.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ParentShellPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.results,
              builder: (context, state) => const ResultsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.attendance,
              builder: (context, state) => const AttendancePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.fees,
              builder: (context, state) => const FeesPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: AppRoutes.homework,
      builder: (context, state) => HomeworkPage(
        // The child the chat showed; the first child opened any other way.
        studentId: switch (state.extra) {
          final int studentId => studentId,
          _ => null,
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.feesPay,
      // Needs the statement Fees showed; opened any other way, start there.
      redirect: (context, state) =>
          state.extra is FeeStatementEntity ? null : AppRoutes.fees,
      builder: (context, state) =>
          PayFeesPage(statement: state.extra! as FeeStatementEntity),
    ),
    GoRoute(
      path: AppRoutes.feesCheckout,
      // Needs the payment Pay fees started; opened any other way, go to
      // Fees.
      redirect: (context, state) =>
          state.extra is CheckoutEntity ? null : AppRoutes.fees,
      builder: (context, state) =>
          CheckoutPage(checkout: state.extra! as CheckoutEntity),
    ),
    GoRoute(
      path: AppRoutes.feeStatementPreview,
      // Needs the PDF Fees made; opened any other way, go to Fees.
      redirect: (context, state) =>
          state.extra is FeeStatementPdfFile ? null : AppRoutes.fees,
      builder: (context, state) =>
          FeeStatementPreviewPage(file: state.extra! as FeeStatementPdfFile),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => ProfilePage(
        // Passed from Settings, which loaded it; missing when opened from a
        // link.
        profile: switch (state.extra) {
          final ProfileEntity profile => profile,
          _ => null,
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.childDetails,
      builder: (context, state) => ChildDetailsPage(
        // A bad id is the server's "not found".
        childId: int.tryParse(state.pathParameters['id']!) ?? 0,
        // Passed from Profile; missing when opened from a link.
        preview: switch (state.extra) {
          final ChildEntity child => child,
          _ => null,
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.complaints,
      builder: (context, state) => const ComplaintsPage(),
    ),
    // Before the details, which would take "new" for an id.
    GoRoute(
      path: AppRoutes.newComplaint,
      builder: (context, state) => const NewComplaintPage(),
    ),
    GoRoute(
      path: AppRoutes.complaintDetails,
      builder: (context, state) => ComplaintDetailsPage(
        // A bad id is the server's "not found".
        complaintId: int.tryParse(state.pathParameters['id']!) ?? 0,
        // Passed from Complaints or New complaint; missing when opened from
        // a link.
        preview: switch (state.extra) {
          final ComplaintEntity complaint => complaint,
          _ => null,
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.newExcuse,
      // Needs the absence Attendance picked; opened any other way, go there.
      redirect: (context, state) =>
          state.extra is NewExcuseArgs ? null : AppRoutes.attendance,
      builder: (context, state) =>
          NewExcusePage(args: state.extra! as NewExcuseArgs),
    ),
    GoRoute(
      path: AppRoutes.excuseDetails,
      builder: (context, state) {
        // Passed from Attendance; missing when opened from a link.
        final args = switch (state.extra) {
          final ExcuseDetailsArgs args => args,
          _ => null,
        };
        return ExcuseDetailsPage(
          // A bad id is the server's "not found".
          childId: int.tryParse(state.pathParameters['childId']!) ?? 0,
          excuseId: int.tryParse(state.pathParameters['id']!) ?? 0,
          shown: args?.shown,
          rules: args?.rules,
        );
      },
    ),
  ],
);
