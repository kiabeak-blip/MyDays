import 'package:flutter/material.dart';
import '../models/family_member.dart';

class MemberAvatar extends StatelessWidget {
  final FamilyMember member;
  final double radius;

  const MemberAvatar({super.key, required this.member, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(member.colorValue),
      child: Text(
        member.emoji,
        style: TextStyle(fontSize: radius * 0.9),
      ),
    );
  }
}
