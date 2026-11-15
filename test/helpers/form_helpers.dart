import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';

/// The text field of the `AppTextField` labelled [label].
Finder textFieldLabeled(String label) => find.descendant(
  of: find.widgetWithText(AppTextField, label),
  matching: find.byType(TextField),
);

/// The button (elevated, outlined or text) showing [label].
Finder buttonLabeled(String label) => find
    .ancestor(
      of: find.text(label),
      matching: find.bySubtype<ButtonStyleButton>(),
    )
    .first;

extension FormActions on WidgetTester {
  /// Whether the button showing [label] can be pressed.
  bool isEnabled(String label) =>
      widget<ButtonStyleButton>(buttonLabeled(label)).enabled;

  /// Scrolls [finder] into view, then taps it.
  Future<void> tapShown(Finder finder) async {
    await ensureVisible(finder);
    await pump();
    await tap(finder);
  }

  /// Lets the tap's action finish and the next page (or snack bar) come
  /// in.
  Future<void> settle() async {
    await pump(); // the action ends, the router builds the next page
    await pump(const Duration(seconds: 1)); // page transition
  }
}
