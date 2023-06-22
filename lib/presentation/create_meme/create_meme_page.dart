import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class CreateMemePage extends StatefulWidget {
  final String? id;
  final String? selectedMemePath;

  CreateMemePage({Key? key, this.id, this.selectedMemePath}) : super(key: key);

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc(
        id: widget.id, selectedMemePath: widget.selectedMemePath);
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
            actions: [
              GestureDetector(
                onTap: () {
                  bloc.saveMeme();
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.save,
                      color: AppColors.darkGrey,
                    )),
              )
            ],
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
            final MemeText? selectedMemeText =
            snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            final isSelected = selectedMemeText != null;
            return TextField(
              enabled: selectedMemeText != null,
              controller: controller,
              onChanged: (text) {
                if (selectedMemeText != null) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              cursorColor: AppColors.fuchsia,
              decoration: InputDecoration(
                  filled: true,
                  hintText: isSelected ? "Ввести текст" : null,
                  hintStyle:
                  TextStyle(fontSize: 16, color: AppColors.darkGrey38),
                  fillColor:
                  isSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
                  disabledBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.darkGrey38, width: 1)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.fuchsia38, width: 1)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: AppColors.fuchsia, width: 2))),
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
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

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
              child: StreamBuilder<List<MemeTextWithSelection>>(
                  stream: bloc.observeMemeTextsWithSelection(),
                  initialData: [],
                  builder: (context, snapshot) {
                    final items = snapshot.hasData
                        ? snapshot.data!
                        : const <MemeTextWithSelection>[];

                    return ListView.separated(
                      itemCount: items.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return AddNewMemeTextButton();
                        }
                        final item = items[index - 1];
                        return Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          color: item.selected ? AppColors.darkGrey16 : null,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item.memeText.text,
                            style: TextStyle(
                                color: AppColors.darkGrey, fontSize: 16),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          height: 1,
                          color: AppColors.darkGrey,
                          margin: const EdgeInsets.only(left: 16),
                        );
                      },
                    );
                  }),
            ))
      ],
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Expanded(
        flex: 2,
        child: Container(
          color: AppColors.darkGrey38,
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          child: AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: () => bloc.deselectMemeText(),
              child: Stack(
                  children: [
                    StreamBuilder<String?>(
                      stream: bloc.observeMemePath(),
                      builder: (context, snapshot) {
                        final path = snapshot.hasData ? snapshot.data : null;
                        if (path == null) {
                          return Container(
                            color: Colors.white,);
                        }
                        return Image.file(File(path));
                      },
                    ),
                    StreamBuilder<List<MemeTextWithOffset>>(
                        initialData: const <MemeTextWithOffset>[],
                        stream: bloc.observeMemeTextWithOffset(),
                        builder: (context, snapshot) {
                          final memeTextWithOffsets = snapshot.hasData
                              ? snapshot.data!
                              : const <MemeTextWithOffset>[];

                          return LayoutBuilder(builder: (context, constraints) {
                            return Stack(
                              children:
                              memeTextWithOffsets.map((memeTextWithOffset) {
                                return DraggableMemeText(
                                  memeTextWithOffset: memeTextWithOffset,
                                  parentConstraints: constraints,
                                );
                              }).toList(),
                            );
                          });
                        }),
                  ]
              ),
            ),
          ),
        ));
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeTextWithOffset memeTextWithOffset;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({Key? key,
    required this.memeTextWithOffset,
    required this.parentConstraints})
      : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;

  @override
  void initState() {
    super.initState();
    top = widget.memeTextWithOffset.offset?.dy ??
        widget.parentConstraints.maxHeight / 2;
    left = widget.memeTextWithOffset.offset?.dx ??
        widget.parentConstraints.maxWidth / 2;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            bloc.selectMemeText(widget.memeTextWithOffset.id);
            setState(() {
              left = calculateLeft(details);
              top = calculateTop(details);
              bloc.changeMemeTextOffset(
                  widget.memeTextWithOffset.id, Offset(left, top));
            });
          },
          onTap: () => bloc.selectMemeText(widget.memeTextWithOffset.id),
          child: StreamBuilder<MemeText?>(
              stream: bloc.observeSelectMemeText(),
              builder: (context, snapshot) {
                final selectedItem = snapshot.hasData ? snapshot.data : null;
                final selected =
                    widget.memeTextWithOffset.id == selectedItem?.id;
                return MemeTextOnCanvas(
                    parentConstraints: widget.parentConstraints,
                    selected: selected,
                    padding: padding,
                    text: widget.memeTextWithOffset.text);
              })),
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

class MemeTextOnCanvas extends StatelessWidget {
  final BoxConstraints parentConstraints;
  final bool selected;
  final double padding;
  final String text;

  const MemeTextOnCanvas({Key? key,
    required this.parentConstraints,
    required this.selected,
    required this.padding,
    required this.text})
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
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
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
