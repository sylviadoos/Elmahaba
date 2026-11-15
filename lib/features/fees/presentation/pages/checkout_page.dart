import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/utils/external_links.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';

/// Skoolex Pay's payment page, inside the app. Closing it goes back to
/// Pay fees, which goes on to Fees.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.checkout});

  final CheckoutEntity checkout;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final WebViewController _controller;

  /// 0–100: how much of the page has loaded.
  int _progress = 0;

  /// The page itself didn't load (no connection…).
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => _update(() => _progress = progress),
          onPageStarted: (_) => _update(() => _failed = false),
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _update(() => _failed = true);
          },
          onNavigationRequest: _onNavigationRequest,
        ),
      );
    _load();
  }

  void _load() =>
      _controller.loadRequest(Uri.parse(widget.checkout.checkoutUrl));

  /// The web view calls back after the page has closed too.
  void _update(VoidCallback change) {
    if (mounted) setState(change);
  }

  /// Web pages open here; the rest (a wallet or bank app's link) open in
  /// their app.
  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (!request.isMainFrame ||
        uri == null ||
        const {'http', 'https', 'about', 'data'}.contains(uri.scheme)) {
      return NavigationDecision.navigate;
    }
    ExternalLinks.open(context, uri);
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 16,
              bottomPadding: 40,
              watermarkTop: 20,
              watermarkSize: const Size(200, 143),
              child: Row(
                spacing: 10.w,
                children: [
                  const AppBackButton(fallbackRoute: AppRoutes.fees),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payOnline,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24.sp,
                            height: 28 / 24,
                            letterSpacing: 0,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          context.egp(widget.checkout.total),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Stays in place on errors, to load again in.
                  Positioned.fill(
                    child: WebViewWidget(controller: _controller),
                  ),
                  if (_progress < 100 && !_failed)
                    LinearProgressIndicator(
                      value: _progress / 100,
                      minHeight: 3,
                      color: AppColors.mahabbahRed,
                      backgroundColor: Colors.transparent,
                    ),
                  if (_failed)
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.white,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: StateMessage(
                              icon: AppIcons.navFees,
                              title: l10n.paymentPageFailed,
                              action: AppButton(
                                label: l10n.tryAgain,
                                expand: false,
                                onPressed: _load,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
