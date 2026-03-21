import 'dart:convert';
import 'package:flutter/material.dart';
import '../viewmodels/friend_schedule_viewmodel.dart';
import 'calendar_view.dart';
import '../config/constants.dart';
import '../models/usuario.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class FriendDetailScreen extends StatelessWidget {
  final Usuario friend;
  final bool isAvailable;
  final String currentUserId;

  const FriendDetailScreen({
    super.key,
    required this.friend,
    required this.isAvailable,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    const Color night = Color(0xFF0A090C);
    const Color white = Color(0xFFF0EDEE);
    const Color currant = Color(0xFF2C666E);
    const Color blue = Color(0xFF90DDF0);

    Future<void> sendMyLocation() async {
      try {
        final userResponse = await http.get(
          Uri.parse('${Config.baseUrl}/usuarios/$userId'),
          headers: {'Content-Type': 'application/json'},
        );
        if (userResponse.statusCode != 200) {
          throw Exception('Could not fetch user data.');
        }
        final currentUsername = jsonDecode(userResponse.body)['username'] as String;
        // Permisos
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw Exception('Location services are disabled.');
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied.');
        }

        // Ubicación
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final mapsLink = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

        // POST al webhook de n8n
        final response = await http.post(
          Uri.parse('https://automation.luminotest.com/webhook/email-location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': friend.gmail,
            'name': friend.username,
            'from': currentUsername,
            'mapsLink': mapsLink,
          }),
        );

        if (!context.mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email sent successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send email. Try again.')),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }

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
                    onPressed: sendMyLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currant,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send my location',
                      style: TextStyle(
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CalendarView(
                            userId: currentUserId,
                            title: '${friend.username}\'s Schedule',
                            viewModel: FriendScheduleViewModel(friendId: friend.id),
                          ),
                        ),
                      );
                    },
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