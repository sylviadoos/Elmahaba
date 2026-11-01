/// A quick reply on a school message: the button [label] and the [reply]
/// it sends.
class ChatOption {
  const ChatOption(this.label, this.reply);

  final String label;
  final String reply;
}

/// Screen a message's link button opens.
enum ChatLink { fees, results }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isGeneral,
    required this.audience,
    required this.time,
    required this.title,
    required this.body,
    this.action,
    this.actionLink,
    this.options = const [],
  });

  final String id;

  /// Sent to a class or all parents, rather than privately to this parent.
  final bool isGeneral;

  /// Who it was sent to, e.g. "Omar", "Class 4B", "All parents".
  final String audience;
  final String time;
  final String title;
  final String body;

  /// Label of a link button, e.g. "Pay now".
  final String? action;
  final ChatLink? actionLink;
  final List<ChatOption> options;
}

// TODO: replace with the chat API. Mock content from the design, in the
// same order as mockChildren.
const ChatMessage _birthdays = ChatMessage(
  id: 'bday',
  isGeneral: true,
  audience: 'All parents',
  time: '9:41',
  title: 'Birthday celebration',
  body:
      'Today we celebrated the birthdays of children born in September and October. Happy birthday to all of them!',
);

const List<List<ChatMessage>> mockChats = [
  [
    ChatMessage(
      id: 'fees',
      isGeneral: false,
      audience: 'Omar',
      time: '8:00',
      title: 'Term 2 fees due in 12 days',
      body: 'EGP 20,000 is due on Nov 7. 50% of the year is paid.',
      action: 'Pay now',
      actionLink: ChatLink.fees,
    ),
    ChatMessage(
      id: 'absence',
      isGeneral: false,
      audience: 'Omar',
      time: '8:05',
      title: 'Omar was absent today',
      body: 'Monday, Oct 26. Please tell us the reason.',
      options: [
        ChatOption('He’s sick', 'Omar is sick today.'),
        ChatOption('Family reason', 'Omar is absent for a family reason.'),
        ChatOption(
          'He was at school',
          'Omar was at school today, please check.',
        ),
      ],
    ),
    ChatMessage(
      id: 'results',
      isGeneral: false,
      audience: 'Omar',
      time: '9:10',
      title: 'Term 1 results are out',
      body: 'Average 92% · Excellent.',
      action: 'View results',
      actionLink: ChatLink.results,
    ),
    ChatMessage(
      id: 'book',
      isGeneral: true,
      audience: 'Class 4B',
      time: '9:30',
      title: 'Please bring the Science book tomorrow',
      body: 'Students will need it for the plants activity in class.',
      options: [
        ChatOption('Will bring it', 'Okay, he will bring it.'),
        ChatOption('We don’t have it', 'We don’t have this book.'),
      ],
    ),
    _birthdays,
  ],
  [
    ChatMessage(
      id: 'lfees',
      isGeneral: false,
      audience: 'Lina',
      time: '8:00',
      title: 'All fees are paid',
      body: 'Your receipts are saved in Fees.',
      action: 'View receipts',
      actionLink: ChatLink.fees,
    ),
    ChatMessage(
      id: 'lresults',
      isGeneral: false,
      audience: 'Lina',
      time: '9:05',
      title: 'Term 1 report is ready',
      body: 'Average 96% · Excellent.',
      action: 'View report',
      actionLink: ChatLink.results,
    ),
    ChatMessage(
      id: 'photo',
      isGeneral: true,
      audience: 'KG 2',
      time: '9:20',
      title: 'Please send a family photo by Thursday',
      body: 'We’ll use it for the “My family” activity in class.',
      options: [
        ChatOption('Will send it', 'Okay, I will send it.'),
        ChatOption('Need more time', 'I need a few more days, please.'),
      ],
    ),
    _birthdays,
  ],
];

/// Replies already given: message id → chosen option label.
const Map<String, String> mockAnswers = {'absence': 'He’s sick'};
