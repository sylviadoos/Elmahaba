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
