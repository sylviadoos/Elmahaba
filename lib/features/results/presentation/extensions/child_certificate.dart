import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';

extension ChildCertificate on ChildEntity {
  /// The monthly certificate with only the child on it (name, class,
  /// grade), no marks: what downloads when the school sent no monthly
  /// results.
  MonthlyCertificateEntity get blankCertificate => MonthlyCertificateEntity(
    studentName: name,
    studentNameAr: nameAr,
    grade: grade,
    className: className,
    academicYear: academicYear,
  );
}
