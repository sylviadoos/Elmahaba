import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/attendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:al_mahhaba_school/features/attendance/data/models/month_attendance_model.dart';

@LazySingleton(as: AttendanceRemoteDataSource)
class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<MonthAttendanceModel> getMonthAttendance({
    required int childId,
    required DateTime month,
  }) async {
    // { "status": "success", "data": { "student_id": 1201,
    //   "month": "2026-10", "counts": {…}, "records": […],
    //   "holidays": […] } }
    final json =
        await _api.get(
              ApiEndpoints.childAttendance(childId),
              // Built by hand: a DateFormat could write Arabic digits.
              queryParameters: {
                'month': '${month.year}-${'${month.month}'.padLeft(2, '0')}',
              },
            )
            as Map<String, dynamic>;
    return MonthAttendanceModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
      month: month,
    );
  }
}
