import 'package:flutter/material.dart';

class Like extends StatefulWidget {
  final int likeCount;
  final VoidCallback onLike;
  final bool hasLiked;

  const Like({
    super.key,
    required this.likeCount,
    required this.onLike,
    required this.hasLiked,
  });

  @override
  _LikeState createState() => _LikeState();
}

class _LikeState extends State<Like> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLike() {
    _controller.forward();
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleLike,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: widget.hasLiked ? Colors.blue : Colors.grey,
              size: 24.0,
            ),
          ),
        ),
        Text(
          '${widget.likeCount}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
