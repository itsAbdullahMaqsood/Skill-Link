import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/Pages/chat/chat_inbox.dart';
import 'package:skilllink/Pages/offers/open_offers.dart';
import 'package:skilllink/Pages/profile/profile_page.dart';
import 'package:skilllink/Pages/timecoin/timecoin_screen.dart';
import 'package:skilllink/Pages/home/home_body_screen.dart';
import 'package:skilllink/Pages/offers/new_offer_screen.dart';
import 'package:skilllink/Widgets/home_drawer.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/skill_post_service.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';

enum SortMode { latest, oldest, mostBids, leastBids }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final SkillPostService _skillPostService = SkillPostService();
  String _searchQuery = '';
  SortMode _sortMode = SortMode.latest;

  List<SkillPost> _posts = [];
  bool _isLoadingInitial = false;
  bool _isFetchingMore = false;
  bool _isFetching = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _feedError;
  String _activeSearch = '';
  static const int _pageLimit = 10;
  static const String _feedStatus = 'active';

  String _sortParam(SortMode mode) {
    switch (mode) {
      case SortMode.latest:
        return 'latest';
      case SortMode.oldest:
        return 'oldest';
      case SortMode.mostBids:
        return 'most_bids';
      case SortMode.leastBids:
        return 'least_bids';
    }
  }

  UserModel? _currentUser;
  final Map<String, SkillPost> _postsById = {};
  final AuthService _authService = AuthService();

  UserModel get _userForDrawer =>
      _currentUser ??
      UserModel(
        id: '',
        fullName: 'Loading...',
        email: '',
        password: '',
        age: 0,
        gender: '',
        location: '',
        phoneNumber: '',
        portfolioLink: '',
        verified: false,
      );

  @override
  void initState() {
    super.initState();
    _fetchPosts(isInitial: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
    unawaited(_refreshCurrentUser());
  }

  Future<void> _refreshCurrentUser() async {
    final fresh = await _authService.refreshCurrentUserFromApi();
    if (!mounted || fresh == null) return;
    setState(() => _currentUser = fresh);
  }

  Future<void> _fetchPosts({bool isInitial = false}) async {
    if (_isFetching) return;
    if (!isInitial && !_hasMore) return;
    _isFetching = true;

    if (isInitial) {
      _offset = 0;
      _postsById.clear();
    }

    setState(() {
      _isLoadingInitial = isInitial;
      _isFetchingMore = !isInitial;
      _feedError = isInitial ? null : _feedError;
    });

    final requestOffset = _offset;

    try {
      final result = await _skillPostService.getSkillPosts(
        limit: _pageLimit,
        offset: requestOffset,
        status: _feedStatus,
        search: _activeSearch.isNotEmpty ? _activeSearch : null,
        sort: _sortParam(_sortMode),
      );
      if (!mounted) return;

      int addedCount = 0;
      for (final post in result.posts) {
        if (!post.isExpired && !_postsById.containsKey(post.id)) {
          _postsById[post.id] = post;
          addedCount++;
        }
      }

      final nextOffset = requestOffset + result.posts.length;
      final moreAvailable =
          result.hasMore && result.posts.isNotEmpty && addedCount > 0;

      debugPrint(
        '[Feed] offset=$requestOffset fetched=${result.posts.length} '
        'new=$addedCount total=${_postsById.length} '
        'nextOffset=$nextOffset hasMore=$moreAvailable',
      );

      setState(() {
        _posts = _postsById.values.toList();
        _offset = nextOffset;
        _hasMore = moreAvailable;
        _isLoadingInitial = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _isFetchingMore = false;
        if (isInitial) _feedError = e.toString();
      });
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh() async {
    _hasMore = true;
    await _fetchPosts(isInitial: true);
  }

  void _onBidStatusChanged(String postId, bool hasUserBid) {
    final existing = _postsById[postId];
    if (existing != null) {
      _postsById[postId] = existing.copyWith(hasUserBid: hasUserBid);
      setState(() {
        _posts = _postsById.values.toList();
      });
    }
  }

  void _onPostAccepted(String postId) {
    if (_postsById.remove(postId) != null) {
      setState(() {
        _posts = _postsById.values.toList();
      });
    }
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed == _activeSearch) return;
    _searchQuery = value.toLowerCase().trim();
    _activeSearch = trimmed;
    _hasMore = true;
    _fetchPosts(isInitial: true);
  }

  void _onSortChanged(SortMode mode) {
    if (mode == _sortMode) return;
    setState(() {
      _sortMode = mode;
      _hasMore = true;
    });
    _fetchPosts(isInitial: true);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex > 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        endDrawer: HomeDrawer(
          user: _userForDrawer,
          timecoinBalance: _currentUser?.timeCoins ?? 0,
          onSelectTab: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          onPushScreen: (screen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ).then((_) {
              setState(() {});
            });
          },
          onLogout: () => _logout(context),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: Colors.transparent,
          shape: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
          automaticallyImplyLeading: false,
          leadingWidth: 110,
          leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimecoinScreen()),
              ).then((_) {
                setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/timecoin.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    (_currentUser?.timeCoins ?? 0).toString(),
                    style: AppTypography.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          title: Text(
            'Skill Link',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall.copyWith(letterSpacing: 0.3),
          ),
          actions: [
            SizedBox(
              width: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    color: AppColors.textPrimary,
                    tooltip: 'Notifications',
                    onPressed: () {},
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      color: AppColors.textPrimary,
                      tooltip: 'Open menu',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _getBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          showUnselectedLabels: true,
          selectedLabelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTypography.labelMedium,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.add_rounded, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart_outlined),
              activeIcon: Icon(Icons.stacked_bar_chart),
              label: 'Offers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return HomeBodyScreen(
          posts: _posts,
          searchQuery: _searchQuery,
          isLoadingInitial: _isLoadingInitial,
          isFetchingMore: _isFetchingMore,
          hasMore: _hasMore,
          feedError: _feedError,
          onFetchMore: () => _fetchPosts(),
          onRefresh: _onRefresh,
          onBalanceUpdate: () => setState(() {}),
          onSearchSubmitted: _onSearchChanged,
          sortMode: _sortMode,
          onSortChanged: _onSortChanged,
          onBidStatusChanged: _onBidStatusChanged,
          onPostAccepted: _onPostAccepted,
        );
      case 1:
        return const ChatInboxScreen();
      case 2:
        return const NewOfferScreen();
      case 3:
        return const MyOffersScreen();
      case 4:
        return _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : ProfileScreen(
                user: _currentUser!,
                isCurrentUser: true,
                onProfileUpdated: (u) => setState(() => _currentUser = u),
                onRefresh: _refreshCurrentUser,
              );
      default:
        return HomeBodyScreen(
          posts: _posts,
          searchQuery: _searchQuery,
          isLoadingInitial: _isLoadingInitial,
          isFetchingMore: _isFetchingMore,
          hasMore: _hasMore,
          feedError: _feedError,
          onFetchMore: () => _fetchPosts(),
          onRefresh: _onRefresh,
          onBalanceUpdate: () => setState(() {}),
          onSearchSubmitted: _onSearchChanged,
          sortMode: _sortMode,
          onSortChanged: _onSortChanged,
          onBidStatusChanged: _onBidStatusChanged,
          onPostAccepted: _onPostAccepted,
        );
    }
  }
}
