import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';

extension EducationTypeLabel on EducationType {
  String label(AppLocalizations l10n) => switch (this) {
    EducationType.language => l10n.educationLanguage,
  };
}

extension SchoolStageLabel on SchoolStage {
  String label(AppLocalizations l10n) => switch (this) {
    SchoolStage.babyClass => l10n.stageBabyClass,
    SchoolStage.kg1 => l10n.stageKg1,
    SchoolStage.kg2 => l10n.stageKg2,
    SchoolStage.primary1 => l10n.stagePrimary1,
    SchoolStage.primary2 => l10n.stagePrimary2,
    SchoolStage.primary3 => l10n.stagePrimary3,
    SchoolStage.primary4 => l10n.stagePrimary4,
    SchoolStage.primary5 => l10n.stagePrimary5,
  };
}
