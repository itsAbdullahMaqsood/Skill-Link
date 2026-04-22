import 'package:skilllink/skillink/domain/models/review.dart';

class SampleReviews {
  SampleReviews._();

  static List<Review> _demoReviewsForNewWorkers(DateTime base) => [
        Review(
          id: 'r_001_1',
          jobId: 'j_100',
          rating: 5,
          comment:
              'Bilal fixed a tripping circuit in 20 minutes. Clean work, '
              'explained everything.',
          createdAt: base.subtract(const Duration(days: 4)),
          reviewerName: 'Asad R.',
        ),
        Review(
          id: 'r_001_2',
          jobId: 'j_101',
          rating: 5,
          comment: 'On time, fair price, and very professional.',
          createdAt: base.subtract(const Duration(days: 18)),
          reviewerName: 'Noor F.',
        ),
        Review(
          id: 'r_001_3',
          jobId: 'j_102',
          rating: 4,
          comment: 'Good job, had to come back once for a loose connection.',
          createdAt: base.subtract(const Duration(days: 42)),
          reviewerName: 'Sadia K.',
        ),
      ];

  static List<Review> forWorker(String workerId) {
    final base = DateTime.now();
    final demoFallback = _demoReviewsForNewWorkers(base);
    return switch (workerId) {
      'w_001' => demoFallback,
      'w_002' => [
          Review(
            id: 'r_002_1',
            jobId: 'j_103',
            rating: 5,
            comment: 'Came within an hour and fixed the kitchen leak.',
            createdAt: base.subtract(const Duration(days: 6)),
            reviewerName: 'Omar S.',
          ),
          Review(
            id: 'r_002_2',
            jobId: 'j_104',
            rating: 4,
            comment: 'Solid work. A bit pricey but worth it.',
            createdAt: base.subtract(const Duration(days: 23)),
            reviewerName: 'Hina M.',
          ),
        ],
      'w_003' => [
          Review(
            id: 'r_003_1',
            jobId: 'j_105',
            rating: 5,
            comment: 'Serviced both AC units and explained maintenance tips. '
                'Highly recommend.',
            createdAt: base.subtract(const Duration(days: 2)),
            reviewerName: 'Fatima Z.',
          ),
          Review(
            id: 'r_003_2',
            jobId: 'j_106',
            rating: 5,
            comment: 'Best HVAC tech I\'ve used.',
            createdAt: base.subtract(const Duration(days: 14)),
            reviewerName: 'Shahid A.',
          ),
          Review(
            id: 'r_003_3',
            jobId: 'j_107',
            rating: 5,
            comment: 'Very thorough. Found a gas leak that two others missed.',
            createdAt: base.subtract(const Duration(days: 31)),
            reviewerName: 'Mariam I.',
          ),
        ],
      'w_004' => [
          Review(
            id: 'r_004_1',
            jobId: 'j_108',
            rating: 4,
            comment: 'Fitted a new wardrobe door. Happy with the finish.',
            createdAt: base.subtract(const Duration(days: 9)),
            reviewerName: 'Zain H.',
          ),
        ],
      _ => demoFallback,
    };
  }
}
