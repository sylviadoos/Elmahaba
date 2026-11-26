import 'package:flutter/widgets.dart';

/// Calls [onRefresh] when the parent, down at the newest item of the
/// chat's list ([child], reversed: the newest at offset 0), keeps pulling
/// past it by [distance] — once each pull.
///
/// The other end, the oldest, is left to loading older items.
class ChatPullToRefresh extends StatefulWidget {
  const ChatPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.distance = 64,
  });

  final VoidCallback onRefresh;

  /// How far past the newest, in logical pixels, a pull asks.
  final double distance;

  final Widget child;

  @override
  State<ChatPullToRefresh> createState() => _ChatPullToRefreshState();
}

class _ChatPullToRefreshState extends State<ChatPullToRefresh> {
  /// How far past the newest this pull went.
  double _pulled = 0;

  /// This pull asked already.
  bool _asked = false;

  bool _onScroll(ScrollNotification notification) {
    // The list's own, not one inside an item.
    if (notification.depth != 0) return false;
    final metrics = notification.metrics;
    switch (notification) {
      case ScrollStartNotification():
        _pulled = 0;
        _asked = false;
      // Android: the list stops at the newest, and says by how much the
      // finger went on.
      case OverscrollNotification(:final overscroll, dragDetails: _?)
          when overscroll < 0 && metrics.pixels <= metrics.minScrollExtent:
        _pull(_pulled - overscroll);
      // iPhone: the list goes past the newest, and springs back.
      case ScrollUpdateNotification(dragDetails: _?):
        _pull(
          metrics.pixels < metrics.minScrollExtent
              ? metrics.minScrollExtent - metrics.pixels
              : 0,
        );
      default:
    }
    return false;
  }

  void _pull(double pulled) {
    _pulled = pulled;
    if (_asked || _pulled < widget.distance) return;
    _asked = true;
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: widget.child,
    );
  }
}
