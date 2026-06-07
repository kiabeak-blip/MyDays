// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'MyDays';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navMembers => 'Familj';

  @override
  String get navAssistant => 'Assistent';

  @override
  String get navSettings => 'Inställningar';

  @override
  String get navMyTasks => 'Mina uppgifter';

  @override
  String get today => 'Idag';

  @override
  String get yesterday => 'Igår';

  @override
  String get tomorrow => 'Imorgon';

  @override
  String get recurringTasks => 'Återkommande uppgifter';

  @override
  String get scheduled => 'Schemalagda';

  @override
  String get tasks => 'Uppgifter';

  @override
  String get noTasks => 'Inga uppgifter';

  @override
  String noTasksForMember(String name) {
    return 'Inga uppgifter för $name idag';
  }

  @override
  String get enjoyWeekend => 'Inga uppgifter — njut av helgen!';

  @override
  String get addTask => 'Lägg till uppgift';

  @override
  String get editTask => 'Redigera uppgift';

  @override
  String get newTask => 'Ny uppgift';

  @override
  String get duplicateTask => 'Duplicera uppgift';

  @override
  String get duplicateTaskSub => 'Kopiera med ny medlem/datum';

  @override
  String get deleteTask => 'Ta bort uppgift';

  @override
  String get deleteTaskConfirm => 'Detta kan inte ångras.';

  @override
  String get applyChangesTo => 'Tillämpa ändringar på…';

  @override
  String get applyChangesDesc =>
      'Det här är en återkommande uppgift. Vill du uppdatera alla förekomster eller bara dagens och framtida datum?';

  @override
  String get allOccurrences => 'Alla förekomster';

  @override
  String get todayAndFuture => 'Idag och framåt';

  @override
  String get taskTitleLabel => 'Uppgiftstitel *';

  @override
  String get taskTitleValidation => 'Ange en titel';

  @override
  String get descriptionOptional => 'Kort beskrivning (valfri)';

  @override
  String get checklist => 'Checklista';

  @override
  String get addStep => '+ Lägg till steg';

  @override
  String get checklistHint =>
      'Lägg till steg för ett litet barn att följa ett i taget';

  @override
  String get stepDescription => 'Stegbeskrivning…';

  @override
  String stepsDone(int done, int total) {
    return '$done/$total steg klara';
  }

  @override
  String steps(int done, int total) {
    return '$done / $total steg';
  }

  @override
  String get repeats => 'Upprepas';

  @override
  String get oneTime => 'Engångs';

  @override
  String get daily => 'Dagligen';

  @override
  String get altDay => 'Varannan dag';

  @override
  String get monFri => 'Mån – Fre';

  @override
  String get weekly => 'Varje vecka';

  @override
  String get startsFrom => 'Börjar från';

  @override
  String get selectDays => 'Välj dagar';

  @override
  String get tapToSelectDays => 'Tryck för att välja specifika dagar';

  @override
  String daysSelected(int count) {
    return '$count dag vald';
  }

  @override
  String get assignToMembers => 'Tilldela familjemedlemmar';

  @override
  String get noMembersYet =>
      'Inga familjemedlemmar ännu — lägg till dem från fliken Familj.';

  @override
  String get saveChanges => 'Spara ändringar';

  @override
  String get cancel => 'Avbryt';

  @override
  String get delete => 'Ta bort';

  @override
  String get save => 'Spara';

  @override
  String get edit => 'Redigera';

  @override
  String get add => 'Lägg till';

  @override
  String get remove => 'Ta bort';

  @override
  String get confirm => 'Bekräfta';

  @override
  String get signIn => 'Logga in';

  @override
  String get createAccount => 'Skapa konto';

  @override
  String get emailLabel => 'E-post';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get signInWithGoogle => 'Logga in med Google';

  @override
  String get forgotPassword => 'Glömt lösenordet?';

  @override
  String get sendResetLink => 'Skicka återställningslänk';

  @override
  String get alreadyHaveAccount => 'Har du redan ett konto? Logga in';

  @override
  String get noAccount => 'Inget konto? Registrera dig';

  @override
  String get familyName => 'Familjenamn';

  @override
  String get createFamily => 'Skapa familj';

  @override
  String get joinFamily => 'Gå med i familj';

  @override
  String get inviteCode => 'Inbjudningskod';

  @override
  String get joinWithCode => 'Gå med med kod';

  @override
  String get members => 'Familj';

  @override
  String get addMember => 'Lägg till';

  @override
  String get editMember => 'Redigera medlem';

  @override
  String get removeMember => 'Ta bort medlem?';

  @override
  String removeMemberConfirm(String name) {
    return '$name tas bort från alla uppgifter. Detta kan inte ångras.';
  }

  @override
  String get nameLabel => 'Namn *';

  @override
  String get nameValidation => 'Ange ett namn';

  @override
  String get role => 'Roll';

  @override
  String get childRole => 'Barn';

  @override
  String get parentRole => 'Förälder';

  @override
  String get colour => 'Färg';

  @override
  String get avatar => 'Välj avatar';

  @override
  String doneToday(int done, int total) {
    return '$done / $total klara idag';
  }

  @override
  String get settings => 'Inställningar';

  @override
  String get appearance => 'Utseende';

  @override
  String get language => 'Språk';

  @override
  String get darkMode => 'Mörkt läge';

  @override
  String get lightMode => 'Ljust läge';

  @override
  String get themeColour => 'Temafärg';

  @override
  String get memberColours => 'Medlemsfärger';

  @override
  String get familySettings => 'Familj';

  @override
  String get allowChildAddTasks => 'Tillåt barn att lägga till uppgifter';

  @override
  String get inviteMembers => 'Bjud in medlemmar';

  @override
  String get inviteCode2 => 'Inbjudningskod';

  @override
  String get signOut => 'Logga ut';

  @override
  String get assistant => 'Assistent';

  @override
  String get assistantGreeting =>
      'Hej! Jag är din familjeassistent 👋 Jag kan hjälpa dig hantera uppgifter och skapa nya. Vad vill du göra?';

  @override
  String get setApiKey => 'Ange API-nyckel';

  @override
  String get apiKeyTitle => 'Anthropic API-nyckel';

  @override
  String get apiKeyDesc =>
      'Ange din Claude API-nyckel från console.anthropic.com. Den lagras bara på den här enheten.';

  @override
  String get apiKeyHint => 'sk-ant-…';

  @override
  String get addApiKeyBanner =>
      'Lägg till din Claude API-nyckel för att aktivera assistenten.';

  @override
  String get askMeAnything => 'Fråga mig vad som helst…';

  @override
  String get setApiKeyToStart => 'Ange din API-nyckel för att börja';

  @override
  String get weekView => 'Veckovy';

  @override
  String get monthView => 'Månadsvy';

  @override
  String get week => 'Vecka';

  @override
  String get month => 'Månad';

  @override
  String get addTaskBtn => '+ Lägg till uppgift';

  @override
  String get addRecurring => '+ Återkommande';

  @override
  String get tapIconToAdd => 'Tryck på rutan för att lägga till en ikon';

  @override
  String get noActionsAvailable => 'Inga åtgärder tillgängliga';

  @override
  String get askParentToEdit =>
      'Be en förälder att redigera eller ta bort uppgifter';
}
