import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_member.dart';
import '../models/task.dart';

class FamilySettings {
  final String familyId;
  final String name;
  final String inviteCode;
  final bool allowChildAddTasks;
  final String ownerUid;

  const FamilySettings({
    required this.familyId,
    required this.name,
    required this.inviteCode,
    required this.allowChildAddTasks,
    required this.ownerUid,
  });

  FamilySettings copyWith({bool? allowChildAddTasks}) => FamilySettings(
        familyId: familyId,
        name: name,
        inviteCode: inviteCode,
        allowChildAddTasks: allowChildAddTasks ?? this.allowChildAddTasks,
        ownerUid: ownerUid,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'inviteCode': inviteCode,
        'allowChildAddTasks': allowChildAddTasks,
        'ownerUid': ownerUid,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  // ── Family ──────────────────────────────────────────────────────────────

  Future<FamilySettings> createFamily(String ownerUid, String familyName) async {
    final code = _generateCode();
    final ref = _db.collection('families').doc();
    final settings = FamilySettings(
      familyId: ref.id,
      name: familyName,
      inviteCode: code,
      allowChildAddTasks: false,
      ownerUid: ownerUid,
    );
    await ref.set(settings.toMap());
    return settings;
  }

  Future<FamilySettings?> findFamilyByCode(String code) async {
    final q = await _db
        .collection('families')
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final data = doc.data();
    return FamilySettings(
      familyId: doc.id,
      name: data['name'] as String,
      inviteCode: data['inviteCode'] as String,
      allowChildAddTasks: data['allowChildAddTasks'] as bool? ?? false,
      ownerUid: data['ownerUid'] as String,
    );
  }

  Stream<FamilySettings?> watchFamily(String familyId) =>
      _db.collection('families').doc(familyId).snapshots().map((snap) {
        if (!snap.exists) return null;
        final d = snap.data()!;
        return FamilySettings(
          familyId: snap.id,
          name: d['name'] as String,
          inviteCode: d['inviteCode'] as String,
          allowChildAddTasks: d['allowChildAddTasks'] as bool? ?? false,
          ownerUid: d['ownerUid'] as String,
        );
      });

  Future<void> updateAllowChildAddTasks(String familyId, bool value) =>
      _db.collection('families').doc(familyId).update({'allowChildAddTasks': value});

  // ── User↔Family mapping ─────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserRecord(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> setUserRecord(String uid, String familyId, String memberId) =>
      _db.collection('users').doc(uid).set({
        'familyId': familyId,
        'memberId': memberId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ── Members ─────────────────────────────────────────────────────────────

  Stream<List<FamilyMember>> watchMembers(String familyId) =>
      _db.collection('families/$familyId/members').snapshots().map(
            (snap) => snap.docs.map((d) => FamilyMember.fromJson(d.data())).toList(),
          );

  Future<void> setMember(String familyId, FamilyMember member) =>
      _db.collection('families/$familyId/members').doc(member.id).set(member.toJson());

  Future<void> deleteMember(String familyId, String memberId) =>
      _db.collection('families/$familyId/members').doc(memberId).delete();

  Future<void> updateMemberUid(String familyId, String memberId, String? uid) =>
      _db.collection('families/$familyId/members').doc(memberId).update({'uid': uid});

  /// Members that don't yet have a linked account (available for joining)
  Future<List<FamilyMember>> getAvailableMembers(String familyId) async {
    final snap = await _db.collection('families/$familyId/members').get();
    return snap.docs
        .map((d) => FamilyMember.fromJson(d.data()))
        .where((m) => m.uid == null)
        .toList();
  }

  // ── Tasks ───────────────────────────────────────────────────────────────

  Stream<List<Task>> watchTasks(String familyId) =>
      _db.collection('families/$familyId/tasks').snapshots().map(
            (snap) => snap.docs.map((d) => Task.fromJson(d.data())).toList(),
          );

  Future<void> setTask(String familyId, Task task) =>
      _db.collection('families/$familyId/tasks').doc(task.id).set(task.toJson());

  Future<void> deleteTask(String familyId, String taskId) =>
      _db.collection('families/$familyId/tasks').doc(taskId).delete();

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
