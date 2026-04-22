import 'package:flutter/material.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/services/skill_post_service.dart';
import 'package:skilllink/Widgets/recommendation_card.dart';
import 'package:skilllink/Pages/my_posts/my_post_detail_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final SkillPostService _service = SkillPostService();
  final ScrollController _scrollController = ScrollController();
  final Map<String, SkillPost> _postsById = {};

  List<SkillPost> _posts = [];
  bool _isLoadingInitial = false;
  bool _isFetchingMore = false;
  bool _isFetching = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _error;

  static const int _pageLimit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchPosts(isInitial: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isFetchingMore || !_hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts({bool isInitial = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (isInitial) {
      _offset = 0;
      _postsById.clear();
      setState(() {
        _isLoadingInitial = true;
        _error = null;
      });
    } else {
      setState(() => _isFetchingMore = true);
    }

    try {
      final result = await _service.getMyPosts(
        limit: _pageLimit,
        offset: _offset,
      );

      for (final post in result.posts) {
        _postsById[post.id] = post;
      }

      setState(() {
        _posts = _postsById.values.toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
        _hasMore = result.hasMore;
        _offset += result.posts.length;
        _isLoadingInitial = false;
        _isFetchingMore = false;
        _error = null;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoadingInitial = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong';
        _isLoadingInitial = false;
        _isFetchingMore = false;
      });
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh() async {
    await _fetchPosts(isInitial: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingInitial) return _buildSkeletonList();

    if (_error != null && _posts.isEmpty) return _buildErrorState();

    if (_posts.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length + (_isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            return Padding(
              key: ValueKey(_posts[index].id),
              padding: const EdgeInsets.only(bottom: 16),
              child: RecommendationCard(
                post: _posts[index],
                showActions: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyPostDetailScreen(post: _posts[index]),
                    ),
                  );
                },
              ),
            );
          }
          return _buildBottomLoader();
        },
      ),
    );
  }


  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(56, 56, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(14, 140),
                    const SizedBox(height: 8),
                    _shimmerBox(12, 100),
                  ],
                ),
              ),
              _shimmerBox(24, 80, radius: 12),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBox(60, double.infinity, radius: 12),
          const SizedBox(height: 12),
          _shimmerBox(60, double.infinity, radius: 12),
        ],
      ),
    );
  }

  Widget _shimmerBox(double height, double width, {double radius = 4}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildBottomLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }


  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Couldn't load your posts",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Check your connection and try again',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No posts yet",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "Your posts will appear here once you create one.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
