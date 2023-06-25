import 'package:flutter/widgets.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

import '../create_meme/create_meme_bloc.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData? icon;
  final Color color;

  const AppButton(
      {Key? key,
      required this.onTap,
      required this.text,
      this.icon,
      this.color = AppColors.fuchsia})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: color,
              ),
            Text(
              text.toUpperCase(),
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
