// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get nameIsRequired => 'الاسم مطلوب!';

  @override
  String get nameIsNotValid => 'الاسم غير صحيح';

  @override
  String get emailIsRequired => 'البريد الإلكتروني مطلوب!';

  @override
  String get emailIsNotValid => 'البريد الإلكتروني غير صحيح';

  @override
  String get passwordIsRequired => 'كلمة المرور مطلوبة!';

  @override
  String get passwordIsNotValid => 'كلمة المرور غير صحيحة';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get confirmPasswordIsRequired => 'تأكيد كلمة المرور مطلوب!';

  @override
  String get confirmPasswordIsNotValid => 'تأكيد كلمة المرور غير صحيح';

  @override
  String get passwordAndConfirmPasswordMustBeSame =>
      'يجب أن تكون كلمتا المرور متطابقتين';

  @override
  String get phoneNumberIsRequired => 'رقم الهاتف مطلوب!';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت!';

  @override
  String get cancelled => 'تم إلغاء الطلب إلى الخادم';

  @override
  String get unknown =>
      'حدث خطأ غير متوقع في الاتصال بالخادم ، يرجى المحاولة لاحقًا!';

  @override
  String get serverError => 'خطأ في الخادم، يرجى المحاولة لاحقًا!';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get expiredToken => 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';

  @override
  String get phoneNumberIsNotValid => 'رقم الهاتف غير صحيح';

  @override
  String get thisFieldIsRequired => 'هذا الحقل مطلوب';

  @override
  String get error => 'خطأ';

  @override
  String get ok => 'حسناً';

  @override
  String get heyThere => 'مرحباً';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPasswordQuestion => 'نسيت كلمة المرور؟';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get or => 'أو';

  @override
  String get settings => 'الإعدادات';

  @override
  String get help => 'مساعدة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get hi => 'مرحباً';

  @override
  String get apply => 'تقديم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get enterYourUsernameAndPasswordToLogin =>
      'أدخل اسم المستخدم وكلمة المرور لتسجيل الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get orLoginWith => 'أو سجل باستخدام';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟';

  @override
  String get name => 'الاسم';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get mobileNumber => 'رقم الهاتف';

  @override
  String get selectAnOption => 'اختر خياراً';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get registerSuccess => 'تم التسجيل بنجاح';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get didntReceiveCode => 'لم تستلم الكود؟';

  @override
  String get invalidCode => 'الكود غير صحيح، يرجى المحاولة مرة أخرى';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get emailVerification => 'التحقق من البريد الإلكتروني';

  @override
  String get pleaseEnterYourEmailAssociatedToYourAccount =>
      'من فضلك أدخل البريد الإلكتروني المرتبط بحسابك';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get loading => 'تحميل ...';

  @override
  String get confirm => 'تأكيد';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordMustNotBeEmpty =>
      'يجب ألا تكون كلمة المرور فارغة وأن تحتوي على 6 أحرف وحرف كبير ورقم واحد على الأقل';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String pageXOfY(int current, int total) {
    return '$current من $total';
  }

  @override
  String get onboardingGradesTitle => 'تابع درجات طفلك';

  @override
  String get onboardingGradesBody =>
      'اطّلع على نتائج الامتحانات والشهادات وملاحظات المعلمين فور نشرها.';

  @override
  String get onboardingLessonsTitle => 'اعرف ما يتعلمه كل يوم';

  @override
  String get onboardingLessonsBody =>
      'الدروس اليومية والواجبات ومواعيد التسليم، لتتمكن من مساعدته في المنزل.';

  @override
  String get onboardingFeesTitle => 'المصروفات الدراسية بوضوح وبساطة';

  @override
  String get onboardingFeesBody =>
      'اعرف ما تم دفعه وما هو مستحق، وادفع إلكترونيًا واحتفظ بكل إيصال.';

  @override
  String get aboutUs => 'من نحن';

  @override
  String get news => 'الأخبار';

  @override
  String get contact => 'تواصل';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get schoolName => 'مدارس المحبة';

  @override
  String get schoolNameTwoLines => 'مدارس المحبة';

  @override
  String get welcomeTo => 'مرحبًا بك في';

  @override
  String get schoolTagline => 'تعليم جذوره المحبة، ودافعه التميّز';

  @override
  String get languageSchool => 'مدرسة لغات';

  @override
  String get curriculaInEnglish => 'مناهج تُدرَّس باللغة الإنجليزية';

  @override
  String get whyFamiliesChooseUs => 'لماذا تختارنا العائلات';

  @override
  String get featureCurriculaTitle => 'مناهج إنجليزية';

  @override
  String get featureCurriculaBody => 'مهارات لغوية وثقافية';

  @override
  String get featureBusesTitle => 'حافلات المدرسة';

  @override
  String get featureBusesBody => 'تنقّل آمن ومريح';

  @override
  String get featureSafeTitle => 'آمنة ومبدعة';

  @override
  String get featureSafeBody => 'مكان ودود للتعلّم';

  @override
  String get featureValuesTitle => 'القيم أولًا';

  @override
  String get featureValuesBody => 'طيبة وصدق واحترام';

  @override
  String get latestNews => 'آخر الأخبار';

  @override
  String get interestedInJoining => 'مهتم بالانضمام؟';

  @override
  String get admissionTeamWillAnswer => 'فريق القبول سيجيب عن أسئلتك.';

  @override
  String get contactAdmission => 'تواصل مع القبول';

  @override
  String get aboutSubtitle => 'رسالتنا ورؤيتنا وإرثنا';

  @override
  String get ourVision => 'رؤيتنا';

  @override
  String get visionBody =>
      'أن نكون من أفضل مدارس اللغات في مصر، ونُخرّج طلابًا واثقين مستعدين للعالم.';

  @override
  String get ourMission => 'رسالتنا';

  @override
  String get mission1 => 'تعليم متميز يركّز على اللغات';

  @override
  String get mission2 => 'بيئة آمنة وودودة ومبدعة';

  @override
  String get mission3 => 'مساعدة كل طالب على اكتشاف مواهبه';

  @override
  String get mission4 => 'طلاب طيبون وصادقون ومحترمون';

  @override
  String get mission5 => 'مستعدون للامتحانات وللحياة';

  @override
  String get ourLegacy => 'إرثنا';

  @override
  String get legacyBody =>
      'أجيال من الخريجين أصبحوا قادة واثقين ومتعلمين مدى الحياة.';

  @override
  String get legacyQuote =>
      '«يحمل خريجونا قيمنا أينما ذهبوا: الصدق والاحترام والاجتهاد والانفتاح.»';

  @override
  String get schoolPrincipal => 'مديرة المدرسة';

  @override
  String get principalName => 'السيدة أحلام لويس رياض';

  @override
  String get principalInitials => 'أر';

  @override
  String get newsSubtitle => 'ما الجديد في مدارس المحبة';

  @override
  String get filterAll => 'الكل';

  @override
  String get noNewsYet => 'لا توجد أخبار بعد';

  @override
  String get noNewsYetSubtitle => 'ستظهر أخبار وفعاليات المدرسة هنا.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get schoolNews => 'أخبار المدرسة';

  @override
  String get contactSubtitle => 'يسعدنا تواصلك معنا';

  @override
  String get ourSchool => 'مدرستنا';

  @override
  String get openInGoogleMaps => 'افتح في خرائط جوجل';

  @override
  String get callOrEmail => 'اتصل أو راسلنا';

  @override
  String get phone => 'الهاتف';

  @override
  String get admission => 'القبول';

  @override
  String get followUs => 'تابعنا';

  @override
  String get couldNotOpenLink => 'تعذّر فتح الرابط';

  @override
  String get appliedThroughWebsite => 'قدّمت من خلال موقعنا؟';

  @override
  String get confirmationEmailNote =>
      'من المفترض أن تصلك رسالة تأكيد بالبريد الإلكتروني. إذا لم تصل خلال 24 ساعة، راجع مجلد الرسائل غير المرغوب فيها أو راسل الصفحة الرسمية للمدرسة.';

  @override
  String get otherLanguage => 'English';

  @override
  String get loginSubtitle =>
      'أولياء الأمور، سجّلوا الدخول لمتابعة يوم أبنائكم الدراسي.';

  @override
  String get emailOrMobile => 'البريد الإلكتروني أو رقم الموبايل';

  @override
  String get emailHint => 'parent@email.com';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get newParent => 'ولي أمر جديد؟';

  @override
  String get createAnAccount => 'أنشئ حسابًا';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'حساب ولي الأمر — تابع يوم أبنائك الدراسي.';

  @override
  String get parentFullName => 'اسم ولي الأمر بالكامل';

  @override
  String get asOnNationalId => 'كما هو في بطاقة الرقم القومي';

  @override
  String get phoneHint => '10 1234 5678';

  @override
  String get passwordHint => '6 أحرف على الأقل';

  @override
  String get agreePrefix => 'أوافق على ';

  @override
  String get terms => 'الشروط';

  @override
  String get agreeAnd => ' و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get verifyYourNumber => 'تأكيد رقمك';

  @override
  String get otpSentTo => 'أرسلنا كودًا من 6 أرقام برسالة SMS إلى ';

  @override
  String get enterVerificationCode => 'أدخل كود التحقق';

  @override
  String resendCodeIn(String time) {
    return 'إعادة الإرسال بعد $time';
  }

  @override
  String get didntGetIt => 'لم يصلك؟';

  @override
  String get resendCode => 'إعادة إرسال الكود';

  @override
  String get verify => 'تأكيد';

  @override
  String get wrongNumber => 'رقم خاطئ؟';

  @override
  String get changeIt => 'غيّره';

  @override
  String get lastStep => 'الخطوة الأخيرة';

  @override
  String get addYourChildren => 'أضف أبناءك';

  @override
  String get addChildrenSubtitle =>
      'اربط كل طفل برقمه القومي. يمكنك إضافة أكثر من طفل.';

  @override
  String get childNationalId => 'الرقم القومي للطفل';

  @override
  String get nationalIdDigitsHint => 'رقم من 14 خانة';

  @override
  String get add => 'إضافة';

  @override
  String get nationalIdMatchNote => 'نطابقه مع سجلات المدرسة للعثور على طفلك.';

  @override
  String get yourChildren => 'أبناؤك';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طفل',
      few: '$count أطفال',
      two: 'طفلان',
      one: 'طفل واحد',
    );
    return '$_temp0';
  }

  @override
  String childIdTail(String tail) {
    return 'الرقم ••••$tail';
  }

  @override
  String get linked => 'مرتبط';

  @override
  String removeChild(String name) {
    return 'إزالة $name';
  }

  @override
  String get noChildrenYet => 'لم تتم إضافة أطفال بعد';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get today => 'اليوم';

  @override
  String get results => 'النتائج';

  @override
  String get attendance => 'الحضور';

  @override
  String get fees => 'المصروفات';

  @override
  String get chat => 'المحادثة';

  @override
  String get schoolChat => 'محادثة المدرسة';

  @override
  String newCount(int count) {
    return '$count جديدة';
  }

  @override
  String daysPresentIn(String month) {
    return 'أيام حضور في $month';
  }

  @override
  String get ofTheYearPaid => 'من مصروفات العام مدفوعة';

  @override
  String get needsYourAttention => 'يحتاج انتباهك';

  @override
  String get chatGeneral => 'عام';

  @override
  String get chatPrivate => 'خاص';

  @override
  String get chatPrivateOnlyYou => 'خاص · لا يراه غيرك';

  @override
  String get youReplied => 'رددت';

  @override
  String get you => 'أنت';

  @override
  String get chatReplyHint => 'رد باختيار أحد الخيارات في كل رسالة';

  @override
  String get term1 => 'الترم الأول';

  @override
  String get term2Soon => 'الترم الثاني · قريبًا';

  @override
  String get term1Average => 'متوسط الترم الأول';

  @override
  String get reportCardPdf => 'الشهادة (PDF)';

  @override
  String get subjects => 'المواد';

  @override
  String get teachersNote => 'ملاحظة المعلم';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get late => 'متأخر';

  @override
  String get officialHoliday => 'إجازة رسمية';

  @override
  String get friSatOff => 'إجازة الجمعة والسبت';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String schoolYear(String years) {
    return 'العام الدراسي $years';
  }

  @override
  String percentPaid(String percent) {
    return '$percent مدفوعة';
  }

  @override
  String get remaining => 'المتبقي';

  @override
  String paidAmount(String amount) {
    return 'المدفوع $amount';
  }

  @override
  String totalAmount(String amount) {
    return 'الإجمالي $amount';
  }

  @override
  String payAmount(String amount) {
    return 'ادفع $amount';
  }

  @override
  String egpAmount(String amount) {
    return '$amount ج.م';
  }

  @override
  String get allFeesPaid => 'تم دفع كل المصروفات';

  @override
  String get installments => 'الأقساط';

  @override
  String get paid => 'مدفوع';

  @override
  String get due => 'مستحق';

  @override
  String get receipts => 'الإيصالات';

  @override
  String get pdf => 'PDF';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get myChildren => 'أبنائي';

  @override
  String get addAChild => 'إضافة طفل';

  @override
  String get language => 'اللغة';

  @override
  String get chatNotifications => 'إشعارات المحادثة';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get contactTheSchool => 'تواصل مع المدرسة';

  @override
  String get aboutSchool => 'عن مدارس المحبة';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get allParents => 'كل أولياء الأمور';

  @override
  String get yesterday => 'أمس';

  @override
  String get earlier => 'سابقًا';

  @override
  String get unread => 'غير مقروء';

  @override
  String get sendUsAMessage => 'أرسل لنا رسالة';

  @override
  String get writeToUs => 'راسلنا';

  @override
  String get sendMessageSubtitle => 'سنرد عليك في أقرب وقت ممكن';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get firstNameHint => 'اسمك الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get lastNameHint => 'اسم العائلة';

  @override
  String get optional => 'اختياري';

  @override
  String get educationType => 'نوع التعليم';

  @override
  String get chooseEducationType => 'اختر نوع التعليم';

  @override
  String get schoolStage => 'المرحلة';

  @override
  String get chooseStage => 'اختر المرحلة';

  @override
  String get educationLanguage => 'لغات';

  @override
  String get stageBabyClass => 'بيبي كلاس';

  @override
  String get stageKg1 => 'KG1';

  @override
  String get stageKg2 => 'KG2';

  @override
  String get stagePrimary1 => 'الصف الأول الابتدائي';

  @override
  String get stagePrimary2 => 'الصف الثاني الابتدائي';

  @override
  String get stagePrimary3 => 'الصف الثالث الابتدائي';

  @override
  String get stagePrimary4 => 'الصف الرابع الابتدائي';

  @override
  String get stagePrimary5 => 'الصف الخامس الابتدائي';

  @override
  String get yourMessage => 'الرسالة';

  @override
  String get messageHint => 'اكتب رسالتك هنا…';

  @override
  String get sendMessage => 'إرسال الرسالة';

  @override
  String get checkHighlightedFields => 'من فضلك راجع الحقول المحددة.';

  @override
  String get messageSentTitle => 'تم إرسال رسالتك!';

  @override
  String get messageSentSubtitle => 'شكراً لك! ستتواصل معك المدرسة قريباً.';

  @override
  String get done => 'تم';
}
