import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/attendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/repos/attendance_repo.dart';

@LazySingleton(as: AttendanceRepo)
class AttendanceRepoImpl implements AttendanceRepo {
  AttendanceRepoImpl(this._remoteDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<MonthAttendanceEntity>> getMonthAttendance({
    required int childId,
    required DateTime month,
  }) => Result.guard(
    () => _remoteDataSource.getMonthAttendance(childId: childId, month: month),
  );
}
