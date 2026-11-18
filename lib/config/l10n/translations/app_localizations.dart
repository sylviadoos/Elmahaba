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
  /// **'No internet connection. Check your connection and try again.'**
  String get noInternet;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'The request to the server was cancelled'**
  String get cancelled;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknown;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again in a few minutes.'**
  String get serverError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpectedError;

  /// No description provided for @expiredToken.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please log in again'**
  String get expiredToken;

  /// No description provided for @accountWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Your account is no longer available because the student is no longer enrolled at the school. Please contact the school.'**
  String get accountWithdrawn;

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

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your mobile number and password to log in again.'**
  String get logOutMessage;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account, your linked children and your settings will be deleted. The school keeps your chat and complaint records.'**
  String get deleteAccountMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted'**
  String get accountDeleted;

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

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

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
  /// **'Parents, log in with the mobile number you gave the school to follow your child’s school day.'**
  String get loginSubtitle;

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
  /// **'Parent account — sign up with the mobile number you gave the school to follow your children’s school day.'**
  String get registerSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10 1234 5678'**
  String get phoneHint;

  /// No description provided for @fullPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'010 1234 5678'**
  String get fullPhoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Type the password again'**
  String get confirmPasswordHint;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this number. Please log in.'**
  String get accountAlreadyExists;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created. Please log in.'**
  String get accountCreated;

  /// No description provided for @phoneVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify your number. Please try again.'**
  String get phoneVerificationFailed;

  /// No description provided for @otpWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code isn’t right. Check the latest SMS and try again.'**
  String get otpWrongCode;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Please request a new one.'**
  String get otpExpired;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a few minutes, then try again.'**
  String get tooManyAttempts;

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

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the mobile number on your account and we’ll send you a code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @useRegisteredNumber.
  ///
  /// In en, this message translates to:
  /// **'Use the same number you registered with.'**
  String get useRegisteredNumber;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @rememberedIt.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get rememberedIt;

  /// No description provided for @enterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterTheCode;

  /// No description provided for @resetCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'To reset your password, enter the 6-digit code we sent to '**
  String get resetCodeSentTo;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get setNewPassword;

  /// No description provided for @setNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password you don’t use anywhere else.'**
  String get setNewPasswordSubtitle;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @typeItAgain.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get typeItAgain;

  /// No description provided for @ruleEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get ruleEightCharacters;

  /// No description provided for @ruleHasLetter.
  ///
  /// In en, this message translates to:
  /// **'Contains a letter'**
  String get ruleHasLetter;

  /// No description provided for @ruleHasNumber.
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get ruleHasNumber;

  /// No description provided for @rulePasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Both passwords match'**
  String get rulePasswordsMatch;

  /// No description provided for @saveNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get saveNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @logInWithNewPassword.
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your new password.'**
  String get logInWithNewPassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get backToLogin;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your current password first.'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @forgotCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your current password?'**
  String get forgotCurrentPassword;

  /// No description provided for @ruleNewPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Both new passwords match'**
  String get ruleNewPasswordsMatch;

  /// No description provided for @ruleDifferentFromCurrent.
  ///
  /// In en, this message translates to:
  /// **'Different from the current password'**
  String get ruleDifferentFromCurrent;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @useNewPasswordNextTime.
  ///
  /// In en, this message translates to:
  /// **'Next time you log in, use your new password.'**
  String get useNewPasswordNextTime;

  /// No description provided for @backToSettings.
  ///
  /// In en, this message translates to:
  /// **'Back to settings'**
  String get backToSettings;

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

  /// No description provided for @childLinked.
  ///
  /// In en, this message translates to:
  /// **'Your child has been linked to your account.'**
  String get childLinked;

  /// No description provided for @linkCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to: '**
  String get linkCodeSentTo;

  /// No description provided for @codeAttemptsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tries left} =1{1 try left} other{{count} tries left}}'**
  String codeAttemptsLeft(int count);

  /// No description provided for @childLinkPending.
  ///
  /// In en, this message translates to:
  /// **'Request sent to the school. You’ll see your child once the school confirms it.'**
  String get childLinkPending;

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

  /// No description provided for @needsYourAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get needsYourAttention;

  /// No description provided for @attendanceNotTaken.
  ///
  /// In en, this message translates to:
  /// **'Attendance not taken yet'**
  String get attendanceNotTaken;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get noResultsYet;

  /// No description provided for @noFeesYet.
  ///
  /// In en, this message translates to:
  /// **'No fees yet'**
  String get noFeesYet;

  /// No description provided for @overdueInstallmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue installment} other{{count} overdue installments}}'**
  String overdueInstallmentsCount(int count);

  /// No description provided for @feesDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String feesDueOn(String date);

  /// No description provided for @feesOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'Overdue since {date}'**
  String feesOverdueSince(String date);

  /// No description provided for @daysPresent.
  ///
  /// In en, this message translates to:
  /// **'Days present'**
  String get daysPresent;

  /// No description provided for @messagesAndNotices.
  ///
  /// In en, this message translates to:
  /// **'Messages {messages} · Notices {notices}'**
  String messagesAndNotices(int messages, int notices);

  /// No description provided for @chatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get chatGeneral;

  /// No description provided for @chatNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get chatNew;

  /// No description provided for @chatRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get chatRead;

  /// No description provided for @chatPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get chatPrivate;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @noMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Messages from the school, and the ones you send, show here.'**
  String get noMessagesHint;

  /// No description provided for @olderMessagesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load older messages.'**
  String get olderMessagesFailed;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replyingTo;

  /// No description provided for @inReplyTo.
  ///
  /// In en, this message translates to:
  /// **'In reply to'**
  String get inReplyTo;

  /// No description provided for @cancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get cancelReply;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get deletedMessage;

  /// No description provided for @earlierMessage.
  ///
  /// In en, this message translates to:
  /// **'An earlier message'**
  String get earlierMessage;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @chatCantSend.
  ///
  /// In en, this message translates to:
  /// **'You can message the school while one of your children is enrolled.'**
  String get chatCantSend;

  /// No description provided for @chatClosed.
  ///
  /// In en, this message translates to:
  /// **'The chat is closed for now. You can still read messages.'**
  String get chatClosed;

  /// No description provided for @messageAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get messageAbout;

  /// No description provided for @viewAttendance.
  ///
  /// In en, this message translates to:
  /// **'View attendance'**
  String get viewAttendance;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View results'**
  String get viewResults;

  /// No description provided for @viewFees.
  ///
  /// In en, this message translates to:
  /// **'View fees'**
  String get viewFees;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String publishedOn(String date);

  /// No description provided for @finalResult.
  ///
  /// In en, this message translates to:
  /// **'Final result'**
  String get finalResult;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @countedInFinalResult.
  ///
  /// In en, this message translates to:
  /// **'Counted in the final result'**
  String get countedInFinalResult;

  /// No description provided for @otherSubjects.
  ///
  /// In en, this message translates to:
  /// **'Other subjects'**
  String get otherSubjects;

  /// No description provided for @notCountedInFinalResult.
  ///
  /// In en, this message translates to:
  /// **'Not counted in the final result'**
  String get notCountedInFinalResult;

  /// No description provided for @highLevel.
  ///
  /// In en, this message translates to:
  /// **'High level'**
  String get highLevel;

  /// No description provided for @highLevelNote.
  ///
  /// In en, this message translates to:
  /// **'Extra level, not counted in the final result'**
  String get highLevelNote;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @downloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Download certificate (PDF)'**
  String get downloadCertificate;

  /// No description provided for @certificateSaved.
  ///
  /// In en, this message translates to:
  /// **'Certificate saved'**
  String get certificateSaved;

  /// No description provided for @certificateNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the certificate. Try again.'**
  String get certificateNotSaved;

  /// No description provided for @certificateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t make the certificate. Try again.'**
  String get certificateFailed;

  /// No description provided for @monthlyResults.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyResults;

  /// No description provided for @latestResult.
  ///
  /// In en, this message translates to:
  /// **'Latest result'**
  String get latestResult;

  /// No description provided for @classRank.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String classRank(int rank);

  /// No description provided for @assessmentInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial'**
  String get assessmentInitial;

  /// No description provided for @assessmentFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get assessmentFinal;

  /// No description provided for @assessmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get assessmentStatus;

  /// No description provided for @gradeExceeds.
  ///
  /// In en, this message translates to:
  /// **'Exceeds Expectations'**
  String get gradeExceeds;

  /// No description provided for @gradeMeets.
  ///
  /// In en, this message translates to:
  /// **'Meets Expectations'**
  String get gradeMeets;

  /// No description provided for @gradePartiallyMeets.
  ///
  /// In en, this message translates to:
  /// **'Partially Meets Expectations'**
  String get gradePartiallyMeets;

  /// No description provided for @gradeBelow.
  ///
  /// In en, this message translates to:
  /// **'Below Expectations'**
  String get gradeBelow;

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

  /// No description provided for @arrivedLate.
  ///
  /// In en, this message translates to:
  /// **'Arrived late'**
  String get arrivedLate;

  /// No description provided for @officialHoliday.
  ///
  /// In en, this message translates to:
  /// **'Official holiday'**
  String get officialHoliday;

  /// No description provided for @friSatOff.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
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

  /// No description provided for @attendanceWord.
  ///
  /// In en, this message translates to:
  /// **'attendance'**
  String get attendanceWord;

  /// No description provided for @attendedOfDays.
  ///
  /// In en, this message translates to:
  /// **'{attended} of {total} school days'**
  String attendedOfDays(int attended, int total);

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @excusedOrMedical.
  ///
  /// In en, this message translates to:
  /// **'Excused / medical'**
  String get excusedOrMedical;

  /// No description provided for @excusedAbsence.
  ///
  /// In en, this message translates to:
  /// **'Excused absence'**
  String get excusedAbsence;

  /// No description provided for @reasonIs.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String reasonIs(String reason);

  /// No description provided for @noReasonGiven.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get noReasonGiven;

  /// No description provided for @holidayNoSchool.
  ///
  /// In en, this message translates to:
  /// **'{name} · no school'**
  String holidayNoSchool(String name);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @noAbsencesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No absences or late days this month.'**
  String get noAbsencesThisMonth;

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

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account {number}'**
  String accountNumber(String number);

  /// No description provided for @payFeesAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay fees · {amount}'**
  String payFeesAmount(String amount);

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @allParents.
  ///
  /// In en, this message translates to:
  /// **'All parents'**
  String get allParents;

  /// No description provided for @medicalExcuse.
  ///
  /// In en, this message translates to:
  /// **'Medical excuse'**
  String get medicalExcuse;

  /// No description provided for @submitExcuse.
  ///
  /// In en, this message translates to:
  /// **'Submit excuse'**
  String get submitExcuse;

  /// No description provided for @viewExcuse.
  ///
  /// In en, this message translates to:
  /// **'View excuse'**
  String get viewExcuse;

  /// No description provided for @excuseStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Medical excuse · {status}'**
  String excuseStatusLine(String status);

  /// No description provided for @excuseSubmitBy.
  ///
  /// In en, this message translates to:
  /// **'Excuse by {date}'**
  String excuseSubmitBy(String date);

  /// No description provided for @excuseUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get excuseUnderReview;

  /// No description provided for @excuseInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Information needed'**
  String get excuseInfoRequired;

  /// No description provided for @excuseAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get excuseAccepted;

  /// No description provided for @excuseRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get excuseRejected;

  /// No description provided for @excuseForAbsence.
  ///
  /// In en, this message translates to:
  /// **'For the absence on {date}'**
  String excuseForAbsence(String date);

  /// No description provided for @excuseSubmitUntil.
  ///
  /// In en, this message translates to:
  /// **'You can send it until {date}.'**
  String excuseSubmitUntil(String date);

  /// No description provided for @excuseNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get excuseNote;

  /// No description provided for @excuseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Doctor visit — fever'**
  String get excuseNoteHint;

  /// No description provided for @excuseDocuments.
  ///
  /// In en, this message translates to:
  /// **'Medical documents'**
  String get excuseDocuments;

  /// No description provided for @excuseDocumentsRules.
  ///
  /// In en, this message translates to:
  /// **'{types} · up to {megabytes} MB each · up to {count} files'**
  String excuseDocumentsRules(String types, int megabytes, int count);

  /// No description provided for @excuseDocumentRequired.
  ///
  /// In en, this message translates to:
  /// **'Attach at least one document.'**
  String get excuseDocumentRequired;

  /// No description provided for @excuseSent.
  ///
  /// In en, this message translates to:
  /// **'Your medical excuse has been sent.'**
  String get excuseSent;

  /// No description provided for @excuseSubmittedByOther.
  ///
  /// In en, this message translates to:
  /// **'Sent by the child\'s other parent'**
  String get excuseSubmittedByOther;

  /// No description provided for @excuseRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Why it was rejected'**
  String get excuseRejectionReason;

  /// No description provided for @excuseInformationRequest.
  ///
  /// In en, this message translates to:
  /// **'What the school needs'**
  String get excuseInformationRequest;

  /// No description provided for @excuseAcceptedNote.
  ///
  /// In en, this message translates to:
  /// **'The day now counts as medical leave.'**
  String get excuseAcceptedNote;

  /// No description provided for @addDocuments.
  ///
  /// In en, this message translates to:
  /// **'Add documents'**
  String get addDocuments;

  /// No description provided for @sendDocuments.
  ///
  /// In en, this message translates to:
  /// **'Send documents'**
  String get sendDocuments;

  /// No description provided for @documentsSent.
  ///
  /// In en, this message translates to:
  /// **'Documents sent. The school will review the excuse again.'**
  String get documentsSent;

  /// No description provided for @excuseHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get excuseHistory;

  /// No description provided for @excuseStepSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Excuse sent'**
  String get excuseStepSubmitted;

  /// No description provided for @excuseStepInfoRequested.
  ///
  /// In en, this message translates to:
  /// **'The school asked for more'**
  String get excuseStepInfoRequested;

  /// No description provided for @excuseStepDocumentsAdded.
  ///
  /// In en, this message translates to:
  /// **'Documents added'**
  String get excuseStepDocumentsAdded;

  /// No description provided for @excuseStepAccepted.
  ///
  /// In en, this message translates to:
  /// **'Excuse accepted'**
  String get excuseStepAccepted;

  /// No description provided for @excuseStepRejected.
  ///
  /// In en, this message translates to:
  /// **'Excuse rejected'**
  String get excuseStepRejected;

  /// No description provided for @byParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get byParent;

  /// No description provided for @bySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get bySchool;

  /// No description provided for @feeStatement.
  ///
  /// In en, this message translates to:
  /// **'Fee statement'**
  String get feeStatement;

  /// No description provided for @feeStatementSaved.
  ///
  /// In en, this message translates to:
  /// **'Fee statement saved'**
  String get feeStatementSaved;

  /// No description provided for @feeStatementNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the fee statement. Try again.'**
  String get feeStatementNotSaved;

  /// No description provided for @feeStatementFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t make the fee statement. Try again.'**
  String get feeStatementFailed;

  /// No description provided for @payFees.
  ///
  /// In en, this message translates to:
  /// **'Pay fees'**
  String get payFees;

  /// No description provided for @payFullAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay full amount'**
  String get payFullAmount;

  /// No description provided for @payInInstallments.
  ///
  /// In en, this message translates to:
  /// **'Pay in installments'**
  String get payInInstallments;

  /// No description provided for @amountPayableNow.
  ///
  /// In en, this message translates to:
  /// **'Amount payable now'**
  String get amountPayableNow;

  /// No description provided for @tickInstallments.
  ///
  /// In en, this message translates to:
  /// **'Tick the installments you want to pay'**
  String get tickInstallments;

  /// No description provided for @confirmOptionalFee.
  ///
  /// In en, this message translates to:
  /// **'Confirm Optional Fee'**
  String get confirmOptionalFee;

  /// No description provided for @confirmOptionalFeeMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to pay this fee?\n{fee} — {amount}'**
  String confirmOptionalFeeMessage(String fee, String amount);

  /// No description provided for @yesPay.
  ///
  /// In en, this message translates to:
  /// **'Yes, Pay'**
  String get yesPay;

  /// No description provided for @dropOptionalFee.
  ///
  /// In en, this message translates to:
  /// **'Remove Optional Fee'**
  String get dropOptionalFee;

  /// No description provided for @dropOptionalFeeMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {fee} from the fees?'**
  String dropOptionalFeeMessage(String fee);

  /// No description provided for @yesDrop.
  ///
  /// In en, this message translates to:
  /// **'Yes, Remove'**
  String get yesDrop;

  /// No description provided for @tickEarlierInstallmentsFirst.
  ///
  /// In en, this message translates to:
  /// **'To preview or download the statement, tick the earlier unpaid installments too.'**
  String get tickEarlierInstallmentsFirst;

  /// No description provided for @dueOnAccount.
  ///
  /// In en, this message translates to:
  /// **'Due {date} · Account {account}'**
  String dueOnAccount(String date, String account);

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @underSettlement.
  ///
  /// In en, this message translates to:
  /// **'Under settlement'**
  String get underSettlement;

  /// No description provided for @paymentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Payment in progress'**
  String get paymentInProgress;

  /// No description provided for @payOnline.
  ///
  /// In en, this message translates to:
  /// **'Pay online'**
  String get payOnline;

  /// No description provided for @payOnlineAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay online · {amount}'**
  String payOnlineAmount(String amount);

  /// No description provided for @paymentBySkoolex.
  ///
  /// In en, this message translates to:
  /// **'Payment is processed through the Skoolex school system'**
  String get paymentBySkoolex;

  /// No description provided for @paymentPageFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the payment page'**
  String get paymentPageFailed;

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

  /// No description provided for @chooseChild.
  ///
  /// In en, this message translates to:
  /// **'Choose a child'**
  String get chooseChild;

  /// No description provided for @allChildren.
  ///
  /// In en, this message translates to:
  /// **'All children'**
  String get allChildren;

  /// No description provided for @childDetails.
  ///
  /// In en, this message translates to:
  /// **'Child details'**
  String get childDetails;

  /// No description provided for @childStudentInfo.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get childStudentInfo;

  /// No description provided for @childSchoolInfo.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get childSchoolInfo;

  /// No description provided for @childContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get childContactInfo;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @studentCode.
  ///
  /// In en, this message translates to:
  /// **'Student code'**
  String get studentCode;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String yearsOld(int count);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @schoolClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get schoolClass;

  /// No description provided for @academicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic year'**
  String get academicYear;

  /// No description provided for @enrolledOn.
  ///
  /// In en, this message translates to:
  /// **'Enrolled on'**
  String get enrolledOn;

  /// No description provided for @previousSchool.
  ///
  /// In en, this message translates to:
  /// **'Previous school'**
  String get previousSchool;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @homePhone.
  ///
  /// In en, this message translates to:
  /// **'Home phone'**
  String get homePhone;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @childrenLinked.
  ///
  /// In en, this message translates to:
  /// **'{count} linked'**
  String childrenLinked(int count);

  /// No description provided for @linkAnotherChild.
  ///
  /// In en, this message translates to:
  /// **'Link another child'**
  String get linkAnotherChild;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationKindsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what rings your phone. Everything still shows in the app.'**
  String get notificationKindsHint;

  /// No description provided for @notificationsOffNote.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. Turn them on to choose which ones ring.'**
  String get notificationsOffNote;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @noAnnouncementsHint.
  ///
  /// In en, this message translates to:
  /// **'Announcements from the school show here.'**
  String get noAnnouncementsHint;

  /// No description provided for @announcementsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No announcements} =1{1 announcement} other{{count} announcements}}'**
  String announcementsCount(int count);

  /// No description provided for @announcementEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get announcementEnded;

  /// No description provided for @announcementUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String announcementUntil(String date);

  /// No description provided for @homework.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get homework;

  /// No description provided for @homeworkCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No homework} =1{1 homework} other{{count} homework}}'**
  String homeworkCount(int count);

  /// No description provided for @homeworkDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get homeworkDueSoon;

  /// No description provided for @homeworkUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeworkUpcoming;

  /// No description provided for @homeworkDueTodayFilter.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeworkDueTodayFilter;

  /// No description provided for @homeworkPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get homeworkPast;

  /// No description provided for @homeworkNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get homeworkNoDueDate;

  /// No description provided for @allSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get allSubjects;

  /// No description provided for @homeworkDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String homeworkDueOn(String date);

  /// No description provided for @homeworkDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeworkDueToday;

  /// No description provided for @homeworkWasDue.
  ///
  /// In en, this message translates to:
  /// **'Was due {date}'**
  String homeworkWasDue(String date);

  /// No description provided for @homeworkGiven.
  ///
  /// In en, this message translates to:
  /// **'Given {date}'**
  String homeworkGiven(String date);

  /// No description provided for @homeworkNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homeworkNew;

  /// No description provided for @noHomework.
  ///
  /// In en, this message translates to:
  /// **'No homework yet'**
  String get noHomework;

  /// No description provided for @noHomeworkHint.
  ///
  /// In en, this message translates to:
  /// **'Homework from the school shows here.'**
  String get noHomeworkHint;

  /// No description provided for @noHomeworkFiltered.
  ///
  /// In en, this message translates to:
  /// **'No homework here'**
  String get noHomeworkFiltered;

  /// No description provided for @noHomeworkFilteredHint.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or subject.'**
  String get noHomeworkFilteredHint;

  /// No description provided for @viewHomework.
  ///
  /// In en, this message translates to:
  /// **'View homework'**
  String get viewHomework;

  /// No description provided for @viewAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'View announcements'**
  String get viewAnnouncements;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

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

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @newComplaint.
  ///
  /// In en, this message translates to:
  /// **'New complaint'**
  String get newComplaint;

  /// No description provided for @complaintPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Only you and the school can see your complaint.'**
  String get complaintPrivacyNote;

  /// No description provided for @complaintCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get complaintCategory;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'The category field is required.'**
  String get categoryRequired;

  /// No description provided for @complaintAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get complaintAbout;

  /// No description provided for @complaintGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get complaintGeneral;

  /// No description provided for @complaintGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'Choose General if it isn’t about one child.'**
  String get complaintGeneralHint;

  /// No description provided for @complaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintDescription;

  /// No description provided for @complaintDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened, when and where'**
  String get complaintDescriptionHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'The description field is required.'**
  String get descriptionRequired;

  /// No description provided for @complaintAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get complaintAttachments;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optionalNote;

  /// No description provided for @addFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get addFile;

  /// No description provided for @attachmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} files'**
  String attachmentsCount(int count, int max);

  /// No description provided for @attachmentFormats.
  ///
  /// In en, this message translates to:
  /// **'Allowed formats: {types}.'**
  String attachmentFormats(String types);

  /// No description provided for @attachmentMaxFileSize.
  ///
  /// In en, this message translates to:
  /// **'Maximum file size: {megabytes} MB per file.'**
  String attachmentMaxFileSize(int megabytes);

  /// No description provided for @attachmentMaxTotalSize.
  ///
  /// In en, this message translates to:
  /// **'Maximum total size: {megabytes} MB.'**
  String attachmentMaxTotalSize(int megabytes);

  /// No description provided for @attachmentLimitsShort.
  ///
  /// In en, this message translates to:
  /// **'{types} · Max {megabytes} MB per file · {total} MB total'**
  String attachmentLimitsShort(String types, int megabytes, int total);

  /// No description provided for @attachmentsRoomLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You can add 1 more · Max {megabytes} MB each} other{You can add {count} more · Max {megabytes} MB each}}'**
  String attachmentsRoomLeft(int count, int megabytes);

  /// No description provided for @attachmentsSpaceLeft.
  ///
  /// In en, this message translates to:
  /// **'{left} MB left of {total} MB'**
  String attachmentsSpaceLeft(String left, int total);

  /// No description provided for @attachmentsMaxReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of attachments ({max} files).'**
  String attachmentsMaxReached(int max);

  /// No description provided for @attachmentsTotalFull.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used the full {total} MB. Remove a file to add another.'**
  String attachmentsTotalFull(int total);

  /// No description provided for @attachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Too large ({size} MB). Max size is {max} MB'**
  String attachmentTooLarge(String size, int max);

  /// No description provided for @attachmentTypeNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'File type not allowed. Allowed: {types}.'**
  String attachmentTypeNotAllowed(String types);

  /// No description provided for @attachmentOverTotal.
  ///
  /// In en, this message translates to:
  /// **'Over the {total} MB total. {left} MB left.'**
  String attachmentOverTotal(int total, String left);

  /// No description provided for @attachmentOverTotalFull.
  ///
  /// In en, this message translates to:
  /// **'Over the {total} MB total.'**
  String attachmentOverTotalFull(int total);

  /// No description provided for @attachmentRejected.
  ///
  /// In en, this message translates to:
  /// **'This file could not be accepted'**
  String get attachmentRejected;

  /// No description provided for @attachmentUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String attachmentUploading(int percent);

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo from the gallery'**
  String get attachPhoto;

  /// No description provided for @attachDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF or Word file'**
  String get attachDocument;

  /// No description provided for @couldNotOpenFiles.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open your photos or files. Please try again.'**
  String get couldNotOpenFiles;

  /// No description provided for @tooManyAttachments.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to {count} files.'**
  String tooManyAttachments(int count);

  /// No description provided for @attachmentNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed files are {types}, up to {megabytes} MB each.'**
  String attachmentNotAllowed(String types, int megabytes);

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeAttachment(String name);

  /// No description provided for @fileSizeKb.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String fileSizeKb(String size);

  /// No description provided for @fileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String fileSizeMb(String size);

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit complaint'**
  String get submitComplaint;

  /// No description provided for @complaintSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been submitted.'**
  String get complaintSubmitted;

  /// No description provided for @complaintReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get complaintReference;

  /// No description provided for @viewComplaint.
  ///
  /// In en, this message translates to:
  /// **'View complaint'**
  String get viewComplaint;

  /// No description provided for @backToComplaints.
  ///
  /// In en, this message translates to:
  /// **'Back to complaints'**
  String get backToComplaints;

  /// No description provided for @complaintsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 complaint} other{{count} complaints}}'**
  String complaintsCount(int count);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String openCount(int count);

  /// No description provided for @filterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get filterOpen;

  /// No description provided for @filterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get filterClosed;

  /// No description provided for @noComplaintsHere.
  ///
  /// In en, this message translates to:
  /// **'No complaints here'**
  String get noComplaintsHere;

  /// No description provided for @noComplaintsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complaints you submit will appear in this list.'**
  String get noComplaintsSubtitle;

  /// No description provided for @complaintsPageNote.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {lastPage} · {total} total'**
  String complaintsPageNote(int page, int lastPage, int total);

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String submittedOn(String date);

  /// No description provided for @lastUpdateOn.
  ///
  /// In en, this message translates to:
  /// **'Last update {date}'**
  String lastUpdateOn(String date);

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusUnderReview;

  /// No description provided for @statusAwaitingReply.
  ///
  /// In en, this message translates to:
  /// **'Awaiting your reply'**
  String get statusAwaitingReply;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @complaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get complaintDetails;

  /// No description provided for @submittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submittedAt;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdate;

  /// No description provided for @yourComplaint.
  ///
  /// In en, this message translates to:
  /// **'Your complaint'**
  String get yourComplaint;

  /// No description provided for @statusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status history'**
  String get statusHistory;

  /// No description provided for @complaintUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get complaintUpdates;

  /// No description provided for @schoolAdministration.
  ///
  /// In en, this message translates to:
  /// **'School administration'**
  String get schoolAdministration;

  /// No description provided for @schoolInitials.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get schoolInitials;

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tapToOpen;

  /// No description provided for @openInAnotherApp.
  ///
  /// In en, this message translates to:
  /// **'Open in another app'**
  String get openInAnotherApp;

  /// No description provided for @cantShowFile.
  ///
  /// In en, this message translates to:
  /// **'This file can’t be shown here.'**
  String get cantShowFile;

  /// No description provided for @checkingFile.
  ///
  /// In en, this message translates to:
  /// **'Checking file…'**
  String get checkingFile;

  /// No description provided for @addAReply.
  ///
  /// In en, this message translates to:
  /// **'Add a reply'**
  String get addAReply;

  /// No description provided for @replyHint.
  ///
  /// In en, this message translates to:
  /// **'Write more details for the school'**
  String get replyHint;

  /// No description provided for @replySent.
  ///
  /// In en, this message translates to:
  /// **'Your reply has been sent.'**
  String get replySent;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @sendReply.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get sendReply;

  /// No description provided for @complaintClosedNote.
  ///
  /// In en, this message translates to:
  /// **'This complaint is closed. You can submit a new complaint.'**
  String get complaintClosedNote;

  /// No description provided for @cantOpenFile.
  ///
  /// In en, this message translates to:
  /// **'There’s no app on this phone that opens this file.'**
  String get cantOpenFile;

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

  /// Under Log in while the number is locked; time counts down, e.g. 04:59.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts. Try again in {time}.'**
  String loginLockedFor(String time);

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

  /// No description provided for @appUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The parents app is paused by the school for now. Please try again later.'**
  String get appUnavailable;

  /// No description provided for @codeSendFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t send the code right now. Please try again in a moment.'**
  String get codeSendFailed;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'This mobile number doesn’t look right. Check it and try again.'**
  String get invalidPhoneNumber;
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
