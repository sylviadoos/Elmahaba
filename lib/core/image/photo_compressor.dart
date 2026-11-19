import 'dart:math' as math;

/// A photo made lighter: where it's saved and its size in bytes.
typedef CompressedPhoto = ({String path, int size});

/// Makes photos lighter before they're sent: smaller, and without what the
/// camera wrote in them (where it was taken, for one).
abstract interface class PhotoCompressor {
  /// The photo at [path] as a JPEG at most [PhotoCompression.maxSide] px on
  /// its long side, at [PhotoCompression.quality], turned the way it's
  /// seen; saved apart, the original left as it is. Null when it can't be
  /// read as a photo.
  Future<CompressedPhoto?> compress(String path);
}

/// How photos are made lighter.
abstract final class PhotoCompression {
  /// The long side, in px: a page or a prescription still reads well.
  static const int maxSide = 1920;

  /// JPEG quality (0–100).
  static const int quality = 75;

  /// What the short side of a [width] × [height] photo is to be for its
  /// long side to be [maxSide] at most (the compressor sizes photos by
  /// their short side); its own when it's small enough already.
  static int shortSideFor(int width, int height) {
    final long = math.max(width, height);
    final short = math.min(width, height);
    if (short <= 0) return maxSide;
    if (long <= maxSide) return short;
    return math.max(1, maxSide * short ~/ long);
  }
}
