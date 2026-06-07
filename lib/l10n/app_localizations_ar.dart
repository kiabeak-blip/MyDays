// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MyDays';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navMembers => 'العائلة';

  @override
  String get navAssistant => 'المساعد';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navMyTasks => 'مهامي';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get tomorrow => 'غداً';

  @override
  String get recurringTasks => 'المهام المتكررة';

  @override
  String get scheduled => 'المجدولة';

  @override
  String get tasks => 'المهام';

  @override
  String get noTasks => 'لا توجد مهام';

  @override
  String noTasksForMember(String name) {
    return 'لا توجد مهام لـ$name اليوم';
  }

  @override
  String get enjoyWeekend => 'لا مهام — استمتع بعطلة نهاية الأسبوع!';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get duplicateTask => 'نسخ المهمة';

  @override
  String get duplicateTaskSub => 'نسخ بعضو/تاريخ مختلف';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get deleteTaskConfirm => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get applyChangesTo => 'تطبيق التغييرات على…';

  @override
  String get applyChangesDesc =>
      'هذه مهمة متكررة. هل تريد تحديث جميع التكرارات أم اليوم والتواريخ المستقبلية فقط؟';

  @override
  String get allOccurrences => 'جميع التكرارات';

  @override
  String get todayAndFuture => 'اليوم وما بعده';

  @override
  String get taskTitleLabel => 'عنوان المهمة *';

  @override
  String get taskTitleValidation => 'الرجاء إدخال عنوان';

  @override
  String get descriptionOptional => 'وصف مختصر (اختياري)';

  @override
  String get checklist => 'قائمة التحقق';

  @override
  String get addStep => '+ إضافة خطوة';

  @override
  String get checklistHint => 'أضف خطوات يتبعها الطفل واحدة تلو الأخرى';

  @override
  String get stepDescription => 'وصف الخطوة…';

  @override
  String stepsDone(int done, int total) {
    return '$done/$total خطوات مكتملة';
  }

  @override
  String steps(int done, int total) {
    return '$done / $total خطوات';
  }

  @override
  String get repeats => 'التكرار';

  @override
  String get oneTime => 'مرة واحدة';

  @override
  String get daily => 'يومياً';

  @override
  String get altDay => 'يوم بعد يوم';

  @override
  String get monFri => 'الإثنين – الجمعة';

  @override
  String get weekly => 'أسبوعياً';

  @override
  String get startsFrom => 'يبدأ من';

  @override
  String get selectDays => 'اختر الأيام';

  @override
  String get tapToSelectDays => 'اضغط لاختيار أيام محددة';

  @override
  String daysSelected(int count) {
    return '$count يوم محدد';
  }

  @override
  String get assignToMembers => 'تعيين لأفراد العائلة';

  @override
  String get noMembersYet =>
      'لا يوجد أفراد عائلة بعد — أضفهم من تبويب العائلة.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بـ Google';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get sendResetLink => 'إرسال رابط الاسترداد';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ سجل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get familyName => 'اسم العائلة';

  @override
  String get createFamily => 'إنشاء عائلة';

  @override
  String get joinFamily => 'الانضمام لعائلة';

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get joinWithCode => 'الانضمام برمز';

  @override
  String get members => 'العائلة';

  @override
  String get addMember => 'إضافة';

  @override
  String get editMember => 'تعديل العضو';

  @override
  String get removeMember => 'إزالة العضو؟';

  @override
  String removeMemberConfirm(String name) {
    return 'سيتم إزالة $name من جميع المهام. لا يمكن التراجع عن هذا.';
  }

  @override
  String get nameLabel => 'الاسم *';

  @override
  String get nameValidation => 'الرجاء إدخال اسم';

  @override
  String get role => 'الدور';

  @override
  String get childRole => 'طفل';

  @override
  String get parentRole => 'والد/والدة';

  @override
  String get colour => 'اللون';

  @override
  String get avatar => 'اختر صورة';

  @override
  String doneToday(int done, int total) {
    return '$done / $total مكتملة اليوم';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get themeColour => 'لون السمة';

  @override
  String get memberColours => 'ألوان الأعضاء';

  @override
  String get familySettings => 'العائلة';

  @override
  String get allowChildAddTasks => 'السماح للأطفال بإضافة مهام';

  @override
  String get inviteMembers => 'دعوة الأعضاء';

  @override
  String get inviteCode2 => 'رمز الدعوة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get assistant => 'المساعد';

  @override
  String get assistantGreeting =>
      'مرحباً! أنا مساعدك العائلي 👋 يمكنني مساعدتك في إدارة المهام وإنشاء جداول جديدة. ماذا تريد أن تفعل؟';

  @override
  String get setApiKey => 'تعيين مفتاح API';

  @override
  String get apiKeyTitle => 'مفتاح Anthropic API';

  @override
  String get apiKeyDesc =>
      'أدخل مفتاح Claude API من console.anthropic.com. يتم تخزينه على هذا الجهاز فقط.';

  @override
  String get apiKeyHint => 'sk-ant-…';

  @override
  String get addApiKeyBanner => 'أضف مفتاح Claude API لتفعيل المساعد.';

  @override
  String get askMeAnything => 'اسألني أي شيء…';

  @override
  String get setApiKeyToStart => 'أضف مفتاح API للبدء';

  @override
  String get weekView => 'عرض الأسبوع';

  @override
  String get monthView => 'عرض الشهر';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get addTaskBtn => '+ إضافة مهمة';

  @override
  String get addRecurring => '+ متكررة';

  @override
  String get tapIconToAdd => 'اضغط على المربع لإضافة أيقونة';

  @override
  String get noActionsAvailable => 'لا توجد إجراءات متاحة';

  @override
  String get askParentToEdit => 'اطلب من أحد الوالدين تعديل أو حذف المهام';
}
