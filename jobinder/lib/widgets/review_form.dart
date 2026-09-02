import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_stars/easy_stars.dart';
import 'package:jobinder/models/review_model.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/providers/review_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReviewWidget extends StatefulWidget {
  const ReviewWidget({super.key, required this.revieweeId});

  final String revieweeId;

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  int _rating = 0;
  bool _isSending = false;
  // Workaround to reset the EasyStarsRating widget when a review is sent
  int _starsKey = 0;

  String? _errorText;

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> sendReview(int note, String comment) async {
    final reviewProvider = context.read<ReviewProvider>();

    final review = Review(
      reviewer_user: context.read<AuthProvider>().user!.uid,
      reviewee_user: widget.revieweeId,
      comment: comment,
      note: note,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isSending = true;
    });

    // Check for profanity in text
    final response = await http.post(
      Uri.parse('https://vector.profanity.dev'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': comment}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final bool isProfanity = data['isProfanity'] as bool;

      if (isProfanity) {
        if (!mounted) return;

        setState(() {
          _isSending = false;
          _errorText = 'Your review contains inappropriate language.';
        });
        return;
      }
    }

    try {
      await reviewProvider.addReview(review);

      if (!mounted) return;

      _descriptionController.clear();

      setState(() {
        _rating = 0;
        _starsKey++; // Increment key to force EasyStarsRating widget to rebuild
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _errorText = 'Failed to send review. Please try again.';
      });
    }
  }

  void submitReview() {
    final description = _descriptionController.text.trim();

    if (_rating == 0 || description.isEmpty) {
      setState(() {
        _errorText = 'Please provide a rating and a review.';
      });
      return;
    }

    sendReview(_rating, description);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Rate your experience',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // Stars rating
        Center(
          child: EasyStarsRating(
            key: ValueKey(_starsKey),
            initialRating: _rating.toDouble(),
            animateOnRatingChange: true,
            animationConfig: StarAnimationConfig.bounce,
            sizeVariant: StarSizeVariant.large,
            onRatingChanged: _isSending
                ? null
                : (value) {
                    setState(() {
                      _rating = value.round();
                      _errorText = null;
                    });
                  },
          ),
        ),

        const SizedBox(height: 20),

        // Comment
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          enabled: !_isSending,
          onChanged: (_) {
            // Clear error text when typing
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Review',
            hintText: 'Write your review...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            errorText: _errorText,
          ),
        ),

        const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : submitReview,
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit review'),
          ),
        ),
      ],
    );
  }
}
