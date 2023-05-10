import 'package:flutter/widgets.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
  });
  final Color? color;
  final String? text;
  final bool? isSquare;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare == true ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
