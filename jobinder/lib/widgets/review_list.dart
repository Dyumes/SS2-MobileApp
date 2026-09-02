import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:jobinder/models/appuser_model.dart';
import 'package:jobinder/models/review_model.dart';
import 'package:jobinder/repositories/firestore_user_repository.dart';
import 'package:jobinder/repositories/user_repository.dart';

class ReviewList extends StatefulWidget {
  final List<Review> reviews;
  final UserRepository? userRepository;

  const ReviewList({
    super.key,
    required this.reviews,
    this.userRepository,
  });

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late final UserRepository _userRepository =
      widget.userRepository ?? FirestoreUserRepository();

  final Map<String, AppUser> _users = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final userIds = widget.reviews
        .map((review) => review.reviewer_user)
        .where((uid) => uid.isNotEmpty)
        .toSet();

    print('USER IDS: $userIds');

    for (final uid in userIds) {
      final user = await _userRepository.getUser(uid);

      if (user != null && mounted) {
        setState(() {
          _users[uid] = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final review = widget.reviews[index];

        return _ReviewItem(
          review: review,
          user: _users[review.reviewer_user],
        );
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  final AppUser? user;

  const _ReviewItem({
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
                          color: Colors.grey.shade600,
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