import 'package:flutter/material.dart';

import '../models/usuario.dart';

class FriendDetailScreen extends StatelessWidget {
  final Usuario friend;
  final bool isAvailable;

  const FriendDetailScreen({
    super.key,
    required this.friend,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    const Color night = Color(0xFF0A090C);
    const Color white = Color(0xFFF0EDEE);
    const Color currant = Color(0xFF2C666E);
    const Color blue = Color(0xFF90DDF0);

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        iconTheme: const IconThemeData(color: night),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: blue.withOpacity(0.25),
                  backgroundImage:
                      friend.foto.isNotEmpty ? NetworkImage(friend.foto) : null,
                  child: friend.foto.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 64,
                          color: currant,
                        )
                      : null,
                ),
                const SizedBox(height: 28),
                Text(
                  friend.username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: night,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currant,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Send my location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: currant,
                      side: const BorderSide(color: currant, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'View schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}