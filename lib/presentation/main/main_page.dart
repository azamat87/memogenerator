import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memogenerator/presentation/main/models/meme_thumbnail.dart';
import 'package:memogenerator/presentation/main/models/template_full.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late MainBloc bloc;
  late TabController tabController;

  double tabIndex = 0;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
    tabController = TabController(length: 2, vsync: this);

    tabController.animation?.addListener(() {
      setState(() {
        tabIndex = tabController.animation!.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitDialog(context);
          return goBack ?? false;
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: GestureDetector(
                onLongPress: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => EasterEggPage()));
                },
                child: Text("Мемогенератор",
                    style: GoogleFonts.seymourOne(fontSize: 24)),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: tabController,
                labelColor: AppColors.darkGrey,
                indicatorColor: AppColors.fuchsia,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Созданные".toUpperCase()),
                  Tab(text: "Шаблоны".toUpperCase()),
                ],
              ),
            ),
            floatingActionButton: tabIndex <= 0.5
                ? Transform.scale(
                    scale: 1 - tabIndex / 0.5,
                    child: CreateMemeFab(),
                  )
                :  Transform.scale(
              scale: (tabIndex - 0.5) / 0.5,
              child: CreateTemplateFab(),
            ),
            backgroundColor: Colors.white,
            body: TabBarView(
              controller: tabController,
              children: [
                SafeArea(child: CreatedMemesGrid()),
                SafeArea(child: TemplatesGrid()),
              ],
            )),
      ),
    );
  }

  Future<bool?> showConfirmationExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Точно хотите выйти?"),
            content: Text("Мемы сами себя не сделают"),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16),
            actions: [
              AppButton(
                onTap: () => Navigator.of(context).pop(false),
                text: "Остаться",
                color: AppColors.darkGrey,
              ),
              AppButton(
                onTap: () => Navigator.of(context).pop(true),
                text: "Выйти",
                color: AppColors.darkGrey,
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
    tabController.dispose();
  }
}

class CreateMemeFab extends StatelessWidget {
  const CreateMemeFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
        onPressed: () async {
          final selectedMemePath = await bloc.selectMeme();
          if (selectedMemePath == null) {
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateMemePage(
                    selectedMemePath: selectedMemePath,
                  )));
        },
        backgroundColor: AppColors.fuchsia,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text("Мем"));
  }
}

class CreateTemplateFab extends StatelessWidget {
  const CreateTemplateFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
        onPressed: () async {
          await bloc.addToTemplates();
        },
        backgroundColor: AppColors.fuchsia,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text("Шаблон"));
  }
}

class CreatedMemesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: StreamBuilder<List<MemeThumbnail>>(
        stream: bloc.observeMemes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final items = snapshot.requireData;

          return GridView.extent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: items
                .map((item) => MemeGridItem(
                      memeThumbnail: item))
                .toList(),
          );
        },
      ),
    );
  }
}

class TemplatesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: StreamBuilder<List<TemplateFull>>(
        stream: bloc.observeTemplates(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final templates = snapshot.requireData;

          return GridView.extent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: templates
                .map((template) => TemplateGridItem(template: template))
                .toList(),
          );
        },
      ),
    );
  }
}

class MemeGridItem extends StatelessWidget {
  final MemeThumbnail memeThumbnail;

  const MemeGridItem({Key? key, required this.memeThumbnail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File(memeThumbnail.fullImageUrl);
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return CreateMemePage(id: memeThumbnail.memeId);
        }));
      },
      child: Stack(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkGrey, width: 1)),
              child: imageFile.existsSync()
                  ? Image.file(
                      File(memeThumbnail.fullImageUrl))
                  : Text(memeThumbnail.memeId)),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              itemName: "мем",
              onDelete: () {
                bloc.deleteMeme(memeThumbnail.memeId);
              },
            ),
          )
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final String itemName;
  final VoidCallback onDelete;

  const DeleteButton({Key? key, required this.onDelete, required this.itemName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final delete = await showConfirmationDeleteDialog(context) ?? false;
        if (delete) {
          onDelete();
        }
      },
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        decoration:
            BoxDecoration(color: AppColors.darkGrey38, shape: BoxShape.circle),
        child: Icon(Icons.delete_outline, size: 24, color: Colors.white),
      ),
    );
  }

  Future<bool?> showConfirmationDeleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Удалить $itemName?"),
            content: Text("Выбранный $itemName будет удалён навсегда"),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16),
            actions: [
              AppButton(
                onTap: () => Navigator.of(context).pop(false),
                text: "Отмена",
                color: AppColors.darkGrey,
              ),
              AppButton(
                onTap: () => Navigator.of(context).pop(true),
                text: "Удалить",
                color: AppColors.darkGrey,
              ),
            ],
          );
        });
  }
}

class TemplateGridItem extends StatelessWidget {
  final TemplateFull template;

  const TemplateGridItem({Key? key, required this.template}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File(template.fullImagePath);
    final bloc = Provider.of<MainBloc>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CreateMemePage(
                  selectedMemePath: template.fullImagePath,
                )));
      },
      child: Stack(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkGrey, width: 1)),
              child: imageFile.existsSync()
                  ? Image.file(imageFile)
                  : Text(template.id)),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              itemName: "шаблон",
              onDelete: () {
                bloc.deleteTemplate(template.id);
              },
            ),
          )
        ],
      ),
    );
  }
}
