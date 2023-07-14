import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
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

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
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
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.lemon,
                foregroundColor: AppColors.darkGrey,
                title: GestureDetector(
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EasterEggPage()));
                  },
                  child: Text("Мемогенератор",
                      style: GoogleFonts.seymourOne(fontSize: 24)),
                ),
                centerTitle: true,
                bottom: TabBar(
                  labelColor: AppColors.darkGrey,
                  indicatorColor: AppColors.fuchsia,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: "Созданные".toUpperCase()),
                    Tab(text: "Шаблоны".toUpperCase()),
                  ],
                ),
              ),
              floatingActionButton: CreateMemeFab(),
              backgroundColor: Colors.white,
              body: TabBarView(
                children: [
                  SafeArea(child: CreatedMemesGrid()),
                  SafeArea(child: TemplatesGrid()),
                ],
              )),
        ),
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
        label: Text("Создать"));
  }
}


class CreatedMemesGrid extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: StreamBuilder<MemesWithDocsPath>(
        stream: bloc.observeMemesWithDocsPath(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final items = snapshot.requireData.memes;
          final docsPath = snapshot.requireData.docsPath;

          return GridView.extent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: items
                .map((item) => MemeGridItem(
                      item: item,
                      docsPath: docsPath,
                    ))
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
                .map((template) => TemplateGridItem(
              template: template
            ))
                .toList(),
          );
        },
      ),
    );
  }
}

class MemeGridItem extends StatelessWidget {
  final Meme item;
  final String docsPath;

  const MemeGridItem({Key? key, required this.item, required this.docsPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File("$docsPath${Platform.pathSeparator}${item.id}.png");

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return CreateMemePage(id: item.id);
        }));
      },
      child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey, width: 1)),
          child: imageFile.existsSync()
              ? Image.file(
                  File("$docsPath${Platform.pathSeparator}${item.id}.png"))
              : Text(item.id)),
    );
  }
}

class TemplateGridItem extends StatelessWidget {
  final TemplateFull template;

  const TemplateGridItem({Key? key, required this.template})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File(template.fullImagePath);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CreateMemePage(
              selectedMemePath: template.fullImagePath,
            )));
      },
      child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey, width: 1)),
          child: imageFile.existsSync()
              ? Image.file(imageFile)
              : Text(template.id)),
    );
  }
}
