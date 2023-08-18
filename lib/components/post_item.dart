import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(children: [
            SizedBox(
              width: 16,
            ),
            Text('sara'),
          ]),
          //Image.asset('assets/temp/b.jpg'),
          Text('Hello my name is ahmed douss')
        ],
      ),
    );
  }
}
