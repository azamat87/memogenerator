import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class CreateMemePage extends StatefulWidget {
  // final http.Client? client;
  //
  // CreateMemePage({Key? key, this.client}) : super(key: key);
  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: Text("Создаем мем"),
            bottom: EditTextBar(),
          ),
          backgroundColor: Colors.white,
          body: SafeArea(child: CreateMemePageContent())),
    );
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({super.key});

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText = snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }

            return TextField(
              enabled: selectedMemeText != null,
              controller: controller,
              onChanged: (text) {
                if (selectedMemeText != null) {
                  bloc.changeMemeText(
                      selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              decoration:
                  InputDecoration(filled: true, fillColor: AppColors.darkGrey6),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  @override
  State<CreateMemePageContent> createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MemeCanvasWidget(),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.darkGrey,
        ),
        Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  AddNewMemeTextButton()
                ],
              ),
            ))
      ],
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final block = Provider.of<CreateMemeBloc>(context, listen: false);
    return Expanded(
        flex: 2,
        child: Container(
          color: AppColors.darkGrey38,
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<MemeText>>(
                  initialData: const <MemeText>[],
                  stream: block.observeMemeTexts(),
                  builder: (context, snapshot) {
                    final memeTexts =
                        snapshot.hasData ? snapshot.data! : const <MemeText>[];

                    return LayoutBuilder(builder: (context, constraints) {
                      return Stack(
                        children: memeTexts.map((memeText) {
                          return DraggableMemeText(
                            memeText: memeText,
                            parentConstraints: constraints,
                          );
                        }).toList(),
                      );
                    });
                  }),
            ),
          ),
        ));
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText(
      {Key? key, required this.memeText, required this.parentConstraints})
      : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  double top = 0;
  double left = 0;
  final double padding = 8;

  @override
  Widget build(BuildContext context) {
    final block = Provider.of<CreateMemeBloc>(context, listen: false);
    return Positioned(
      top: top,
      left: left,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: widget.parentConstraints.maxWidth,
            maxHeight: widget.parentConstraints.maxHeight),
        padding: EdgeInsets.all(padding),
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              setState(() {
                left = calculateLeft(details);
                top = calculateTop(details);
              });
            },
            onTap: () => block.selectMemeText(widget.memeText.id),
            child: Text(
              widget.memeText.text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 24),
            )),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }

    return rawLeft;
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final block = Provider.of<CreateMemeBloc>(context, listen: false);

    return GestureDetector(
      onTap: () => block.addNewText(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppColors.fuchsia,
              ),
              Text(
                "Добавить текст".toUpperCase(),
                style: TextStyle(
                    color: AppColors.fuchsia,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}
