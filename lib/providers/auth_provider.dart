import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../services/firebase_service.dart';

enum AuthStatus { loading, unauthenticated, noFamily, ready }

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _svc = FirebaseService();
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  String? _familyId;
  String? _memberId;
  MemberRole _role = MemberRole.child;
  bool _allowChildAddTasks = false;
  String? _loadError;

  StreamSubscription? _familySubscription;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get familyId => _familyId;
  String? get memberId => _memberId;
  MemberRole get role => _role;
  bool get isParent => _role == MemberRole.parent;
  bool get allowChildAddTasks => _allowChildAddTasks;
  String? get loadError => _loadError;
  bool get canAddTasks => isParent || _allowChildAddTasks;
  bool get canDeleteTasks => isParent;
  bool get canManageMembers => isParent;
  bool get canEditTasks => isParent;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _clearFamily();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await _loadFamily(user.uid);
  }

  Future<void> _loadFamily(String uid) async {
    _loadError = null;
    try {
      final record = await _svc
          .getUserRecord(uid)
          .timeout(const Duration(seconds: 15));
      if (record == null) {
        _clearFamily();
        _status = AuthStatus.noFamily;
        notifyListeners();
        return;
      }

      _familyId = record['familyId'] as String;
      _memberId = record['memberId'] as String?;

      // Check if this member's record has isParent = true
      bool memberIsParent = false;
      if (_memberId != null) {
        final member = await _svc
            .getMember(_familyId!, _memberId!)
            .timeout(const Duration(seconds: 15));
        memberIsParent = member?.isParent ?? false;
      }

      _familySubscription?.cancel();
      _familySubscription = _svc.watchFamily(_familyId!).listen((settings) {
        if (settings == null) return;
        _allowChildAddTasks = settings.allowChildAddTasks;
        _role = (settings.ownerUid == uid || memberIsParent)
            ? MemberRole.parent
            : MemberRole.child;
        notifyListeners();
      });

      _status = AuthStatus.ready;
      notifyListeners();
    } catch (e) {
      _clearFamily();
      _status = AuthStatus.unauthenticated;
      _loadError = 'Could not load your account: ${e.toString().replaceAll('Exception: ', '')}. Please check your connection and try again.';
      notifyListeners();
    }
  }

  void _clearFamily() {
    _familySubscription?.cancel();
    _familyId = null;
    _memberId = null;
    _role = MemberRole.child;
    _allowChildAddTasks = false;
  }

  // ── Sign in ──────────────────────────────────────────────────────────────

  Future<String?> signInWithGoogle() async {
    if (_googleSignIn == null) return 'Google Sign-In is not available on this platform';
    try {
      final account = await _googleSignIn!.signIn();
      if (account == null) return 'Sign-in cancelled';
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled')) return 'Sign-in cancelled';
      return 'Google sign-in failed. Please try another login method.';
    } catch (e) {
      return 'Google sign-in failed. Please try another login method.';
    }
  }

  Future<String?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) return 'Sign in with Apple failed: missing identity token';

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
      );

      await _auth.signInWithCredential(oauthCredential);
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return 'Sign-in cancelled';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  String _generateNonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e);
    }
  }

  // ── Family setup ─────────────────────────────────────────────────────────

  Future<String?> createFamily(String familyName, {
    required String parentName,
    required String parentEmoji,
    required int parentColorValue,
  }) async {
    if (_user == null) return 'Not signed in';
    try {
      final settings = await _svc.createFamily(_user!.uid, familyName);
      final memberId = const Uuid().v4();
      final parentMember = FamilyMember(
        id: memberId,
        name: parentName,
        emoji: parentEmoji,
        colorValue: parentColorValue,
        role: MemberRole.parent,
        uid: _user!.uid,
      );
      await _svc.setMember(settings.familyId, parentMember);
      await _svc.setUserRecord(_user!.uid, settings.familyId, memberId);
      _familyId = settings.familyId;
      _memberId = memberId;
      _role = MemberRole.parent;
      _allowChildAddTasks = false;
      _status = AuthStatus.ready;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> joinFamily(String code, String memberId) async {
    if (_user == null) return 'Not signed in';
    try {
      final settings = await _svc.findFamilyByCode(code);
      if (settings == null) return 'Invalid invite code';
      await _svc.updateMemberUid(settings.familyId, memberId, _user!.uid);
      await _svc.setUserRecord(_user!.uid, settings.familyId, memberId);
      _familyId = settings.familyId;
      _memberId = memberId;
      _role = MemberRole.child;
      _allowChildAddTasks = settings.allowChildAddTasks;
      _status = AuthStatus.ready;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateAllowChildAddTasks(bool value) async {
    if (_familyId == null) return;
    await _svc.updateAllowChildAddTasks(_familyId!, value);
    _allowChildAddTasks = value;
    notifyListeners();
  }

  Future<String?> deleteAccount() async {
    if (_user == null) return 'Not signed in';
    try {
      final uid = _user!.uid;
      final familyId = _familyId;
      final memberId = _memberId;
      if (familyId != null && memberId != null) {
        await _svc.deleteMember(familyId, memberId);
      }
      await _svc.deleteUserRecord(uid);
      await _user!.delete();
      _clearFamily();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'For security, please sign out and sign back in before deleting your account.';
      }
      return e.message ?? 'Failed to delete account.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    final isGoogle = _user?.providerData
            .any((p) => p.providerId == 'google.com') ??
        false;
    if (isGoogle && _googleSignIn != null) {
      try {
        await _googleSignIn?.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
    _clearFamily();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _authError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' => 'No account found for this email.',
        'wrong-password' => 'Incorrect password.',
        'email-already-in-use' => 'An account already exists for this email.',
        'weak-password' => 'Password must be at least 6 characters.',
        'invalid-email' => 'Please enter a valid email address.',
        _ => e.message ?? 'Authentication failed.',
      };

  @override
  void dispose() {
    _familySubscription?.cancel();
    super.dispose();
  }
}
