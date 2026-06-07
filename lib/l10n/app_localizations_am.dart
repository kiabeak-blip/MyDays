// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'MyDays';

  @override
  String get navCalendar => 'የቀን መቁጠሪያ';

  @override
  String get navMembers => 'ቤተሰብ';

  @override
  String get navAssistant => 'ረዳት';

  @override
  String get navSettings => 'ቅንብሮች';

  @override
  String get navMyTasks => 'የእኔ ተግባሮች';

  @override
  String get today => 'ዛሬ';

  @override
  String get yesterday => 'ትናንት';

  @override
  String get tomorrow => 'ነገ';

  @override
  String get recurringTasks => 'ተደጋጋሚ ተግባሮች';

  @override
  String get scheduled => 'የተቀመጡ';

  @override
  String get tasks => 'ተግባሮች';

  @override
  String get noTasks => 'ምንም ተግባሮች የሉም';

  @override
  String noTasksForMember(String name) {
    return 'ዛሬ ለ$name ምንም ተግባሮች የሉም';
  }

  @override
  String get enjoyWeekend => 'ምንም ተግባሮች የሉም — ቀናውን ይደሰቱ!';

  @override
  String get addTask => 'ተግባር ጨምር';

  @override
  String get editTask => 'ተግባር አስተካክል';

  @override
  String get newTask => 'አዲስ ተግባር';

  @override
  String get duplicateTask => 'ተግባር ቅዳ';

  @override
  String get duplicateTaskSub => 'በአዲስ አባል/ቀን ቅዳ';

  @override
  String get deleteTask => 'ተግባር ሰርዝ';

  @override
  String get deleteTaskConfirm => 'ይህ ሊቀለበስ አይችልም።';

  @override
  String get applyChangesTo => 'ለውጦችን ይተግብሩ…';

  @override
  String get applyChangesDesc =>
      'ይህ ተደጋጋሚ ተግባር ነው። ሁሉንም ክስተቶች ማዘመን ይፈልጋሉ፣ ወይስ ዛሬ እና ወደፊት ያሉ ቀናት ብቻ?';

  @override
  String get allOccurrences => 'ሁሉም ክስተቶች';

  @override
  String get todayAndFuture => 'ዛሬ እና ወደፊት';

  @override
  String get taskTitleLabel => 'የተግባር ርዕስ *';

  @override
  String get taskTitleValidation => 'እባክዎ ርዕስ ያስገቡ';

  @override
  String get descriptionOptional => 'አጭር መግለጫ (አማራጭ)';

  @override
  String get checklist => 'የቼክ ዝርዝር';

  @override
  String get addStep => '+ ደረጃ ጨምር';

  @override
  String get checklistHint => 'ልጆች ሊከተሏቸው የሚችሉ ደረጃዎችን ያስገቡ';

  @override
  String get stepDescription => 'የደረጃ መግለጫ…';

  @override
  String stepsDone(int done, int total) {
    return '$done/$total ደረጃዎች ተጠናቅቀዋል';
  }

  @override
  String steps(int done, int total) {
    return '$done / $total ደረጃዎች';
  }

  @override
  String get repeats => 'ድጋሚ';

  @override
  String get oneTime => 'አንድ ጊዜ';

  @override
  String get daily => 'በየቀኑ';

  @override
  String get altDay => 'ቀን 置ተን ቀን';

  @override
  String get monFri => 'ሰኞ – ዓርብ';

  @override
  String get weekly => 'በሳምንት';

  @override
  String get startsFrom => 'ይጀምራል';

  @override
  String get selectDays => 'ቀናት ምረጥ';

  @override
  String get tapToSelectDays => 'ልዩ ቀናት ለመምረጥ ይጫኑ';

  @override
  String daysSelected(int count) {
    return '$count ቀን ተመርጧል';
  }

  @override
  String get assignToMembers => 'ለቤተሰብ አባላት ምደባ';

  @override
  String get noMembersYet => 'እስካሁን ምንም የቤተሰብ አባላት የሉም — ከቤተሰብ ትር ያስገቡ።';

  @override
  String get saveChanges => 'ለውጦች ያስቀምጡ';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get delete => 'አስወግድ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get edit => 'አስተካክል';

  @override
  String get add => 'ጨምር';

  @override
  String get remove => 'አስወጣ';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get signIn => 'ግባ';

  @override
  String get createAccount => 'ምዝገባ';

  @override
  String get emailLabel => 'ኢሜይል';

  @override
  String get passwordLabel => 'የይለፍ ቃል';

  @override
  String get signInWithGoogle => 'በGoogle ግባ';

  @override
  String get forgotPassword => 'የይለፍ ቃል ረሳህ?';

  @override
  String get sendResetLink => 'ማስተካከያ ማገናኛ ላክ';

  @override
  String get alreadyHaveAccount => 'መለያ አለዎ? ይግቡ';

  @override
  String get noAccount => 'መለያ የለዎትም? ይመዝገቡ';

  @override
  String get familyName => 'የቤተሰብ ስም';

  @override
  String get createFamily => 'ቤተሰብ ፍጠር';

  @override
  String get joinFamily => 'ወደ ቤተሰብ ተቀላቀል';

  @override
  String get inviteCode => 'የጥሪ ኮድ';

  @override
  String get joinWithCode => 'በኮድ ተቀላቀል';

  @override
  String get members => 'ቤተሰብ';

  @override
  String get addMember => 'ጨምር';

  @override
  String get editMember => 'አባል አስተካክል';

  @override
  String get removeMember => 'አባል ያስወጡ?';

  @override
  String removeMemberConfirm(String name) {
    return '$name ከሁሉም ተግባሮች ይወጣሉ። ይህ ሊቀለበስ አይችልም።';
  }

  @override
  String get nameLabel => 'ስም *';

  @override
  String get nameValidation => 'እባክዎ ስም ያስገቡ';

  @override
  String get role => 'ሚና';

  @override
  String get childRole => 'ልጅ';

  @override
  String get parentRole => 'ወላጅ';

  @override
  String get colour => 'ቀለም';

  @override
  String get avatar => 'አቀራረብ ምረጥ';

  @override
  String doneToday(int done, int total) {
    return '$done / $total ዛሬ ተጠናቅቋል';
  }

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get appearance => 'መልክ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get darkMode => 'ጨለማ ሁነታ';

  @override
  String get lightMode => 'ብርሃን ሁነታ';

  @override
  String get themeColour => 'የጭብጥ ቀለም';

  @override
  String get memberColours => 'የአባሉ ቀለሞች';

  @override
  String get familySettings => 'ቤተሰብ';

  @override
  String get allowChildAddTasks => 'ልጆች ተግባሮችን እንዲጨምሩ ፍቀድ';

  @override
  String get inviteMembers => 'አባላትን ጋብዝ';

  @override
  String get inviteCode2 => 'የጥሪ ኮድ';

  @override
  String get signOut => 'ውጣ';

  @override
  String get assistant => 'ረዳት';

  @override
  String get assistantGreeting =>
      'ሰላም! እኔ የቤተሰብ ረዳትዎ ነኝ 👋 ተግባሮችን ለማስተዳደር እና አዲስ ለመፍጠር ልረዳዎ እችላለሁ። ምን ማድረግ ይፈልጋሉ?';

  @override
  String get setApiKey => 'API ቁልፍ አዘጋጅ';

  @override
  String get apiKeyTitle => 'Anthropic API ቁልፍ';

  @override
  String get apiKeyDesc =>
      'Claude API ቁልፍዎን ከ console.anthropic.com ያስገቡ። በዚህ መሣሪያ ብቻ ይቀመጣል።';

  @override
  String get apiKeyHint => 'sk-ant-…';

  @override
  String get addApiKeyBanner => 'ረዳቱን ለማግኘት Claude API ቁልፍዎን ያስገቡ።';

  @override
  String get askMeAnything => 'ማንኛውንም ጥያቄ ይጠይቁ…';

  @override
  String get setApiKeyToStart => 'ለመጀመር API ቁልፍ ያዘጋጁ';

  @override
  String get weekView => 'የሳምንት እይታ';

  @override
  String get monthView => 'የወር እይታ';

  @override
  String get week => 'ሳምንት';

  @override
  String get month => 'ወር';

  @override
  String get addTaskBtn => '+ ተግባር ጨምር';

  @override
  String get addRecurring => '+ ተደጋጋሚ';

  @override
  String get tapIconToAdd => 'አዶ ለማከል ሳጥኑን ይጫኑ';

  @override
  String get noActionsAvailable => 'ምንም ተግባሮች አይገኙም';

  @override
  String get askParentToEdit => 'ወላጅ ይዘቶቹን እንዲያስተካክሉ ወይም እንዲሰርዙ ይጠይቁ';
}
