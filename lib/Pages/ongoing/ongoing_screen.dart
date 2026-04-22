import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skilllink/Pages/chat/chat_page.dart';
import 'package:skilllink/Pages/ongoing/ongoing_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/ongoing_post.dart';
import 'package:skilllink/services/skill_post_service.dart';

class OngoingScreen extends StatefulWidget {
  const OngoingScreen({super.key});

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageLimit = 10;
  static const int _autoFillCap = 3;

  final SkillPostService _service = SkillPostService();
  late final TabController _tabs;
  final ScrollController _scrollPosts = ScrollController();
  final ScrollController _scrollBids = ScrollController();

  String _status = 'ongoing';
  List<OngoingPost> _items = const [];
  bool _showInitialSpinner = false;
  bool _isFetching = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;
  int _autoFillUsed = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChanged);
    _scrollPosts.addListener(() => _onScroll(_scrollPosts));
    _scrollBids.addListener(() => _onScroll(_scrollBids));
    _hardReset();
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    _scrollPosts.dispose();
    _scrollBids.dispose();
    super.dispose();
  }


  Future<void> _hardReset() async {
    setState(() {
      _items = const [];
      _offset = 0;
      _hasMore = true;
      _error = null;
      _showInitialSpinner = true;
      _autoFillUsed = 0;
    });
    await _doFetch(replace: true);
  }

  Future<void> _refresh() async {
    if (_isFetching) return;
    setState(() {
      _offset = 0;
      _hasMore = true;
      _error = null;
      _autoFillUsed = 0;
    });
    await _doFetch(replace: true);
  }

  Future<void> _loadMore() async {
    if (_isFetching || !_hasMore) return;
    await _doFetch();
  }

  Future<void> _doFetch({bool replace = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    final requestOffset = _offset;
    try {
      final result = await _service.getUserSkillsPosts(
        status: _status,
        limit: _pageLimit,
        offset: requestOffset,
      );
      if (!mounted) return;

      final List<OngoingPost> next;
      if (replace) {
        next = result.posts;
      } else {
        final merged = <String, OngoingPost>{
          for (final p in _items) p.id: p,
        };
        for (final p in result.posts) {
          merged[p.id] = p;
        }
        next = merged.values.toList();
      }

      setState(() {
        _items = next;
        _offset = requestOffset + result.posts.length;
        _hasMore = result.hasMore && result.posts.isNotEmpty;
        _showInitialSpinner = false;
        _error = null;
      });
      _isFetching = false;
      _maybeAutoFill();
    } catch (e) {
      if (!mounted) {
        _isFetching = false;
        return;
      }
      setState(() {
        _showInitialSpinner = false;
        if (_items.isEmpty) {
          _error = e is ApiException
              ? e.message
              : 'Could not load engagements';
        }
      });
      _isFetching = false;
      if (_items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException ? e.message : 'Failed to refresh',
            ),
          ),
        );
      }
    }
  }

  void _maybeAutoFill() {
    if (!mounted || !_hasMore || _isFetching) return;
    if (_activeList().isNotEmpty) {
      _autoFillUsed = 0;
      return;
    }
    if (_autoFillUsed >= _autoFillCap) return;
    _autoFillUsed++;
    _doFetch();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    _autoFillUsed = 0;
    _maybeAutoFill();
  }

  void _onScroll(ScrollController controller) {
    if (!controller.hasClients) return;
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _setStatus(String status) {
    if (_status == status) return;
    _status = status;
    _hardReset();
  }

  List<OngoingPost> get _myPosts =>
      _items.where((p) => p.myRole == OngoingRole.owner).toList();

  List<OngoingPost> get _myBids =>
      _items.where((p) => p.myRole == OngoingRole.counterparty).toList();

  List<OngoingPost> _activeList() => _tabs.index == 0 ? _myPosts : _myBids;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Ongoing'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'My Posts'),
            Tab(text: 'My Bids'),
          ],
        ),
      ),
      body: _showInitialSpinner
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatusFilter(),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildList(_myPosts, _scrollPosts, isOwnerTab: true),
                      _buildList(_myBids, _scrollBids, isOwnerTab: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          _statusChip(label: 'Ongoing', value: 'ongoing'),
          const SizedBox(width: 8),
          _statusChip(label: 'Completed', value: 'completed'),
        ],
      ),
    );
  }

  Widget _statusChip({required String label, required String value}) {
    final selected = _status == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _setStatus(value),
      selectedColor: Colors.blue.shade600,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.grey.shade800,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.blue.shade600 : Colors.grey.shade300,
        ),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildList(
    List<OngoingPost> items,
    ScrollController controller, {
    required bool isOwnerTab,
  }) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _buildBody(items, controller, isOwnerTab: isOwnerTab),
    );
  }

  Widget _buildBody(
    List<OngoingPost> items,
    ScrollController controller, {
    required bool isOwnerTab,
  }) {
    if (_error != null && items.isEmpty) {
      return _scrollableMessage(
        controller: controller,
        icon: Icons.error_outline,
        iconColor: Colors.red.shade300,
        title: _error!,
        action: OutlinedButton.icon(
          onPressed: _hardReset,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      );
    }

    if (items.isEmpty) {
      if (_isFetching) {
        return _scrollableMessage(
          controller: controller,
          icon: Icons.handshake_outlined,
          iconColor: Colors.blue.shade200,
          title: 'Loading…',
          subtitle: null,
        );
      }
      return _buildEmpty(controller, isOwnerTab: isOwnerTab);
    }

    return ListView.separated(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        if (i >= items.length) {
          return _buildLoadMoreFooter();
        }
        return _buildTile(items[i]);
      },
    );
  }

  Widget _buildLoadMoreFooter() {
    if (_isFetching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _loadMore,
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('Load more'),
        ),
      ),
    );
  }

  Widget _buildEmpty(
    ScrollController controller, {
    required bool isOwnerTab,
  }) {
    final title = isOwnerTab
        ? (_status == 'completed'
            ? 'No completed posts'
            : 'No ongoing posts')
        : (_status == 'completed'
            ? 'No completed bids'
            : 'No ongoing bids');
    final subtitle = isOwnerTab
        ? 'Posts of yours that have an accepted bid will show here.'
        : 'Posts where your bid was accepted will show here.';
    return _scrollableMessage(
      controller: controller,
      icon: Icons.handshake_outlined,
      iconColor: Colors.blue.shade200,
      title: title,
      subtitle: subtitle,
      action: _hasMore
          ? OutlinedButton.icon(
              onPressed: _loadMore,
              icon: const Icon(Icons.expand_more, size: 18),
              label: const Text('Load more'),
            )
          : null,
    );
  }

  Widget _scrollableMessage({
    required ScrollController controller,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      children: [
        Icon(icon, size: 64, color: iconColor),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          Center(child: action),
        ],
      ],
    );
  }

  Widget _buildTile(OngoingPost p) {
    final other = p.otherUser;
    final hasOther = (other?.id ?? '').trim().isNotEmpty;
    final subtitle = p.isOwner
        ? 'You accepted ${other?.fullName ?? 'a bid'}'
        : '${other?.fullName ?? 'Poster'} accepted your bid';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OngoingDetailScreen(post: p),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  imageRef: other?.profilePicUrl,
                  radius: 24,
                  backgroundColor: Colors.blue.shade50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _statusBadge(p.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            p.bidAcceptedAt != null
                                ? 'Accepted ${DateFormat.yMMMd().format(p.bidAcceptedAt!)}'
                                : 'Accepted recently',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: hasOther
                                ? 'Message'
                                : 'No counterparty available',
                            icon: Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: hasOther
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade400,
                            ),
                            onPressed: !hasOther
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          chatUserId: other!.id,
                                          chatUserName: other.fullName,
                                          chatUserAvatar:
                                              other.profilePicUrl ?? '',
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'completed':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'cancelled':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        break;
      default:
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.isEmpty
            ? 'Active'
            : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
