import 'dart:typed_data';

/// A fee statement PDF made on the phone, ready to show or save.
class FeeStatementPdfFile {
  const FeeStatementPdfFile({required this.name, required this.bytes});

  /// e.g. "fee-statement-31806012500923.pdf".
  final String name;
  final Uint8List bytes;
}
