import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('am'),
    Locale('ar'),
    Locale('en'),
    Locale('sv')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'MyDays'**
  String get appTitle;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get navMembers;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMyTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get navMyTasks;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @recurringTasks.
  ///
  /// In en, this message translates to:
  /// **'Recurring Tasks'**
  String get recurringTasks;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasks;

  /// No description provided for @noTasksForMember.
  ///
  /// In en, this message translates to:
  /// **'No tasks for {name} today'**
  String noTasksForMember(String name);

  /// No description provided for @enjoyWeekend.
  ///
  /// In en, this message translates to:
  /// **'No tasks — enjoy the weekend!'**
  String get enjoyWeekend;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @duplicateTask.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Task'**
  String get duplicateTask;

  /// No description provided for @duplicateTaskSub.
  ///
  /// In en, this message translates to:
  /// **'Copy with new member/date'**
  String get duplicateTaskSub;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteTaskConfirm;

  /// No description provided for @applyChangesTo.
  ///
  /// In en, this message translates to:
  /// **'Apply changes to…'**
  String get applyChangesTo;

  /// No description provided for @applyChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'This is a recurring task. Do you want to update all occurrences, or only today and future dates?'**
  String get applyChangesDesc;

  /// No description provided for @allOccurrences.
  ///
  /// In en, this message translates to:
  /// **'All occurrences'**
  String get allOccurrences;

  /// No description provided for @todayAndFuture.
  ///
  /// In en, this message translates to:
  /// **'Today & future'**
  String get todayAndFuture;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Task title *'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get taskTitleValidation;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Short description (optional)'**
  String get descriptionOptional;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'+ Add step'**
  String get addStep;

  /// No description provided for @checklistHint.
  ///
  /// In en, this message translates to:
  /// **'Add steps for a young child to follow one by one'**
  String get checklistHint;

  /// No description provided for @stepDescription.
  ///
  /// In en, this message translates to:
  /// **'Step description…'**
  String get stepDescription;

  /// No description provided for @stepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} steps done'**
  String stepsDone(int done, int total);

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} steps'**
  String steps(int done, int total);

  /// No description provided for @repeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeats;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get oneTime;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @altDay.
  ///
  /// In en, this message translates to:
  /// **'Alt Day'**
  String get altDay;

  /// No description provided for @monFri.
  ///
  /// In en, this message translates to:
  /// **'Mon – Fri'**
  String get monFri;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @startsFrom.
  ///
  /// In en, this message translates to:
  /// **'Starts from'**
  String get startsFrom;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select days'**
  String get selectDays;

  /// No description provided for @tapToSelectDays.
  ///
  /// In en, this message translates to:
  /// **'Tap to select specific days'**
  String get tapToSelectDays;

  /// No description provided for @daysSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} day selected'**
  String daysSelected(int count);

  /// No description provided for @assignToMembers.
  ///
  /// In en, this message translates to:
  /// **'Assign to family members'**
  String get assignToMembers;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No family members yet — add them from the Members tab.'**
  String get noMembersYet;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccount;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// No description provided for @createFamily.
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get createFamily;

  /// No description provided for @joinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get joinFamily;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from all tasks. This cannot be undone.'**
  String removeMemberConfirm(String name);

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @nameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameValidation;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @childRole.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get childRole;

  /// No description provided for @parentRole.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentRole;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get avatar;

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} done today'**
  String doneToday(int done, int total);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @themeColour.
  ///
  /// In en, this message translates to:
  /// **'Theme colour'**
  String get themeColour;

  /// No description provided for @memberColours.
  ///
  /// In en, this message translates to:
  /// **'Member colours'**
  String get memberColours;

  /// No description provided for @familySettings.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familySettings;

  /// No description provided for @allowChildAddTasks.
  ///
  /// In en, this message translates to:
  /// **'Allow children to add tasks'**
  String get allowChildAddTasks;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembers;

  /// No description provided for @inviteCode2.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCode2;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @assistantGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your family assistant 👋 I can help you manage tasks, check schedules, and create new tasks. What would you like to do?'**
  String get assistantGreeting;

  /// No description provided for @setApiKey.
  ///
  /// In en, this message translates to:
  /// **'Set API key'**
  String get setApiKey;

  /// No description provided for @apiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Anthropic API Key'**
  String get apiKeyTitle;

  /// No description provided for @apiKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your Claude API key from console.anthropic.com. It\'s stored only on this device.'**
  String get apiKeyDesc;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-ant-…'**
  String get apiKeyHint;

  /// No description provided for @addApiKeyBanner.
  ///
  /// In en, this message translates to:
  /// **'Add your Claude API key to enable the assistant.'**
  String get addApiKeyBanner;

  /// No description provided for @askMeAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything…'**
  String get askMeAnything;

  /// No description provided for @setApiKeyToStart.
  ///
  /// In en, this message translates to:
  /// **'Set your API key to start'**
  String get setApiKeyToStart;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week view'**
  String get weekView;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month view'**
  String get monthView;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @addTaskBtn.
  ///
  /// In en, this message translates to:
  /// **'+ Add task'**
  String get addTaskBtn;

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'+ Recurring'**
  String get addRecurring;

  /// No description provided for @tapIconToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap the box to add an icon'**
  String get tapIconToAdd;

  /// No description provided for @noActionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No actions available'**
  String get noActionsAvailable;

  /// No description provided for @askParentToEdit.
  ///
  /// In en, this message translates to:
  /// **'Ask a parent to edit or delete tasks'**
  String get askParentToEdit;
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
      <String>['am', 'ar', 'en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
