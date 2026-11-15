/// The fee statement's labels — English and Arabic together, like the
/// school's printed statement, so the same in both app languages.
abstract final class StatementLabels {
  static const studentSummary = ('Student summary', 'ملخص الطالب');
  static const feeStatement = ('Fee statement', 'كشف الرسوم');
  static const choosePaymentMethod = (
    'Choose payment method',
    'اختر طريقة الدفع',
  );
  static const mandatory = ('Mandatory', 'إلزامي');
  static const optional = ('Optional', 'اختياري');
  static const totalAmount = ('Total amount', 'إجمالي المبلغ');
  static const paidAmount = ('Paid amount', 'المبلغ المدفوع');
  static const remainingBalance = ('Remaining balance', 'الرصيد المتبقي');

  static const student = 'STUDENT · الطالب';
  static const school = 'SCHOOL · المدرسة';
  static const nationalId = 'NATIONAL ID · الرقم القومي';
  static const grade = 'GRADE · الصف';
  static const date = 'DATE · التاريخ';

  static const payFullNote = (
    'Pay the full remaining balance using the bank account numbers listed '
        'in the fee statement above.',
    'ادفع الرصيد المتبقي بالكامل باستخدام أرقام الحسابات البنكية الموضحة '
        'في كشف الرسوم أعلاه.',
  );
}
