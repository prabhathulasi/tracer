import 'package:flutter/cupertino.dart';

class AppRichText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? align;
  const AppRichText({super.key, this.style, this.text, this.align});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: align ?? TextAlign.left,
      text: TextSpan(text: text, style: style),
    );
  }
}
