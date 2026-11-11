import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';

extension ParentContext on BuildContext {
  /// The signed-in parent, from the app's shared [ParentViewModel].
  /// Rebuilds the caller when it changes; null until it loads.
  ParentEntity? watchParent() => select<ParentViewModel, ParentEntity?>(
    (viewModel) => viewModel.state.data,
  );
}

extension ParentInitials on ParentEntity {
  /// The first letters of the first two names: "SA" for "Samar Ahmed".
  String get initials => name.initials;
}

extension ParentFormValues on ParentEntity {
  /// "Samar" for "Samar Ahmed Ali".
  String get firstName => _names.firstOrNull ?? '';

  /// The rest: "Ahmed Ali" for "Samar Ahmed Ali".
  String get lastName => _names.skip(1).join(' ');

  /// The mobile as typed after the +20 prefix: "1201234154"; empty when
  /// only the masked one is known.
  String get phoneAfterCountryCode {
    final full = fullPhone ?? '';
    return full.startsWith('0') ? full.substring(1) : full;
  }

  List<String> get _names =>
      name.trim().split(RegExp(r'\s+')).where((n) => n.isNotEmpty).toList();
}
