import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?>
      post; // Specify the data type for the 'post' parameter

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final userId = post['user_id'];
    final postContent = post['content'];
    final String? imageUrl = post['image_url'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Title(
            color: Colors.black,
            child: Text('User ID: $userId'),
          ),
          Text(postContent),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl, // Display image if URL exists and is not empty
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
