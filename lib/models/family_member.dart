import 'dart:convert';

enum MemberRole { parent, child }

class FamilyMember {
  final String id;
  final String name;
  final int colorValue;
  final String emoji;
  final MemberRole role;
  final String? uid; // Firebase Auth UID of the user linked to this profile

  const FamilyMember({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.emoji,
    this.role = MemberRole.child,
    this.uid,
  });

  bool get isParent => role == MemberRole.parent;

  FamilyMember copyWith({
    String? name,
    int? colorValue,
    String? emoji,
    MemberRole? role,
    String? uid,
    bool clearUid = false,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      emoji: emoji ?? this.emoji,
      role: role ?? this.role,
      uid: clearUid ? null : (uid ?? this.uid),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'emoji': emoji,
        'role': role.name,
        'uid': uid,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
        emoji: json['emoji'] as String? ?? '👤',
        role: MemberRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => MemberRole.child,
        ),
        uid: json['uid'] as String?,
      );

  static String encode(List<FamilyMember> members) =>
      jsonEncode(members.map((m) => m.toJson()).toList());

  static List<FamilyMember> decode(String source) =>
      (jsonDecode(source) as List)
          .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
          .toList();
}
