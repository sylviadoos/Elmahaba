/// Central place for every asset path used in the app.
///
/// Add a constant here whenever you drop a new file into `assets/`,
/// then reference it as `AppImages.logoMarkRed`, `AppIcons.navHome`, etc.
abstract final class AppAssets {
  static const String _base = 'assets';
  static const String images = '$_base/images';
  static const String icons = '$_base/icons';
  static const String lottie = '$_base/lottie';
}

/// Images. `.svg` → `SvgPicture.asset`, others → `Image.asset`.
abstract final class AppImages {
  static const String headerWave = '${AppAssets.images}/header_wave.svg';

  /// [headerWave] in `AppColors.surface`.
  static const String headerWaveSurface =
      '${AppAssets.images}/header_wave_surface.svg';

  /// [logoMarkWhite] at 9%, for the red headers' corner.
  static const String logoMarkWatermark =
      '${AppAssets.images}/logo_mark_watermark.svg';
  static const String logoMarkRed = '${AppAssets.images}/logo_mark_red.svg';
  static const String logoMarkWhite = '${AppAssets.images}/logo_mark_white.svg';
  static const String newsBeeDegree = '${AppAssets.images}/news_bee_degree.jpg';
  static const String newsBirthdays = '${AppAssets.images}/news_birthdays.jpg';
  static const String sparkle = '${AppAssets.images}/sparkle.svg';
  static const String studentBoy = '${AppAssets.images}/student_boy.png';
  static const String studentGirlCutout =
      '${AppAssets.images}/student_girl_cutout.png';
  static const String studentGirlFlex =
      '${AppAssets.images}/student_girl_flex.png';
  static const String studentOriginal =
      '${AppAssets.images}/student_original.jpg';
  static const String studentTeen = '${AppAssets.images}/student_teen.png';
}

/// SVG icons — show with `AppSvgIcon(AppIcons.navHome)`.
abstract final class AppIcons {
  static const String alertCircle = '${AppAssets.icons}/ic_alert_circle.svg';
  static const String arrowLeft = '${AppAssets.icons}/ic_arrow_left.svg';
  static const String arrowRight = '${AppAssets.icons}/ic_arrow_right.svg';
  static const String awardLegacy = '${AppAssets.icons}/ic_award_legacy.svg';
  static const String bell = '${AppAssets.icons}/ic_bell.svg';
  static const String book = '${AppAssets.icons}/ic_book.svg';
  static const String briefcase = '${AppAssets.icons}/ic_briefcase.svg';
  static const String bus = '${AppAssets.icons}/ic_bus.svg';
  static const String calendarPresent =
      '${AppAssets.icons}/ic_calendar_present.svg';
  static const String calendarToday =
      '${AppAssets.icons}/ic_calendar_today.svg';
  static const String check = '${AppAssets.icons}/ic_check.svg';
  static const String chevronLeft = '${AppAssets.icons}/ic_chevron_left.svg';
  static const String chevronRight = '${AppAssets.icons}/ic_chevron_right.svg';
  static const String close = '${AppAssets.icons}/ic_close.svg';
  static const String complaint = '${AppAssets.icons}/ic_complaints.svg';
  static const String download = '${AppAssets.icons}/ic_download.svg';
  static const String edit = '${AppAssets.icons}/ic_edit.svg';
  static const String eye = '${AppAssets.icons}/ic_eye.svg';
  static const String eyeOff = '${AppAssets.icons}/ic_eye_off.svg';
  static const String eyeVision = '${AppAssets.icons}/ic_eye_vision.svg';
  static const String file = '${AppAssets.icons}/ic_file.svg';
  static const String fileReport = '${AppAssets.icons}/ic_file_report.svg';
  static const String globeLanguage =
      '${AppAssets.icons}/ic_globe_language.svg';
  static const String graduationCap =
      '${AppAssets.icons}/ic_graduation_cap.svg';
  static const String heart = '${AppAssets.icons}/ic_heart.svg';
  static const String idCard = '${AppAssets.icons}/ic_id_card.svg';
  static const String info = '${AppAssets.icons}/ic_info.svg';
  static const String lock = '${AppAssets.icons}/ic_lock.svg';
  static const String lockReset = '${AppAssets.icons}/ic_lock_reset.svg';
  static const String lockPrivate = '${AppAssets.icons}/ic_lock_private.svg';
  static const String logIn = '${AppAssets.icons}/ic_log_in.svg';
  static const String logOut = '${AppAssets.icons}/ic_log_out.svg';
  static const String mail = '${AppAssets.icons}/ic_mail.svg';
  static const String mapPin = '${AppAssets.icons}/ic_map_pin.svg';
  static const String megaphoneGeneral =
      '${AppAssets.icons}/ic_megaphone_general.svg';
  static const String navAttendance =
      '${AppAssets.icons}/ic_nav_attendance.svg';
  static const String navChat = '${AppAssets.icons}/ic_nav_chat.svg';
  static const String navFees = '${AppAssets.icons}/ic_nav_fees.svg';
  static const String navHome = '${AppAssets.icons}/ic_nav_home.svg';
  static const String navResults = '${AppAssets.icons}/ic_nav_results.svg';
  static const String navigate = '${AppAssets.icons}/ic_navigate.svg';
  static const String news = '${AppAssets.icons}/ic_news.svg';
  static const String paperclip = '${AppAssets.icons}/ic_paperclip.svg';
  static const String phone = '${AppAssets.icons}/ic_phone.svg';
  static const String photo = '${AppAssets.icons}/ic_photo.svg';
  static const String plus = '${AppAssets.icons}/ic_plus.svg';
  static const String reply = '${AppAssets.icons}/ic_reply.svg';
  static const String send = '${AppAssets.icons}/ic_send.svg';
  static const String settings = '${AppAssets.icons}/ic_settings.svg';
  static const String shieldCheck = '${AppAssets.icons}/ic_shield_check.svg';
  static const String smartphoneOtp =
      '${AppAssets.icons}/ic_smartphone_otp.svg';
  static const String subjectMath = '${AppAssets.icons}/ic_subject_math.svg';
  static const String subjectScience =
      '${AppAssets.icons}/ic_subject_science.svg';
  static const String sunHoliday = '${AppAssets.icons}/ic_sun_holiday.svg';
  static const String tapChoose = '${AppAssets.icons}/ic_tap_choose.svg';
  static const String targetMission =
      '${AppAssets.icons}/ic_target_mission.svg';
  static const String trash = '${AppAssets.icons}/ic_trash.svg';
  static const String user = '${AppAssets.icons}/ic_user.svg';
  static const String userFilled = '${AppAssets.icons}/ic_user_filled.svg';
}

/// Lottie animations — `Lottie.asset(AppLottie.splash)`.
abstract final class AppLottie {
  static const String onboarding1Grades =
      '${AppAssets.lottie}/onboarding_1_grades.json';
  static const String onboarding2Learning =
      '${AppAssets.lottie}/onboarding_2_learning.json';
  static const String onboarding3Fees =
      '${AppAssets.lottie}/onboarding_3_fees.json';
  static const String splash = '${AppAssets.lottie}/splash.json';
}

/// Font family names — must match `family:` in pubspec.yaml.
abstract final class AppFonts {
  static const String cairo = 'Cairo';
  static const String montserrat = 'Montserrat';
  static const String outfit = 'Outfit';
}
