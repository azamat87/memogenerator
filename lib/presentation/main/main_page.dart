import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
    );
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
      child: StreamBuilder<List<Meme>>(
        stream: bloc.observeMemes(),
        initialData: <Meme>[],
        builder: (context, snapshot) {
          final items = snapshot.hasData ? snapshot.data! : <Meme>[];

          return ListView(
            children: items
                .map((item) => GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return CreateMemePage(id: item.id);
                        }));
                      },
                      child: Container(
                          height: 48,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(item.id)),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
