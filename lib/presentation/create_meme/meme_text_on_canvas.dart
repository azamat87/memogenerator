import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memogenerator/resources/app_colors.dart';

class MemeTextOnCanvas extends StatelessWidget {
  final BoxConstraints parentConstraints;
  final bool selected;
  final double padding;
  final String text;
  final double fontSize;
  final Color color;

  const MemeTextOnCanvas({Key? key,
    required this.parentConstraints,
    required this.selected,
    required this.padding,
    required this.text,
    required this.fontSize,
    required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: parentConstraints.maxWidth,
          maxHeight: parentConstraints.maxHeight),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          color: selected ? AppColors.darkGrey16 : null,
          border: Border.all(
              color: selected ? AppColors.fuchsia : Colors.transparent,
              width: 1)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
    );
  }
}
