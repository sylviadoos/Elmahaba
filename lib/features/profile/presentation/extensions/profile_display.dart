import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';

extension ProfileDisplay on ProfileEntity {
  /// The parent's name in the app's language, as the school has it for the
  /// father or mother who signed in ([you]); else the account's.
  String displayName(BuildContext context) {
    final yours = you?.displayName(context) ?? '';
    return yours.isNotEmpty ? yours : name;
  }
}
