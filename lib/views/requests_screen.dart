import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../viewmodels/requests_viewmodel.dart';


class RequestsScreen extends StatefulWidget {
  final String userId;

  const RequestsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final RequestsViewModel _viewModel = RequestsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadRequests(widget.userId);
  }

  Future<void> _onSearchPressed() async {
    final TextEditingController controller = TextEditingController();

    _viewModel.clearSearchState();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        const Color night = Color(0xFF0A090C);
        const Color white = Color(0xFFF0EDEE);
        const Color currant = Color(0xFF2C666E);
        const Color blue = Color(0xFF90DDF0);

        return AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Search user',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: night,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Enter username',
                          filled: true,
                          fillColor: white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _viewModel.isSearching
                              ? null
                              : () async {
                                  await _viewModel.searchUserByUsername(
                                    controller.text,
                                    widget.userId,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currant,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _viewModel.isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Search',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_viewModel.searchMessage.isNotEmpty)
                        Text(
                          _viewModel.searchMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: night,
                            fontSize: 15,
                          ),
                        ),
                      if (_viewModel.searchedUser != null) ...[
                        const SizedBox(height: 8),
                        _SearchResultCard(
                          user: _viewModel.searchedUser!,
                          isSending: _viewModel.isSendingRequest,
                          onSend: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            final success = await _viewModel.sendFriendRequest(
                              targetUserId: _viewModel.searchedUser!.id,
                              senderUserId: widget.userId,
                            );

                            if (!mounted) return;

                            if (success) {
                              navigator.pop();
                              await _viewModel.loadRequests(widget.userId);
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Request sent successfully')),
                              );
                            } else if (_viewModel.searchMessage.isNotEmpty) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(_viewModel.searchMessage)),
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    _viewModel.clearSearchState();
  }

  Future<void> _acceptRequest(String senderUserId) async {
    final success = await _viewModel.acceptRequest(
      currentUserId: widget.userId,
      senderUserId: senderUserId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else if (_viewModel.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage)),
      );
    }
  }

  Future<void> _rejectRequest(String senderUserId) async {
    final success = await _viewModel.rejectRequest(
      currentUserId: widget.userId,
      senderUserId: senderUserId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else if (_viewModel.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color night = Color(0xFF0A090C);
    const Color white = Color(0xFFF0EDEE);
    const Color currant = Color(0xFF2C666E);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: night),
            ),
            title: const Text(
              'Requests',
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
                  onPressed: _onSearchPressed,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    const Color night = Color(0xFF0A090C);
    const Color blue = Color(0xFF90DDF0);
    const Color currant = Color(0xFF2C666E);

    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage.isNotEmpty && !_viewModel.hasRequests) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _viewModel.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: night,
            ),
          ),
        ),
      );
    }

    if (!_viewModel.hasRequests) {
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
                  color: blue.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 52,
                  color: currant,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No requests',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: night,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'When someone sends you a request, it will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: night.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _viewModel.requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _viewModel.requests[index];

        return _RequestCard(
          user: user,
          onAccept: () => _acceptRequest(user.id),
          onReject: () => _rejectRequest(user.id),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Usuario user;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.user,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    const Color night = Color(0xFF0A090C);
    const Color white = Color(0xFFF0EDEE);
    const Color currant = Color(0xFF2C666E);

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
            radius: 24,
            backgroundColor: currant.withValues(alpha: 0.15),
            backgroundImage:
                user.foto.isNotEmpty ? NetworkImage(user.foto) : null,
            child: user.foto.isEmpty
                ? const Icon(Icons.person, color: currant)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: night,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onAccept,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onReject,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Usuario user;
  final VoidCallback onSend;
  final bool isSending;

  const _SearchResultCard({
    required this.user,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    const Color night = Color(0xFF0A090C);
    const Color white = Color(0xFFF0EDEE);
    const Color currant = Color(0xFF2C666E);

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
            radius: 24,
            backgroundColor: currant.withValues(alpha: 0.15),
            backgroundImage: user.foto.isNotEmpty ? NetworkImage(user.foto) : null,
            child: user.foto.isEmpty
                ? const Icon(Icons.person, color: currant)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: night,
              ),
            ),
          ),
          IconButton(
            onPressed: isSending ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: currant,
              foregroundColor: Colors.white,
            ),
            icon: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}