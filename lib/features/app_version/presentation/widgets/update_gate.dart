import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_bloc.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_intent.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_state.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/widgets/forced_update_view.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/widgets/update_dialog.dart';

/// Opens a store page; the default opens it in the store app.
typedef OpenStore = Future<void> Function(String url);

/// Over the whole app (`MaterialApp.router`'s `builder`, see `app.dart`):
/// asks the school about the installed version as the app opens and on
/// coming back to it, and shows what it says.
///
/// - Forced: the update card **instead of** the app. Nothing under it is
///   there to reach, so nothing closes it — not a tap beside it, not back
///   (which leaves the app). Back from the store without updating, it's
///   still there; only the updated app opens without it.
/// - Optional: the card over the app, with "Later".
/// - Nothing, or the school not answering: the app as usual.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child, this.openStore});

  final Widget child;

  /// For tests; the store app otherwise.
  final OpenStore? openStore;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  /// Coming back to the app asks again once this long has passed: a forced
  /// update reaches an app left open for days, without a request every
  /// time the parent switches apps.
  static const Duration _askAgainAfter = Duration(minutes: 30);

  DateTime? _lastAsked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final last = _lastAsked;
    if (state == AppLifecycleState.resumed &&
        (last == null || DateTime.now().difference(last) >= _askAgainAfter)) {
      _check();
    }
  }

  void _check() {
    _lastAsked = DateTime.now();
    context.read<AppVersionBloc>().add(const CheckAppVersionIntent());
  }

  Future<void> _openStore(String url) =>
      (widget.openStore ?? _launchStore)(url);

  static Future<void> _launchStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (e) {
      debugPrint('Opening the store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppVersionBloc, AppVersionState>(
      builder: (context, state) {
        if (state case ForcedUpdateState(:final update)) {
          return ForcedUpdateView(
            update: update,
            onUpdate: () => _openStore(update.storeUrl),
          );
        }
        // The app always first in the same Stack: the card coming and going
        // over it doesn't rebuild the pages open under it.
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (state case OptionalUpdateState(:final update)) ...[
              // Only "Later" closes it, not a tap beside it.
              const ModalBarrier(dismissible: false, color: Colors.black54),
              Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.r),
                      child: UpdateDialog(
                        update: update,
                        onUpdate: () => _openStore(update.storeUrl),
                        onLater: () => context.read<AppVersionBloc>().add(
                          const PostponeUpdateIntent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
