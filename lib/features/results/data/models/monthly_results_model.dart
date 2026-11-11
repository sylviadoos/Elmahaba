import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/data/models/monthly_certificate_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_sheet_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';

class MonthlyResultsModel extends MonthlyResultsEntity {
  const MonthlyResultsModel({super.sheets, super.certificate});

  /// The whole response of `result-sheets?template=monthly`:
  /// { "status": "success", "data": [ …sheet… ], "meta": { … },
  ///   "certificate": { "student": {…}, "months": […], "subjects": […] } }
  factory MonthlyResultsModel.fromJson(Map<String, dynamic> json) =>
      MonthlyResultsModel(
        sheets: [
          for (final sheet in jsonObjects(json[ApiKeys.data]))
            // One without its id couldn't be told apart.
            if (sheet['id'] is int) ResultSheetModel.fromJson(sheet),
        ],
        certificate: switch (json['certificate']) {
          final Map<String, dynamic> certificate =>
            MonthlyCertificateModel.fromJson(certificate),
          _ => null,
        },
      );
}
