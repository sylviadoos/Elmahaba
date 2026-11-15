import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/parent_context.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_info_section.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/presentation/extensions/profile_display.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_event.dart';
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_header.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_parent_section.dart';

/// Parent profile, from Settings: their name and phone, and the
/// children's father and mother as the school has them (name, job,
/// education, phone; "You" on the one signed in).
///
/// The children themselves are on Settings (`MyChildrenSection`), so the
/// parent reaches them without opening this page.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.profile});

  /// The account as Settings loaded it, shown while it loads again.
  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProfileViewModel>()..doAction(const LoadProfileEvent()),
      child: _ProfileView(profile: profile),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({this.profile});

  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // As the school has it now; meanwhile (or if it can't load) as Settings
    // had it, else as kept at log in.
    final loaded = context.select(
      (ProfileViewModel viewModel) => viewModel.state.profile,
    );
    final profile = loaded.data ?? this.profile;
    final parent = context.watchParent();

    /// The section of [father] or [mother], when the school has anything
    /// of theirs.
    Widget? parentSection(String title, ChildParentEntity? of) {
      if (of == null) return null;
      if (!ChildInfoSection.anyIn(ProfileParentSection.infosOf(context, of))) {
        return null;
      }
      return ProfileParentSection(
        title: title,
        parent: of,
        isYou: identical(of, profile?.you),
      );
    }

    final father = parentSection(l10n.father, profile?.father);
    final mother = parentSection(l10n.mother, profile?.mother);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                name: profile?.displayName(context) ?? parent?.name,
                phone: profile?.phone ?? parent?.phone,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  6.h,
                  20.w,
                  math.max(36.h, bottomInset + 16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20.h,
                  children: [
                    // The father and mother come with the profile.
                    if (profile == null && loaded.state == StateType.loading)
                      Center(
                        child: SizedBox.square(
                          dimension: 24.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ?father,
                    ?mother,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
