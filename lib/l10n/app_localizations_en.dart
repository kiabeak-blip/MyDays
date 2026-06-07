// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyDays';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navMembers => 'Members';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMyTasks => 'My Tasks';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get recurringTasks => 'Recurring Tasks';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get tasks => 'Tasks';

  @override
  String get noTasks => 'No tasks';

  @override
  String noTasksForMember(String name) {
    return 'No tasks for $name today';
  }

  @override
  String get enjoyWeekend => 'No tasks — enjoy the weekend!';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get newTask => 'New Task';

  @override
  String get duplicateTask => 'Duplicate Task';

  @override
  String get duplicateTaskSub => 'Copy with new member/date';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteTaskConfirm => 'This cannot be undone.';

  @override
  String get applyChangesTo => 'Apply changes to…';

  @override
  String get applyChangesDesc =>
      'This is a recurring task. Do you want to update all occurrences, or only today and future dates?';

  @override
  String get allOccurrences => 'All occurrences';

  @override
  String get todayAndFuture => 'Today & future';

  @override
  String get taskTitleLabel => 'Task title *';

  @override
  String get taskTitleValidation => 'Please enter a title';

  @override
  String get descriptionOptional => 'Short description (optional)';

  @override
  String get checklist => 'Checklist';

  @override
  String get addStep => '+ Add step';

  @override
  String get checklistHint =>
      'Add steps for a young child to follow one by one';

  @override
  String get stepDescription => 'Step description…';

  @override
  String stepsDone(int done, int total) {
    return '$done/$total steps done';
  }

  @override
  String steps(int done, int total) {
    return '$done / $total steps';
  }

  @override
  String get repeats => 'Repeats';

  @override
  String get oneTime => 'One-time';

  @override
  String get daily => 'Daily';

  @override
  String get altDay => 'Alt Day';

  @override
  String get monFri => 'Mon – Fri';

  @override
  String get weekly => 'Weekly';

  @override
  String get startsFrom => 'Starts from';

  @override
  String get selectDays => 'Select days';

  @override
  String get tapToSelectDays => 'Tap to select specific days';

  @override
  String daysSelected(int count) {
    return '$count day selected';
  }

  @override
  String get assignToMembers => 'Assign to family members';

  @override
  String get noMembersYet =>
      'No family members yet — add them from the Members tab.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'Don\'t have an account? Register';

  @override
  String get familyName => 'Family name';

  @override
  String get createFamily => 'Create Family';

  @override
  String get joinFamily => 'Join Family';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get joinWithCode => 'Join with code';

  @override
  String get members => 'Members';

  @override
  String get addMember => 'Add Member';

  @override
  String get editMember => 'Edit Member';

  @override
  String get removeMember => 'Remove member?';

  @override
  String removeMemberConfirm(String name) {
    return '$name will be removed from all tasks. This cannot be undone.';
  }

  @override
  String get nameLabel => 'Name *';

  @override
  String get nameValidation => 'Please enter a name';

  @override
  String get role => 'Role';

  @override
  String get childRole => 'Child';

  @override
  String get parentRole => 'Parent';

  @override
  String get colour => 'Colour';

  @override
  String get avatar => 'Choose avatar';

  @override
  String doneToday(int done, int total) {
    return '$done / $total done today';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get themeColour => 'Theme colour';

  @override
  String get memberColours => 'Member colours';

  @override
  String get familySettings => 'Family';

  @override
  String get allowChildAddTasks => 'Allow children to add tasks';

  @override
  String get inviteMembers => 'Invite members';

  @override
  String get inviteCode2 => 'Invite Code';

  @override
  String get signOut => 'Sign out';

  @override
  String get assistant => 'Assistant';

  @override
  String get assistantGreeting =>
      'Hi! I\'m your family assistant 👋 I can help you manage tasks, check schedules, and create new tasks. What would you like to do?';

  @override
  String get setApiKey => 'Set API key';

  @override
  String get apiKeyTitle => 'Anthropic API Key';

  @override
  String get apiKeyDesc =>
      'Enter your Claude API key from console.anthropic.com. It\'s stored only on this device.';

  @override
  String get apiKeyHint => 'sk-ant-…';

  @override
  String get addApiKeyBanner =>
      'Add your Claude API key to enable the assistant.';

  @override
  String get askMeAnything => 'Ask me anything…';

  @override
  String get setApiKeyToStart => 'Set your API key to start';

  @override
  String get weekView => 'Week view';

  @override
  String get monthView => 'Month view';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get addTaskBtn => '+ Add task';

  @override
  String get addRecurring => '+ Recurring';

  @override
  String get tapIconToAdd => 'Tap the box to add an icon';

  @override
  String get noActionsAvailable => 'No actions available';

  @override
  String get askParentToEdit => 'Ask a parent to edit or delete tasks';
}
