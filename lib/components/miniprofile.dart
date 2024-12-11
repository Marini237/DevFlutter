import 'package:flutter/material.dart';
import 'package:newflutterapp/models/user.dart';

class MiniProfile extends StatelessWidget {
  final User user;

  const MiniProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.avatar),
        ),
        const SizedBox(width: 10),
        Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
