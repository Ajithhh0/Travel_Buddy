import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final void Function()? onTap;

  const UserTile({
    Key? key,
    required this.username,
    required this.avatarUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 20),
            Text(username),
          ],
        ),
      ),
    );
  }
}
