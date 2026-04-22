import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/ongoing_post.dart';
import 'package:skilllink/models/post_bid.dart';
import 'package:skilllink/models/received_bid.dart';
import 'package:skilllink/models/sent_bid.dart';
import 'package:skilllink/models/skill_post_dto.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/services/api_service.dart';

class SkillPostService {
  SkillPostService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  static ApiException _fromDio(DioException e) {
    final data = e.response?.data;
    String message = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
    }
    return ApiException(
      message: message,
      statusCode: e.response?.statusCode,
      error: data is Map ? (data['error'] as String?) : null,
    );
  }

  Future<Map<String, dynamic>> createPost(Map<String, dynamic> payload) async {
    try {
      final res = await _api.post('/skill-posts', data: payload);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<PaginatedSkillPosts> getSkillPosts({
    required int limit,
    required int offset,
    required String status,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'status': status,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParameters['sortBy'] = sort;
      }
      debugPrint('[SkillPostService] GET /skill-posts?$queryParameters');
      final res = await _api.get(
        '/skill-posts',
        queryParameters: queryParameters,
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      debugPrint('[SkillPostService] Response total=${data['total']} hasMore=${data['hasMore']} posts=${(data['posts'] as List?)?.length ?? 0}');
      final dto = PaginatedSkillPostsDto.fromJson(data);
      return SkillPostMapper.fromPaginatedDto(dto);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<PaginatedSkillPosts> getMyPosts({
    required int limit,
    required int offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      debugPrint('[SkillPostService] GET /skill-posts/my-posts?$queryParameters');
      final res = await _api.get(
        '/skill-posts/my-posts',
        queryParameters: queryParameters,
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      debugPrint('[SkillPostService] my-posts total=${data['total']} hasMore=${data['hasMore']} posts=${(data['posts'] as List?)?.length ?? 0}');
      final dto = PaginatedSkillPostsDto.fromJson(data);
      return SkillPostMapper.fromPaginatedDto(dto);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<PaginatedSentBids> getMyBids({
    required int limit,
    required int offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      debugPrint('[SkillPostService] GET /skill-posts/my-bids?$queryParameters');
      final res = await _api.get(
        '/skill-posts/my-bids',
        queryParameters: queryParameters,
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      debugPrint('[SkillPostService] my-bids total=${data['total']} hasMore=${data['hasMore']} posts=${(data['posts'] as List?)?.length ?? 0}');
      return PaginatedSentBids.fromJson(data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<({SkillPost post, List<PostBid> bids})> getPostById(String id) async {
    try {
      debugPrint('[SkillPostService] GET /skill-posts/$id');
      final res = await _api.get('/skill-posts/$id');
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};

      final dto = SkillPostDto.fromJson(data);
      final post = SkillPostMapper.fromDto(dto);

      final rawBids = data['bids'];
      final bids = <PostBid>[];
      if (rawBids is List) {
        for (final b in rawBids) {
          if (b is Map<String, dynamic>) {
            bids.add(PostBid.fromJson(b));
          }
        }
      }

      debugPrint('[SkillPostService] post=${post.id} bids=${bids.length}');
      return (post: post, bids: bids);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> placeBid({
    required String postId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      debugPrint('[SkillPostService] POST /skill-posts/$postId/bids payload=$payload');
      final res = await _api.post('/skill-posts/$postId/bids', data: payload);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> cancelBid({required String postId}) async {
    try {
      debugPrint('[SkillPostService] DELETE /skill-posts/$postId/my-bid');
      final res = await _api.delete('/skill-posts/$postId/my-bid');
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'message': 'Bid cancelled'};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>?> getBidByPostId({
    required String postId,
  }) async {
    try {
      debugPrint(
          '[SkillPostService] GET /skill-posts/get-bid-from-post-id/$postId');
      final res =
          await _api.get('/skill-posts/get-bid-from-post-id/$postId');
      final data = res.data;
      if (data is Map<String, dynamic> && data['bid'] is Map<String, dynamic>) {
        return data['bid'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> acceptBid({
    required String postId,
    required String bidId,
    String? comment,
  }) async {
    try {
      final payload = <String, dynamic>{
        'comment': (comment ?? '').trim(),
      };
      debugPrint(
        '[SkillPostService] POST /skill-posts/$postId/accept-bid/$bidId',
      );
      final res = await _api.post(
        '/skill-posts/$postId/accept-bid/$bidId',
        data: payload,
      );
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> acceptOffer({
    required String postId,
    String? comment,
  }) async {
    try {
      final payload = <String, dynamic>{
        'comment': (comment ?? '').trim(),
      };
      debugPrint('[SkillPostService] POST /skill-posts/$postId/accept-offer');
      final res = await _api.post(
        '/skill-posts/$postId/accept-offer',
        data: payload,
      );
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<Map<String, dynamic>> rejectBid({
    required String postId,
    required String bidId,
    String? reason,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (reason != null && reason.trim().isNotEmpty) {
        payload['reason'] = reason.trim();
      }
      debugPrint('[SkillPostService] POST /skill-posts/$postId/bids/$bidId/reject');
      final res = await _api.post(
        '/skill-posts/$postId/bids/$bidId/reject',
        data: payload,
      );
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true};
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<PaginatedOngoingPosts> getUserSkillsPosts({
    required String status,
    required int limit,
    required int offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'status': status,
        'limit': limit,
        'offset': offset,
      };
      debugPrint(
          '[SkillPostService] GET /skill-posts/user-skills-posts?$queryParameters');
      final res = await _api.get(
        '/skill-posts/user-skills-posts',
        queryParameters: queryParameters,
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      debugPrint(
          '[SkillPostService] user-skills-posts total=${data['total']} hasMore=${data['hasMore']} posts=${(data['posts'] as List?)?.length ?? 0}');
      return PaginatedOngoingPosts.fromJson(data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<PaginatedReceivedBids> getReceivedBids({
    required int limit,
    required int offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      debugPrint('[SkillPostService] GET /skill-posts/latest-bids-on-my-posts?$queryParameters');
      final res = await _api.get(
        '/skill-posts/latest-bids-on-my-posts',
        queryParameters: queryParameters,
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      debugPrint('[SkillPostService] received-bids total=${data['total']} hasMore=${data['hasMore']} bids=${(data['bids'] as List?)?.length ?? 0}');
      return PaginatedReceivedBids.fromJson(data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }
}
