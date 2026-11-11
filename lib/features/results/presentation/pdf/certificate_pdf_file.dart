import 'dart:typed_data';

/// A certificate PDF made on the phone, ready to save.
class CertificatePdfFile {
  const CertificatePdfFile({required this.name, required this.bytes});

  /// e.g. "monthly-certificate-2026-2027.pdf".
  final String name;
  final Uint8List bytes;
}
