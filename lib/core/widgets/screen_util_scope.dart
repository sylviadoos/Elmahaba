import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';

/// Sets up ScreenUtil (`.w`, `.h`, `.sp`, `.r`) against the design size.
///
/// Used instead of `ScreenUtilInit`, which measures the real window and so
/// ignores the phone simulated by DevicePreview. This reads the nearest
/// [MediaQuery], which DevicePreview sets to the selected device.
class ScreenUtilScope extends StatefulWidget {
  const ScreenUtilScope({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenUtilScope> createState() => _ScreenUtilScopeState();
}

class _ScreenUtilScopeState extends State<ScreenUtilScope> {
  Size? _size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = MediaQuery.of(context);
    ScreenUtil.configure(
      data: data,
      designSize: AppConstants.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // The screen size changed (rotation, or another device picked in
    // DevicePreview): rebuild everything so sizes use the new scale.
    if (_size != null && _size != data.size) {
      (context as Element).visitChildren(_markNeedsBuild);
    }
    _size = data.size;
  }

  void _markNeedsBuild(Element element) {
    element.markNeedsBuild();
    element.visitChildren(_markNeedsBuild);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
