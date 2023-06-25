import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class FontSettingBottomSheet extends StatefulWidget {
  final MemeText memeText;

  const FontSettingBottomSheet({super.key, required this.memeText});

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingBottomSheetState();
}

class _FontSettingBottomSheetState extends State<FontSettingBottomSheet> {
  late double fontSize;
  late Color color;

  @override
  void initState() {
    super.initState();
      fontSize = widget.memeText.fontSize;
      color = widget.memeText.color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                  color: AppColors.darkGrey38,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          MemeTextOnCanvas(
            parentConstraints: BoxConstraints.expand(),
            selected: true,
            padding: 8,
            text: widget.memeText.text,
            fontSize: fontSize,
            color: color,
          ),
          const SizedBox(
            height: 48,
          ),
          FontSizeSlider(
            initialFontSize: fontSize,
            changeFontSize: (value) {
              setState(() {
                fontSize = value;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          ColorSelection(changeColor: (color) {
            setState(() {
              this.color = color;
            });
          }),
          const SizedBox(
            height: 36,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Buttons(color: color, fontSize: fontSize, textId: widget.memeText.id,),
          ),
          const SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }
}

class Buttons extends StatelessWidget {

  final Color color;
  final double fontSize;
  final String textId;

  const Buttons({Key? key, required this.color, required this.fontSize, required this.textId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Row(
      children: [
        AppButton(onTap: () {
          Navigator.of(context).pop();
        }, text: "Отмена",color: AppColors.darkGrey,),
        const SizedBox(
          width: 24,
        ),
        AppButton(onTap: () {
          bloc.changeFontSettings(textId, color, fontSize);
          Navigator.of(context).pop();
        }, text: "Сохранить"),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}


class ColorSelection extends StatelessWidget {
  final ValueChanged<Color> changeColor;

  const ColorSelection({Key? key, required this.changeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          width: 16,
        ),
        Text(
          "Color",
          style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
        ),
        ColorSelectionBox(changeColor: changeColor, color: Colors.white),
        const SizedBox(
          width: 16,
        ),
        ColorSelectionBox(changeColor: changeColor, color: Colors.black),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  final ValueChanged<Color> changeColor;
  final Color color;

  const ColorSelectionBox(
      {Key? key, required this.changeColor, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        changeColor(color);
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
            color: color, border: Border.all(color: Colors.black, width: 1)),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  const FontSizeSlider({Key? key, required this.changeFontSize, required this.initialFontSize})
      : super(key: key);

  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "Size",
            style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 16,
              max: 32,
              divisions: 10,
              label: fontSize.round().toString(),
              value: fontSize,
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
