import '../models/repositories/friend_schedule_repository.dart';
import 'package:flutter/material.dart';
import '../models/repositories/schedule_repository.dart';
import '../viewmodels/friend_schedule_viewmodel.dart';
import '../viewmodels/match_schedule_viewmodel.dart';
import 'calendar_view.dart';
import '../models/usuario.dart';
import 'app_nav.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cache/profile_image_cache_manager.dart';
import '../viewmodels/friend_detail_viewmodel.dart';


class FriendDetailScreen extends StatefulWidget {
  final Usuario friend;
  final bool isAvailable;
  final String userId;
  final ValueChanged<int>? onTabSwitch;

  const FriendDetailScreen({
    super.key,
    required this.friend,
    required this.isAvailable,
    required this.userId,
    this.onTabSwitch,
  });

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late final FriendDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FriendDetailViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
  

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical:32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: blue.withValues(alpha: 0.25),
                  child: widget.friend.foto.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.friend.foto,
                            cacheManager: ProfileImageCacheManager(),
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) => const Icon(Icons.person, size: 64, color: currant),
                          ),
                        ) 
                      : const Icon(Icons.person, size: 64, color: currant),            
                ),
                const SizedBox(height: 28),
                Text(
                  widget.friend.username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: night,
                  ),
                ),
                AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, _) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading
                                ? null
                                : () => _viewModel.sendLocation(
                                      userId: widget.userId,
                                      friendGmail: widget.friend.gmail,
                                      friendUsername: widget.friend.username,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currant,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _viewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Send my location',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        if (_viewModel.sendState == SendLocationState.noConnection)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off_rounded, size: 14, color: Colors.orange.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'No internet connection',
                                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                                ),
                              ],
                            ),
                          ),
                        if (_viewModel.sendState == SendLocationState.success)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                                SizedBox(width: 6),
                                Text(
                                  'Location sent!',
                                  style: TextStyle(fontSize: 12, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        if (_viewModel.sendState == SendLocationState.error)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _viewModel.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                      ],
                    );
                  },
                ), 
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final friendVm = FriendScheduleViewModel(friendId: widget.friend.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CalendarView(
                            userId: widget.userId,
                            title: '${widget.friend.username}\'s Schedule',
                            viewModel: friendVm,
                            showBottomNav: true,
                            navCurrentIndex: 1,
                            onNavTap: (index) {
                              Navigator.popUntil(context, (route) => route.isFirst);
                              widget.onTabSwitch?.call(index);
                            },
                            floatingActionButton: Builder(
                              builder: (ctx) => FloatingActionButton(
                                backgroundColor: const Color(0xFF2C666E),
                                onPressed: () async {
                                  try {
                                    final myScheduleFuture =
                                        ScheduleRepository().getActiveScheduleWithCache(widget.userId);

                                    final friendScheduleFuture =
                                        FriendScheduleRepository().getFriendActiveScheduleWithCache(widget.friend.id);

                                    await Future.wait([
                                      myScheduleFuture,
                                      friendScheduleFuture,
                                    ]);

                                    final myScheduleResult = await myScheduleFuture;
                                    final friendScheduleResult = await friendScheduleFuture;

                                    final myHorario = myScheduleResult.horario;
                                    final friendHorario = friendScheduleResult.horario;

                                    if (!ctx.mounted) return;

                                    if (myHorario.id.isEmpty || friendHorario.id.isEmpty) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('No se pudo preparar el match de horarios.'),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(ctx).push(
                                      MaterialPageRoute(
                                        builder: (_) => CalendarView(
                                          userId: widget.userId,
                                          title: 'Match Schedule',
                                          viewModel: MatchScheduleViewModel(
                                            userId: widget.userId,
                                            friendId: widget.friend.id,
                                            horario1Id: myHorario.id,
                                            horario2Id: friendHorario.id,
                                          ),
                                          showBottomNav: false,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!ctx.mounted) return;

                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst('Exception: ', ''),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Icon(Icons.compare_arrows_rounded, color: Colors.white),
                              ),
                            ),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          Navigator.popUntil(context, (route) => route.isFirst);
          widget.onTabSwitch?.call(index);
        },
      ),
    );
  }
}