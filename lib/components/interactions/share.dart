import 'package:flutter/material.dart';

class Share extends StatelessWidget {
  final int shareCount;
  final VoidCallback onShare;
  final bool isEnabled; // Pour activer/désactiver le bouton
  final Color activeColor;
  final Color inactiveColor;
  final double iconSize;

  const Share({
    super.key,
    required this.onShare,
    required this.shareCount,
    this.isEnabled = true,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: isEnabled ? onShare : null,
          icon: Icon(
            Icons.share,
            color: isEnabled ? activeColor : inactiveColor,
            size: iconSize,
          ),
          tooltip: "Share",
        ),
        Text(
          '$shareCount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isEnabled ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}
