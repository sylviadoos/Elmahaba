/// Draws a PDF's pages as pictures, to show them where a PDF reader isn't.
abstract interface class PdfPreviewer {
  /// The first page of the PDF at [pdfPath], as a PNG saved beside it
  /// (made once, then reused); the result is where. Throws when the file
  /// isn't a PDF that can be drawn.
  Future<String> firstPage(String pdfPath);
}
