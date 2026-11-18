import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/app_config.dart';
import 'package:al_mahhaba_school/config/routes/app_route_observer.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/routes/home_on_back.dart';
import 'package:al_mahhaba_school/core/analytics/public_content.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/pages/attendance_page.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/add_children_page.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/child_details_page.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/change_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/new_password_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/otp_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/register_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/reset_code_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_images_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/chat_pdf_args.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_image_viewer_page.dart';
import 'package:al_mahhaba_school/features/chat/presentation/pages/chat_pdf_viewer_page.dart';
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
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_args.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/pages/announcement_page.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/pages/announcements_page.dart';
import 'package:al_mahhaba_school/features/home/presentation/pages/home_page.dart';
import 'package:al_mahhaba_school/features/homework/presentation/pages/homework_page.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/profile_page.dart';
import 'package:al_mahhaba_school/features/profile/presentation/pages/settings_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/certificate_preview_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/pdf/certificate_pdf_file.dart';
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
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/link_child_code_page.dart';
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
  AppRoutes.linkChildCode,
  AppRoutes.home,
  AppRoutes.chat,
  AppRoutes.results,
  AppRoutes.attendance,
  AppRoutes.homework,
  AppRoutes.announcements,
  AppRoutes.announcementDetails,
  AppRoutes.fees,
  AppRoutes.feesPay,
  AppRoutes.feesCheckout,
  AppRoutes.feeStatementPreview,
  AppRoutes.certificatePreview,
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
      // The school's own pages: shown as they are in session recordings.
      builder: (context, state) => const PublicContent(child: SplashPage()),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const PublicContent(child: OnboardingPage()),
    ),
    GoRoute(
      path: AppRoutes.explore,
      builder: (context, state) => const PublicContent(child: ExplorePage()),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const PublicContent(child: AboutPage()),
    ),
    GoRoute(
      path: AppRoutes.news,
      builder: (context, state) => const PublicContent(child: NewsPage()),
    ),
    GoRoute(
      path: AppRoutes.newsArticle,
      builder: (context, state) => PublicContent(
        child: NewsArticlePage(
          slug: state.pathParameters['slug']!,
          // Passed from the news list; missing when opened from a link.
          preview: switch (state.extra) {
            final NewsEntity news => news,
            _ => null,
          },
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.contact,
      builder: (context, state) => const PublicContent(child: ContactPage()),
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
      redirect: (context, state) => state.extra is (String, PhoneProofEntity)
          ? null
          : AppRoutes.forgotPassword,
      builder: (context, state) {
        final (phone, proof) = state.extra! as (String, PhoneProofEntity);
        return NewPasswordPage(phone: phone, proof: proof);
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
    _parentPage(
      path: AppRoutes.addChildren,
      builder: (context, state) => const AddChildrenPage(),
    ),
    GoRoute(
      path: AppRoutes.linkChildCode,
      // Needs the check linking started; opened any other way, start there.
      // Back goes to Add children, not Home.
      redirect: (context, state) =>
          state.extra is LinkVerificationEntity ? null : AppRoutes.addChildren,
      builder: (context, state) => LinkChildCodePage(
        verification: state.extra! as LinkVerificationEntity,
      ),
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
    _parentPage(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: AppRoutes.chatImages,
      // Needs the photos the chat saved; opened any other way, go there.
      redirect: (context, state) => switch (state.extra) {
        ChatImagesArgs(:final images) when images.isNotEmpty => null,
        _ => AppRoutes.chat,
      },
      // Fades in over the chat as the photo flies to full screen.
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ChatImageViewerPage(args: state.extra! as ChatImagesArgs),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: AppRoutes.chatPdf,
      // Needs the file the chat saved; opened any other way, go there.
      redirect: (context, state) =>
          state.extra is ChatPdfArgs ? null : AppRoutes.chat,
      // Fades in, like a photo.
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ChatPdfViewerPage(args: state.extra! as ChatPdfArgs),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    _parentPage(
      path: AppRoutes.homework,
      builder: (context, state) => HomeworkPage(
        // The child the chat showed; the first child opened any other way.
        studentId: switch (state.extra) {
          final int studentId => studentId,
          _ => null,
        },
      ),
    ),
    _parentPage(
      path: AppRoutes.announcements,
      builder: (context, state) => AnnouncementsPage(
        // The child Home showed; the one every page shows any other way.
        studentId: switch (state.extra) {
          final int studentId => studentId,
          _ => null,
        },
      ),
    ),
    // Not `_parentPage`: one announcement opens over what the parent was
    // reading — Home or the chat — so back leaves them where they were.
    GoRoute(
      path: AppRoutes.announcementDetails,
      // Needs the announcement that was tapped; opened any other way (a
      // notification carrying only its id), the list opens instead.
      redirect: (context, state) =>
          state.extra is AnnouncementArgs ? null : AppRoutes.announcements,
      builder: (context, state) =>
          AnnouncementPage(args: state.extra! as AnnouncementArgs),
    ),
    // Not `_parentPage`: paying is a step on from the statement, not a
    // page of its own, so back goes back to Fees where the parent was.
    GoRoute(
      path: AppRoutes.feesPay,
      // Needs the statement Fees showed; opened any other way, start there.
      redirect: (context, state) =>
          state.extra is FeeStatementEntity ? null : AppRoutes.fees,
      builder: (context, state) =>
          PayFeesPage(statement: state.extra! as FeeStatementEntity),
    ),
    // The same: back goes to what is being paid, not Home.
    GoRoute(
      path: AppRoutes.feesCheckout,
      // Needs the payment Pay fees started; opened any other way, go to
      // Fees.
      redirect: (context, state) =>
          state.extra is CheckoutEntity ? null : AppRoutes.fees,
      builder: (context, state) =>
          CheckoutPage(checkout: state.extra! as CheckoutEntity),
    ),
    // Not `_parentPage`: a preview is something opened over the page that
    // made it, like the chat's photos, so back closes it and leaves that
    // page where it was.
    GoRoute(
      path: AppRoutes.feeStatementPreview,
      // Needs the PDF Fees made; opened any other way, go to Fees.
      redirect: (context, state) =>
          state.extra is FeeStatementPdfFile ? null : AppRoutes.fees,
      builder: (context, state) =>
          FeeStatementPreviewPage(file: state.extra! as FeeStatementPdfFile),
    ),
    GoRoute(
      path: AppRoutes.certificatePreview,
      // Needs the PDF Results made; opened any other way, go there.
      redirect: (context, state) =>
          state.extra is CertificatePdfFile ? null : AppRoutes.results,
      builder: (context, state) =>
          CertificatePreviewPage(file: state.extra! as CertificatePdfFile),
    ),
    _parentPage(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    _parentPage(
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
    _parentPage(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordPage(),
    ),
    _parentPage(
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
    _parentPage(
      path: AppRoutes.complaints,
      builder: (context, state) => const ComplaintsPage(),
    ),
    // Before the details, which would take "new" for an id.
    _parentPage(
      path: AppRoutes.newComplaint,
      builder: (context, state) => const NewComplaintPage(),
    ),
    _parentPage(
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
    _parentPage(
      path: AppRoutes.newExcuse,
      // Needs the absence Attendance picked; opened any other way, go there.
      redirect: (context, state) =>
          state.extra is NewExcuseArgs ? null : AppRoutes.attendance,
      builder: (context, state) =>
          NewExcusePage(args: state.extra! as NewExcuseArgs),
    ),
    _parentPage(
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

/// A page the parent opens over the tabs. Back from it goes Home, not
/// through every page they opened on the way there ([HomeOnBack]).
GoRoute _parentPage({
  required String path,
  required Widget Function(BuildContext context, GoRouterState state) builder,
  GoRouterRedirect? redirect,
}) => GoRoute(
  path: path,
  redirect: redirect,
  builder: (context, state) => HomeOnBack(child: builder(context, state)),
);
