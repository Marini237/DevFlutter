import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../provider/comment_provider.dart';
import '../provider/like_provider.dart';
import '../provider/share_provider.dart';
import '../components/interactions/like.dart';
import '../components/interactions/comment.dart';
import '../components/interactions/share.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.owner.username)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.post.owner.avatar),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.post.owner.username,
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.post.content ?? 'No content',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  if (widget.post.image != null)
                    Image.network(widget.post.image!),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Consumer<LikeProvider>(
                        builder: (context, likeProvider, _) {
                          final likeCount =
                              likeProvider.getLikeCount(widget.post.hashCode);
                          final hasLiked = likeProvider.hasLiked(
                              widget.post.hashCode, 'currentUserId');
                          return Like(
                            likeCount: likeCount,
                            onLike: () => likeProvider.toggleLike(
                                widget.post.hashCode, 'currentUserId'),
                            hasLiked: hasLiked,
                          );
                        },
                      ),
                      Consumer<CommentProvider>(
                        builder: (context, commentProvider, _) {
                          final commentCount = commentProvider
                              .getComments(widget.post.hashCode)
                              .length;
                          return Comment(
                            commentCount: commentCount,
                            onComment: () {
                              // Focus on the comment input field
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          );
                        },
                      ),
                      Consumer<ShareProvider>(
                        builder: (context, shareProvider, _) {
                          final shareCount =
                              shareProvider.getShareCount(widget.post.hashCode);
                          return Share(
                            shareCount: shareCount,
                            onShare: () {
                              shareProvider.addShare(widget.post.hashCode);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Post partagé avec succès !')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Comments:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            _buildCommentSection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildCommentInputField(context),
    );
  }

  Widget _buildCommentSection(BuildContext context) {
    return Consumer<CommentProvider>(
      builder: (context, commentProvider, _) {
        final comments = commentProvider.getComments(widget.post.hashCode);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(comment.owner.avatar),
              ),
              title: Text(comment.content ?? 'No content'),
              subtitle: Text(comment.owner.username),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<LikeProvider>(
                    builder: (context, likeProvider, _) {
                      final likeCount =
                          likeProvider.getLikeCount(comment.hashCode);
                      final hasLiked = likeProvider.hasLiked(
                          comment.hashCode, 'currentUserId');
                      return Like(
                        likeCount: likeCount,
                        onLike: () => likeProvider.toggleLike(
                            comment.hashCode, 'currentUserId'),
                        hasLiked: hasLiked,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      _showCommentDialog(context, comment);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInputField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                final newComment = Post(
                  owner: widget.post.owner,
                  content: _commentController.text,
                );
                Provider.of<CommentProvider>(context, listen: false)
                    .addComment(widget.post.hashCode, newComment);
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context, Post comment) {
    final TextEditingController _replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to ${comment.owner.username}'),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(
              hintText: 'Add a reply...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_replyController.text.isNotEmpty) {
                  final newReply = Post(
                    owner: widget.post.owner,
                    content: _replyController.text,
                  );
                  Provider.of<CommentProvider>(context, listen: false)
                      .addComment(comment.hashCode, newReply);
                  _replyController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }
}
