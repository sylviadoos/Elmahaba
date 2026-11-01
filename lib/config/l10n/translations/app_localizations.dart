import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required!'**
  String get nameIsRequired;

  /// No description provided for @nameIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'This name is not valid'**
  String get nameIsNotValid;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required!'**
  String get emailIsRequired;

  /// No description provided for @emailIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'This email is not valid'**
  String get emailIsNotValid;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required!'**
  String get passwordIsRequired;

  /// No description provided for @passwordIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'This password is not valid'**
  String get passwordIsNotValid;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @confirmPasswordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required!'**
  String get confirmPasswordIsRequired;

  /// No description provided for @confirmPasswordIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'This confirm password is not valid'**
  String get confirmPasswordIsNotValid;

  /// No description provided for @passwordAndConfirmPasswordMustBeSame.
  ///
  /// In en, this message translates to:
  /// **'Password and confirm password must be same!'**
  String get passwordAndConfirmPasswordMustBeSame;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required!'**
  String get phoneNumberIsRequired;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection!'**
  String get noInternet;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'The request to the server was cancelled'**
  String get cancelled;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while connecting to the server, please try again later!'**
  String get unknown;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error, please try again later!'**
  String get serverError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @expiredToken.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please log in again'**
  String get expiredToken;

  /// No description provided for @phoneNumberIsNotValid.
  ///
  /// In en, this message translates to:
  /// **'This phone number is not valid'**
  String get phoneNumberIsNotValid;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @heyThere.
  ///
  /// In en, this message translates to:
  /// **'Hey There'**
  String get heyThere;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @enterYourUsernameAndPasswordToLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password to login'**
  String get enterYourUsernameAndPasswordToLogin;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @selectAnOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectAnOption;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully'**
  String get registerSuccess;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code, please try again'**
  String get invalidCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerification;

  /// No description provided for @pleaseEnterYourEmailAssociatedToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email associated with your account'**
  String get pleaseEnterYourEmailAssociatedToYourAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @passwordMustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password must not be empty and must contain at least 6 characters, one uppercase letter, and one number'**
  String get passwordMustNotBeEmpty;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @pageXOfY.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String pageXOfY(int current, int total);

  /// No description provided for @onboardingGradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your child’s grades'**
  String get onboardingGradesTitle;

  /// No description provided for @onboardingGradesBody.
  ///
  /// In en, this message translates to:
  /// **'See exam results, report cards and teacher notes the moment they’re published.'**
  String get onboardingGradesBody;

  /// No description provided for @onboardingLessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Know what they learn each day'**
  String get onboardingLessonsTitle;

  /// No description provided for @onboardingLessonsBody.
  ///
  /// In en, this message translates to:
  /// **'Daily lessons, homework and due dates — so you can help at home.'**
  String get onboardingLessonsBody;

  /// No description provided for @onboardingFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'School fees, clear and simple'**
  String get onboardingFeesTitle;

  /// No description provided for @onboardingFeesBody.
  ///
  /// In en, this message translates to:
  /// **'See what’s paid and what’s due, pay online and keep every receipt.'**
  String get onboardingFeesBody;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @schoolName.
  ///
  /// In en, this message translates to:
  /// **'Al Mahabbah Schools'**
  String get schoolName;

  /// No description provided for @schoolNameTwoLines.
  ///
  /// In en, this message translates to:
  /// **'Al Mahabbah\nSchools'**
  String get schoolNameTwoLines;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @schoolTagline.
  ///
  /// In en, this message translates to:
  /// **'Education Rooted in Love, Driven by Excellence'**
  String get schoolTagline;

  /// No description provided for @languageSchool.
  ///
  /// In en, this message translates to:
  /// **'Language school'**
  String get languageSchool;

  /// No description provided for @curriculaInEnglish.
  ///
  /// In en, this message translates to:
  /// **'Curricula taught in English'**
  String get curriculaInEnglish;

  /// No description provided for @whyFamiliesChooseUs.
  ///
  /// In en, this message translates to:
  /// **'Why families choose us'**
  String get whyFamiliesChooseUs;

  /// No description provided for @featureCurriculaTitle.
  ///
  /// In en, this message translates to:
  /// **'English curricula'**
  String get featureCurriculaTitle;

  /// No description provided for @featureCurriculaBody.
  ///
  /// In en, this message translates to:
  /// **'Language & cultural skills'**
  String get featureCurriculaBody;

  /// No description provided for @featureBusesTitle.
  ///
  /// In en, this message translates to:
  /// **'School buses'**
  String get featureBusesTitle;

  /// No description provided for @featureBusesBody.
  ///
  /// In en, this message translates to:
  /// **'Safe, convenient transport'**
  String get featureBusesBody;

  /// No description provided for @featureSafeTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe & creative'**
  String get featureSafeTitle;

  /// No description provided for @featureSafeBody.
  ///
  /// In en, this message translates to:
  /// **'A friendly place to learn'**
  String get featureSafeBody;

  /// No description provided for @featureValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Values first'**
  String get featureValuesTitle;

  /// No description provided for @featureValuesBody.
  ///
  /// In en, this message translates to:
  /// **'Kind, honest, respectful'**
  String get featureValuesBody;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNews;

  /// No description provided for @interestedInJoining.
  ///
  /// In en, this message translates to:
  /// **'Interested in joining?'**
  String get interestedInJoining;

  /// No description provided for @admissionTeamWillAnswer.
  ///
  /// In en, this message translates to:
  /// **'Our admission team will answer your questions.'**
  String get admissionTeamWillAnswer;

  /// No description provided for @contactAdmission.
  ///
  /// In en, this message translates to:
  /// **'Contact admission'**
  String get contactAdmission;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our mission, vision and legacy'**
  String get aboutSubtitle;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our vision'**
  String get ourVision;

  /// No description provided for @visionBody.
  ///
  /// In en, this message translates to:
  /// **'One of the best language schools in Egypt, raising confident students ready for the world.'**
  String get visionBody;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get ourMission;

  /// No description provided for @mission1.
  ///
  /// In en, this message translates to:
  /// **'Quality education with a strong language focus'**
  String get mission1;

  /// No description provided for @mission2.
  ///
  /// In en, this message translates to:
  /// **'A safe, friendly and creative environment'**
  String get mission2;

  /// No description provided for @mission3.
  ///
  /// In en, this message translates to:
  /// **'Help every student find their talents'**
  String get mission3;

  /// No description provided for @mission4.
  ///
  /// In en, this message translates to:
  /// **'Kind, honest and respectful students'**
  String get mission4;

  /// No description provided for @mission5.
  ///
  /// In en, this message translates to:
  /// **'Ready for exams and for real life'**
  String get mission5;

  /// No description provided for @ourLegacy.
  ///
  /// In en, this message translates to:
  /// **'Our legacy'**
  String get ourLegacy;

  /// No description provided for @legacyBody.
  ///
  /// In en, this message translates to:
  /// **'Generations of graduates who became confident leaders and lifelong learners.'**
  String get legacyBody;

  /// No description provided for @legacyQuote.
  ///
  /// In en, this message translates to:
  /// **'“Our graduates carry our values wherever they go — honesty, respect, hard work, and open-mindedness.”'**
  String get legacyQuote;

  /// No description provided for @schoolPrincipal.
  ///
  /// In en, this message translates to:
  /// **'School Principal'**
  String get schoolPrincipal;

  /// No description provided for @principalName.
  ///
  /// In en, this message translates to:
  /// **'Mrs. Ahlam Louis Riad'**
  String get principalName;

  /// No description provided for @principalInitials.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get principalInitials;

  /// No description provided for @newsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What’s happening at Al Mahabbah'**
  String get newsSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noNewsYet.
  ///
  /// In en, this message translates to:
  /// **'No news yet'**
  String get noNewsYet;

  /// No description provided for @noNewsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'School news and events will appear here.'**
  String get noNewsYetSubtitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @schoolNews.
  ///
  /// In en, this message translates to:
  /// **'School news'**
  String get schoolNews;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’re happy to hear from you'**
  String get contactSubtitle;

  /// No description provided for @ourSchool.
  ///
  /// In en, this message translates to:
  /// **'Our school'**
  String get ourSchool;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @callOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Call or email'**
  String get callOrEmail;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @admission.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get admission;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get followUs;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open this link'**
  String get couldNotOpenLink;

  /// No description provided for @appliedThroughWebsite.
  ///
  /// In en, this message translates to:
  /// **'Applied through our website?'**
  String get appliedThroughWebsite;

  /// No description provided for @confirmationEmailNote.
  ///
  /// In en, this message translates to:
  /// **'You should receive a confirmation email. If it doesn’t arrive within 24 hours, check your Spam folder or message the school’s official page.'**
  String get confirmationEmailNote;

  /// No description provided for @otherLanguage.
  ///
  /// In en, this message translates to:
  /// **'عربي'**
  String get otherLanguage;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parents, log in to follow your child’s school day.'**
  String get loginSubtitle;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email or mobile number'**
  String get emailOrMobile;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'parent@email.com'**
  String get emailHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @newParent.
  ///
  /// In en, this message translates to:
  /// **'New parent?'**
  String get newParent;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parent account — follow your children’s school day.'**
  String get registerSubtitle;

  /// No description provided for @parentFullName.
  ///
  /// In en, this message translates to:
  /// **'Parent’s full name'**
  String get parentFullName;

  /// No description provided for @asOnNationalId.
  ///
  /// In en, this message translates to:
  /// **'As on your national ID'**
  String get asOnNationalId;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10 1234 5678'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @agreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreePrefix;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @agreeAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get agreeAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyYourNumber;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code by SMS to '**
  String get otpSentTo;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @didntGetIt.
  ///
  /// In en, this message translates to:
  /// **'Didn’t get it?'**
  String get didntGetIt;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @wrongNumber.
  ///
  /// In en, this message translates to:
  /// **'Wrong number?'**
  String get wrongNumber;

  /// No description provided for @changeIt.
  ///
  /// In en, this message translates to:
  /// **'Change it'**
  String get changeIt;

  /// No description provided for @lastStep.
  ///
  /// In en, this message translates to:
  /// **'Last step'**
  String get lastStep;

  /// No description provided for @addYourChildren.
  ///
  /// In en, this message translates to:
  /// **'Add your children'**
  String get addYourChildren;

  /// No description provided for @addChildrenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link each child with their national ID number. You can add more than one.'**
  String get addChildrenSubtitle;

  /// No description provided for @childNationalId.
  ///
  /// In en, this message translates to:
  /// **'Child’s national ID'**
  String get childNationalId;

  /// No description provided for @nationalIdDigitsHint.
  ///
  /// In en, this message translates to:
  /// **'14-digit number'**
  String get nationalIdDigitsHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @nationalIdMatchNote.
  ///
  /// In en, this message translates to:
  /// **'We match it with the school records to find your child.'**
  String get nationalIdMatchNote;

  /// No description provided for @yourChildren.
  ///
  /// In en, this message translates to:
  /// **'Your children'**
  String get yourChildren;

  /// No description provided for @childrenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 child} other{{count} children}}'**
  String childrenCount(int count);

  /// No description provided for @childIdTail.
  ///
  /// In en, this message translates to:
  /// **'ID ••••{tail}'**
  String childIdTail(String tail);

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @removeChild.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeChild(String name);

  /// No description provided for @noChildrenYet.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildrenYet;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @schoolChat.
  ///
  /// In en, this message translates to:
  /// **'School chat'**
  String get schoolChat;

  /// No description provided for @newCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String newCount(int count);

  /// No description provided for @daysPresentIn.
  ///
  /// In en, this message translates to:
  /// **'days present in {month}'**
  String daysPresentIn(String month);

  /// No description provided for @ofTheYearPaid.
  ///
  /// In en, this message translates to:
  /// **'of the year paid'**
  String get ofTheYearPaid;

  /// No description provided for @needsYourAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get needsYourAttention;

  /// No description provided for @chatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get chatGeneral;

  /// No description provided for @chatPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get chatPrivate;

  /// No description provided for @chatPrivateOnlyYou.
  ///
  /// In en, this message translates to:
  /// **'Private · only you see it'**
  String get chatPrivateOnlyYou;

  /// No description provided for @youReplied.
  ///
  /// In en, this message translates to:
  /// **'You replied'**
  String get youReplied;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @chatReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Reply by choosing one of the options on each message'**
  String get chatReplyHint;

  /// No description provided for @term1.
  ///
  /// In en, this message translates to:
  /// **'Term 1'**
  String get term1;

  /// No description provided for @term2Soon.
  ///
  /// In en, this message translates to:
  /// **'Term 2 · Soon'**
  String get term2Soon;

  /// No description provided for @term1Average.
  ///
  /// In en, this message translates to:
  /// **'Term 1 average'**
  String get term1Average;

  /// No description provided for @reportCardPdf.
  ///
  /// In en, this message translates to:
  /// **'Report card (PDF)'**
  String get reportCardPdf;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @teachersNote.
  ///
  /// In en, this message translates to:
  /// **'Teacher’s note'**
  String get teachersNote;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @officialHoliday.
  ///
  /// In en, this message translates to:
  /// **'Official holiday'**
  String get officialHoliday;

  /// No description provided for @friSatOff.
  ///
  /// In en, this message translates to:
  /// **'Fri & Sat off'**
  String get friSatOff;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @schoolYear.
  ///
  /// In en, this message translates to:
  /// **'School year {years}'**
  String schoolYear(String years);

  /// No description provided for @percentPaid.
  ///
  /// In en, this message translates to:
  /// **'{percent} paid'**
  String percentPaid(String percent);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String paidAmount(String amount);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String totalAmount(String amount);

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @egpAmount.
  ///
  /// In en, this message translates to:
  /// **'EGP {amount}'**
  String egpAmount(String amount);

  /// No description provided for @allFeesPaid.
  ///
  /// In en, this message translates to:
  /// **'All fees paid'**
  String get allFeesPaid;

  /// No description provided for @installments.
  ///
  /// In en, this message translates to:
  /// **'Installments'**
  String get installments;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @myChildren.
  ///
  /// In en, this message translates to:
  /// **'My children'**
  String get myChildren;

  /// No description provided for @addAChild.
  ///
  /// In en, this message translates to:
  /// **'Add a child'**
  String get addAChild;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chatNotifications.
  ///
  /// In en, this message translates to:
  /// **'Chat notifications'**
  String get chatNotifications;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @contactTheSchool.
  ///
  /// In en, this message translates to:
  /// **'Contact the school'**
  String get contactTheSchool;

  /// No description provided for @aboutSchool.
  ///
  /// In en, this message translates to:
  /// **'About Al Mahabbah'**
  String get aboutSchool;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allParents.
  ///
  /// In en, this message translates to:
  /// **'All parents'**
  String get allParents;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @sendUsAMessage.
  ///
  /// In en, this message translates to:
  /// **'Send us a message'**
  String get sendUsAMessage;

  /// No description provided for @writeToUs.
  ///
  /// In en, this message translates to:
  /// **'Write to us'**
  String get writeToUs;

  /// No description provided for @sendMessageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll get back to you as soon as we can'**
  String get sendMessageSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get lastNameHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @educationType.
  ///
  /// In en, this message translates to:
  /// **'Education type'**
  String get educationType;

  /// No description provided for @chooseEducationType.
  ///
  /// In en, this message translates to:
  /// **'Choose education type'**
  String get chooseEducationType;

  /// No description provided for @schoolStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get schoolStage;

  /// No description provided for @chooseStage.
  ///
  /// In en, this message translates to:
  /// **'Choose stage'**
  String get chooseStage;

  /// No description provided for @educationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get educationLanguage;

  /// No description provided for @stageBabyClass.
  ///
  /// In en, this message translates to:
  /// **'Baby Class'**
  String get stageBabyClass;

  /// No description provided for @stageKg1.
  ///
  /// In en, this message translates to:
  /// **'KG1'**
  String get stageKg1;

  /// No description provided for @stageKg2.
  ///
  /// In en, this message translates to:
  /// **'KG2'**
  String get stageKg2;

  /// No description provided for @stagePrimary1.
  ///
  /// In en, this message translates to:
  /// **'First Primary'**
  String get stagePrimary1;

  /// No description provided for @stagePrimary2.
  ///
  /// In en, this message translates to:
  /// **'Second Primary'**
  String get stagePrimary2;

  /// No description provided for @stagePrimary3.
  ///
  /// In en, this message translates to:
  /// **'Third Primary'**
  String get stagePrimary3;

  /// No description provided for @stagePrimary4.
  ///
  /// In en, this message translates to:
  /// **'Fourth Primary'**
  String get stagePrimary4;

  /// No description provided for @stagePrimary5.
  ///
  /// In en, this message translates to:
  /// **'Fifth Primary'**
  String get stagePrimary5;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get yourMessage;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message here…'**
  String get messageHint;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @checkHighlightedFields.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get checkHighlightedFields;

  /// No description provided for @messageSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Message sent!'**
  String get messageSentTitle;

  /// No description provided for @messageSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you! The school will get back to you soon.'**
  String get messageSentSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
