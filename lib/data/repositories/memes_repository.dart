import 'dart:convert';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class MemesRepository {
  final update = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() =>
      _instance ??
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme newMeme) async {
    final memes = await getMemes();
    final memeIndex = memes.indexWhere((element) => newMeme.id == element.id);
    if (memeIndex == -1) {
      memes.add(newMeme);
    } else {
      memes.removeAt(memeIndex);
      memes.insert(memeIndex, newMeme);
    }
    return _setMemes(memes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final memes = await getMemes();
    memes.removeWhere((element) => element.id == id);

    return _setMemes(memes);
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await getMemes();

    return memes.firstWhereOrNull((meme) => meme.id == id);
  }

  Future<List<Meme>> getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map((rawMeme) => Meme.fromJson(json.decode(rawMeme)))
        .toList();
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await getMemes();
    await for (final _ in update) {
      yield await getMemes();
    }
  }

  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes.map((e) => json.encode(e.toJson())).toList();
    return _setRawMemes(rawMemes);
  }

  Future<bool> _setRawMemes(List<String> rawMemes) async {
    update.add(null);
    return spData.setMemes(rawMemes);
  }

  Future<List<String>> _getRawMemes() async {
    return spData.getMemes();
  }
}
