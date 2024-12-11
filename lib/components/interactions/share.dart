import 'package:flutter/material.dart';

class Share extends StatelessWidget {
  final int shareCount;
  final VoidCallback onShare;

  const Share({
    super.key,
    required this.onShare,
    required this.shareCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      IconButton(
        onPressed: onShare,
        icon: const Icon(Icons.share),
        tooltip: "Share",
      ),
      Text('$shareCount'),
    ]);
  }
}
