/// What the PDF viewer opens with: the file saved on the phone at [path],
/// and its name ([fileName]) for the bar.
class ChatPdfArgs {
  const ChatPdfArgs({required this.fileName, required this.path});

  final String fileName;
  final String path;
}
