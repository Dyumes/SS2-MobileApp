import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/review_model.dart';
import 'package:jobinder/providers/review_provider.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';
import 'package:provider/provider.dart';

class ReviewList extends StatelessWidget {
  final String revieweeId;

  const ReviewList({
    super.key,
    required this.revieweeId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: context
          .read<ReviewProvider>()
          .getReviewsForAUser(revieweeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reviews: ${snapshot.error}',
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Center(
            child: Text('No reviews yet.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int index = 0; index < reviews.length; index++) ...[
              if (index > 0) const SizedBox(height: 24),
              _ReviewItem(review: reviews[index]),
            ],
          ],
        );
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;

  const _ReviewItem({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository = FirestoreUserRepository();

    return FutureBuilder<AppUser?>(
      future: userRepository.getUser(review.reviewer_user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        return _ReviewContent(
          review: review,
          user: user,
        );
      },
    );
  }
}

class _ReviewContent extends StatelessWidget {
  final Review review;
  final AppUser? user;

  const _ReviewContent({
    required this.review,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final reviewerName = user == null
        ? 'Unknown user'
        : '${user!.name} ${user!.surname}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(
                user != null && user!.name.isNotEmpty
                    ? user!.name[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reviewerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _RatingStars(note: review.note),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(review.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          review.comment,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _RatingStars extends StatelessWidget {
  final int note;

  const _RatingStars({
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return EasyStarsRating(
      initialRating: note.toDouble(),
      readOnly: true,
      animateOnRatingChange: true,
      animationConfig: StarAnimationConfig.bounce,
      sizeVariant: StarSizeVariant.small,
    );
  }
}