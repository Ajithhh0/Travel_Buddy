import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/screens/chat/chat_page.dart';
import 'package:travel_buddy/screens/chat/chat_services.dart';

class UserTile extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final String recentMessage;
  final void Function()? onTap;

  const UserTile({
    Key? key,
    required this.username,
    required this.avatarUrl,
    required this.recentMessage,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  recentMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}