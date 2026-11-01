class FeeItem {
  const FeeItem({
    required this.name,
    required this.amount,
    required this.isPaid,
    required this.when,
  });

  final String name;

  /// In Egyptian pounds.
  final int amount;
  final bool isPaid;

  /// e.g. "Paid Sep 20" / "Due Nov 7".
  final String when;
}

// TODO: replace with the fees API. Mock content from the design, in the
// same order as mockChildren.
const String mockSchoolYear = '2026 / 2027';

const List<List<FeeItem>> mockFees = [
  [
    FeeItem(
      name: 'Term 1 tuition',
      amount: 15000,
      isPaid: true,
      when: 'Paid Sep 20',
    ),
    FeeItem(
      name: 'Bus subscription',
      amount: 5000,
      isPaid: true,
      when: 'Paid Sep 20',
    ),
    FeeItem(
      name: 'Term 2 tuition',
      amount: 15000,
      isPaid: false,
      when: 'Due Nov 7',
    ),
    FeeItem(
      name: 'Books & uniform',
      amount: 5000,
      isPaid: false,
      when: 'Due Nov 7',
    ),
  ],
  [
    FeeItem(
      name: 'Term 1 tuition',
      amount: 12000,
      isPaid: true,
      when: 'Paid Sep 18',
    ),
    FeeItem(
      name: 'Bus subscription',
      amount: 5000,
      isPaid: true,
      when: 'Paid Sep 18',
    ),
    FeeItem(
      name: 'Term 2 tuition',
      amount: 12000,
      isPaid: true,
      when: 'Paid Oct 2',
    ),
  ],
];
