import 'package:flutter/material.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/models/received_bid.dart';
import 'package:skilllink/services/skill_post_service.dart';
import 'package:skilllink/Pages/offers/offer_card.dart';
import 'package:skilllink/Pages/offers/received_bid_card.dart';

class MyOffersScreen extends StatefulWidget {
  final int initialTab;

  const MyOffersScreen({super.key, this.initialTab = 0});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SkillPostService _service = SkillPostService();
  static const int _limit = 10;

  final List<SentBid> _sentPosts = [];
  final Map<String, SentBid> _sentPostsById = {};
  int _sentOffset = 0;
  bool _sentHasMore = true;
  bool _sentIsLoading = true;
  bool _sentIsFetchingMore = false;
  String? _sentError;
  final ScrollController _sentScrollController = ScrollController();

  final List<ReceivedBid> _receivedBids = [];
  int _receivedOffset = 0;
  bool _receivedHasMore = true;
  bool _receivedIsLoading = true;
  bool _receivedIsFetchingMore = false;
  String? _receivedError;
  final ScrollController _receivedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _sentScrollController.addListener(_onSentScroll);
    _receivedScrollController.addListener(_onReceivedScroll);
    _fetchSentPosts(initial: true);
    _fetchReceivedBids(initial: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sentScrollController.dispose();
    _receivedScrollController.dispose();
    super.dispose();
  }


  void _onSentScroll() {
    if (_sentScrollController.position.pixels >=
            _sentScrollController.position.maxScrollExtent - 200 &&
        !_sentIsFetchingMore &&
        _sentHasMore) {
      _fetchSentPosts();
    }
  }

  Future<void> _fetchSentPosts({bool initial = false}) async {
    if (!initial && (_sentIsFetchingMore || !_sentHasMore)) return;

    setState(() {
      if (initial) {
        _sentIsLoading = true;
        _sentError = null;
      } else {
        _sentIsFetchingMore = true;
      }
    });

    try {
      final result = await _service.getMyBids(
        limit: _limit,
        offset: _sentOffset,
      );
      if (!mounted) return;

      int newCount = 0;
      for (final post in result.posts) {
        if (!_sentPostsById.containsKey(post.postId)) {
          _sentPostsById[post.postId] = post;
          _sentPosts.add(post);
          newCount++;
        }
      }

      setState(() {
        _sentOffset += result.posts.length;
        _sentHasMore = result.hasMore;
        _sentIsLoading = false;
        _sentIsFetchingMore = false;
      });

      debugPrint(
        '[Sent] fetched=${result.posts.length} new=$newCount total=${_sentPosts.length} hasMore=${result.hasMore}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sentError = e.toString();
        _sentIsLoading = false;
        _sentIsFetchingMore = false;
      });
    }
  }

  Future<void> _refreshSent() async {
    _sentPosts.clear();
    _sentPostsById.clear();
    _sentOffset = 0;
    _sentHasMore = true;
    await _fetchSentPosts(initial: true);
  }


  void _onReceivedScroll() {
    if (_receivedScrollController.position.pixels >=
            _receivedScrollController.position.maxScrollExtent - 200 &&
        !_receivedIsFetchingMore &&
        _receivedHasMore) {
      _fetchReceivedBids();
    }
  }

  Future<void> _fetchReceivedBids({bool initial = false}) async {
    if (!initial && (_receivedIsFetchingMore || !_receivedHasMore)) return;

    setState(() {
      if (initial) {
        _receivedIsLoading = true;
        _receivedError = null;
      } else {
        _receivedIsFetchingMore = true;
      }
    });

    try {
      final result = await _service.getReceivedBids(
        limit: _limit,
        offset: _receivedOffset,
      );
      if (!mounted) return;

      setState(() {
        _receivedBids.addAll(result.bids);
        _receivedOffset += result.bids.length;
        _receivedHasMore = result.hasMore;
        _receivedIsLoading = false;
        _receivedIsFetchingMore = false;
      });

      debugPrint(
        '[Received] fetched=${result.bids.length} total=${_receivedBids.length} hasMore=${result.hasMore}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _receivedError = e.toString();
        _receivedIsLoading = false;
        _receivedIsFetchingMore = false;
      });
    }
  }

  Future<void> _refreshReceived() async {
    _receivedBids.clear();
    _receivedOffset = 0;
    _receivedHasMore = true;
    await _fetchReceivedBids(initial: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.inbox), text: "Received"),
            Tab(icon: Icon(Icons.send), text: "Sent"),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: TabBarView(
          controller: _tabController,
          children: [_buildReceivedTab(), _buildSentTab()],
        ),
      ),
    );
  }


  Widget _buildReceivedTab() {
    if (_receivedIsLoading) return _buildLoadingState();
    if (_receivedError != null) {
      return _buildErrorState(_receivedError!, _refreshReceived);
    }
    if (_receivedBids.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: "No bids received",
        subtitle: "Bids on your posts will appear here",
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReceived,
      child: ListView.builder(
        controller: _receivedScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _receivedBids.length + (_receivedHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _receivedBids.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ReceivedBidCard(bid: _receivedBids[index]);
        },
      ),
    );
  }


  Widget _buildSentTab() {
    if (_sentIsLoading) return _buildLoadingState();
    if (_sentError != null) {
      return _buildErrorState(_sentError!, _refreshSent);
    }
    if (_sentPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: "No bids sent",
        subtitle: "Posts you've bid on will appear here",
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSent,
      child: ListView.builder(
        controller: _sentScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _sentPosts.length + (_sentHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _sentPosts.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return OfferCard(
            key: ValueKey(_sentPosts[index].postId),
            bid: _sentPosts[index],
          );
        },
      ),
    );
  }


  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
