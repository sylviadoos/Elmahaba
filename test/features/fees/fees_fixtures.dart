import 'package:al_mahhaba_school/features/fees/domain/entities/bus_subscription_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_student_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';

const firstEducation = '8472|قسط اول|2026-08-16';

/// The school's own sentence for the bus installment, as its website
/// shows it.
const busReason = 'اختر أقساط التعليم السابقة أولاً';

/// The bus, as the school lists it on the statement.
const busFeeId = 159;
const busFeeName = 'اشتراك الباص';

const student = FeeStudentEntity(
  id: 9,
  name: 'Rovanio Abram',
  nameEn: 'Rovanio Abram',
  nameAr: 'روفانيو ابرام',
  nationalId: '32207262500509',
  grade: 'Second Primary',
  academicYear: '2026-2027',
);

/// The tuition the school always charges: no id, never dropped.
const tuition = FeeEntity(
  id: null,
  name: 'مصاريف التعليم والنشاط',
  bankAccount: '••••••••/446',
  amount: 18000,
  isOptional: false,
  isPaid: false,
  canDelete: false,
);

/// The bus as an optional fee still on offer — not on the statement yet.
const busOnOffer = FeeEntity(
  id: busFeeId,
  name: busFeeName,
  bankAccount: '••••••••/447',
  amount: 8000,
  isOptional: true,
  isPaid: false,
  canDelete: false,
);

/// The bus once the parent added it: a mandatory line they may drop
/// again while nothing is paid on it.
const busAdded = FeeEntity(
  id: busFeeId,
  name: busFeeName,
  bankAccount: '••••••••/447',
  amount: 8000,
  isOptional: false,
  isPaid: false,
  canDelete: true,
);

/// A child's statement: the [fees] lines, and an education installment
/// that comes before a bus one — locked, with [reason] for why.
FeeStatementEntity statement({
  String reason = busReason,
  List<FeeEntity> fees = const [tuition],
  bool canChangeOptionalFees = true,
}) => FeeStatementEntity(
  student: student,
  payOnlineEnabled: true,
  fees: fees,
  totalAmount: 8000,
  paidAmount: 0,
  remainingBalance: 8000,
  installments: [
    const FeeInstallmentEntity(
      feeName: 'مصاريف التعليم والنشاط',
      label: 'قسط اول',
      bankAccount: '••••••••/446',
      amount: 5000,
      status: InstallmentStatus.overdue,
      statusLabel: 'متأخر',
      canPay: true,
      payKey: firstEducation,
    ),
    FeeInstallmentEntity(
      feeName: 'الباص',
      label: 'قسط اول',
      bankAccount: '••••••••/447',
      amount: 3000,
      status: InstallmentStatus.upcoming,
      statusLabel: 'قادم',
      canPay: true,
      payKey: '8473|قسط اول|2026-10-01',
      requires: const [firstEducation],
      lockedReason: reason,
    ),
  ],
  busSubscription: const BusSubscriptionEntity(
    available: false,
    status: 'NONE',
  ),
  canChangeOptionalFees: canChangeOptionalFees,
);
