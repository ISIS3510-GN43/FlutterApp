import 'package:app_flutter/cache/profile_image_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../viewmodels/friends_viewmodel.dart';
import 'friend_detail_screen.dart';
import 'requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  final String userId;
  final ValueChanged<int>? onTabSwitch;

  const FriendsScreen({
    super.key,
    required this.userId,
    this.onTabSwitch,
  });

  @override
  State<FriendsScreen> createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  final FriendsViewModel _viewModel = FriendsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadFriends(widget.userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    await _viewModel.loadFriends(widget.userId);
    setState(() {});
  }

  Future<void> _openRequestsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestsScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      await _viewModel.loadFriends(widget.userId);
    }
  }

  String _formatLastSync(DateTime? dt) {
    if (dt == null) return 'Never synced';
 
    final diff = DateTime.now().difference(dt);
 
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    const night = Color(0xFF0A090C);
    const white = Color(0xFFF0EDEE);
    const green = Color(0xFF07393C);
    const currant = Color(0xFF2C666E);
    const blue = Color(0xFF90DDF0);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Friends',
              style: TextStyle(
                color: night,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: _openRequestsScreen,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Banner offline: solo visible cuando no hay conexión ──────
              if (_viewModel.isOffline)
                _OfflineBanner(
                  lastSynced: _formatLastSync(_viewModel.lastSyncedAt),
                ),
              Expanded(
                child: _buildBody(
                  night: night,
                  green: green,
                  currant: currant,
                  blue: blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required Color night,
    required Color green,
    required Color currant,
    required Color blue,
  }) {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _viewModel.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: night,
            ),
          ),
        ),
      );
    }

    if (!_viewModel.hasFriends) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 52,
                  color: currant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No friends yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: night,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'When you add friends, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: night,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _viewModel.friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final friend = _viewModel.friends[index];
        final isAvailable = _viewModel.isFriendAvailable(friend);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendDetailScreen(
                  friend: friend,
                  isAvailable: isAvailable,
                  userId: widget.userId,
                  onTabSwitch: widget.onTabSwitch,
                ),
              ),
            );
          },
          child: _FriendCard(
            friend: friend,
            isAvailable: isAvailable,
            isOffline: _viewModel.isOffline,
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String lastSynced;
 
  const _OfflineBanner({required this.lastSynced});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline · Last updated: $lastSynced',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final Usuario friend;
  final bool isAvailable;
  final bool isOffline;

  const _FriendCard({
    required this.friend,
    required this.isAvailable,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    const night = Color(0xFF0A090C);
    const white = Color(0xFFF0EDEE);
    const currant = Color(0xFF2C666E);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: currant.withValues(alpha: 0.15),
            child: friend.foto.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: friend.foto,
                      cacheManager: ProfileImageCacheManager(),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const Icon(Icons.person, color: currant),
                    ),
                )
                : const Icon(Icons.person, color: currant),
                
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              friend.username,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: night,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isOffline
                  ? Colors.grey.withValues(alpha: 0.10)
                  : isAvailable
                    ? Colors.green.withValues(alpha: 0.10)
                    : Colors.red.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: isOffline ? Colors.grey : isAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  isOffline ? 'Offline' : isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOffline ? Colors.grey : isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}