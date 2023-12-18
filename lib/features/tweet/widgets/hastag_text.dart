import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone/features/tweet/view/hashtag_view.dart';
import 'package:twitter_clone/theme/pallete.dart';

class HashTagText extends StatelessWidget {
  final String text;
  const HashTagText({Key? key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textspans = [];
    text.split(' ').forEach(
      (element) {
        if (element.startsWith("#")) {
          textspans.add(
            TextSpan(
              text: '$element ',
              style: const TextStyle(
                color: Pallete.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    HashtagView.route(element),
                  );
                },
            ),
          );
        } else if (element.startsWith("www.") ||
            element.startsWith("https://")) {
          textspans.add(
            TextSpan(
              text: '$element ',
              style: const TextStyle(
                color: Pallete.blueColor,
                fontSize: 18,
              ),
            ),
          );
        } else {
          textspans.add(
            // This was missing in your code
            TextSpan(
              text: '$element ',
              style: const TextStyle(fontSize: 18, color: Pallete.whiteColor),
            ),
          );
        }
      },
    );
    print(textspans.toString());
    return RichText(
      text: TextSpan(children: textspans),
    );
  }
}
