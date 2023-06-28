import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
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
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: Text("Мемогенератор",
                  style: GoogleFonts.seymourOne(fontSize: 24)),
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton.extended(
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
                label: Text("Создать")),
            backgroundColor: Colors.white,
            body: SafeArea(child: MainPageContent())),
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

class MainPageContent extends StatefulWidget {
  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: StreamBuilder<MemesWithDocsPath>(
        stream: bloc.observeMemes(),
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
                .map((item) => GridItem(
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

class GridItem extends StatelessWidget {
  final Meme item;
  final String docsPath;

  const GridItem({Key? key, required this.item, required this.docsPath})
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
