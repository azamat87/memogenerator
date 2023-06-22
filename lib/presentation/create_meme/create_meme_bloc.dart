import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/position.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/domain/interactors/save_meme_interactor.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class CreateMemeBloc {
  final memeTextSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject =
      BehaviorSubject<List<MemeTextOffset>>.seeded(<MemeTextOffset>[]);
  final newMemeTextOffsetSubject =
      BehaviorSubject<MemeTextOffset?>.seeded(null);
  final memePathSubject = BehaviorSubject<String?>.seeded(null);

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool?>? saveMemeSubscription;
  StreamSubscription<Meme?>? existentMemeSubscription;

  final String id;
  final String? selectedMemePath;

  CreateMemeBloc({final String? id, final this.selectedMemePath})
      : this.id = id ?? Uuid().v4() {
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemeTextOffset();
    _subscribeToExistentMeme();
  }

  void saveMeme() {
    final memeTexts = memeTextSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;
    final textsWithPosition = memeTexts.map((memeText) {
      final memeTextPosition =
          memeTextOffsets.firstWhereOrNull((memeTextOffset) {
        return memeTextOffset.id == memeText.id;
      });
      final position = Position(
          top: memeTextPosition?.offset.dy ?? 0,
          left: memeTextPosition?.offset.dx ?? 0);
      return TextWithPosition(
          id: memeText.id, text: memeText.text, position: position);
    }).toList();

    saveMemeSubscription = SaveMemeInteractor.getInstance()
        .saveMeme(
            id: id, textWithPositions: textsWithPosition, imagePath: memePathSubject.value)
        .asStream()
        .listen((event) {
      print("meme save");
    },
            onError: (error, stackTrace) =>
                print("Error in saveMemeSubs $error $stackTrace"));
  }

  void _subscribeToNewMemeTextOffset() {
    newMemeTextOffsetSubscription = newMemeTextOffsetSubject
        .debounceTime(Duration(milliseconds: 300))
        .listen((newMemeTextOffset) {
      if (newMemeTextOffset != null) {
        _changeMemeTextOffsetInternal(newMemeTextOffset);
      }
    },
            onError: (error, stackTrace) => print(
                "Error in newMemeTextOffsetSubscription $error $stackTrace"));
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
  }

  void _changeMemeTextOffsetInternal(final MemeTextOffset newMemeTextOffset) {
    final copiedMemeTextOffsets = [...memeTextOffsetsSubject.value];
    final currentMemeTextOffset = copiedMemeTextOffsets.firstWhereOrNull(
        (memeTextOffset) => memeTextOffset.id == newMemeTextOffset.id);
    if (currentMemeTextOffset != null) {
      copiedMemeTextOffsets.remove(currentMemeTextOffset);
    }
    copiedMemeTextOffsets.add(newMemeTextOffset);
    memeTextOffsetsSubject.add(copiedMemeTextOffsets);
  }

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextSubject.add([...memeTextSubject.value, newMemeText]);
    selectedMemeTextSubject.add(newMemeText);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);
    if (index == -1) {
      return;
    }
    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextSubject.add(copiedList);
  }

  void selectMemeText(final String id) {
    final foundMemeText =
        memeTextSubject.value.firstWhereOrNull((memeText) => memeText.id == id);
    selectedMemeTextSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextSubject.add(null);
  }

  Stream<List<MemeTextWithSelection>> observeMemeTextsWithSelection() =>
      Rx.combineLatest2<List<MemeText>, MemeText?, List<MemeTextWithSelection>>(
          observeMemeTexts(), observeSelectMemeText(), (a, b) {
        return a.map((element) {
          return MemeTextWithSelection(
              memeText: element, selected: element.id == b?.id);
        }).toList();
      });

  Stream<List<MemeText>> observeMemeTexts() => memeTextSubject
      .distinct((prev, next) => ListEquality().equals(prev, next));

  Stream<List<MemeTextWithOffset>> observeMemeTextWithOffset() {
    return Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>,
            List<MemeTextWithOffset>>(
        observeMemeTexts(), memeTextOffsetsSubject.distinct(),
        (memeTexts, memeTextOffsets) {
      return memeTexts.map((memeText) {
        final memeTextOffset = memeTextOffsets.firstWhereOrNull((element) {
          return element.id == memeText.id;
        });
        return MemeTextWithOffset(
            id: memeText.id,
            text: memeText.text,
            offset: memeTextOffset?.offset);
      }).toList();
    });
  }

  Stream<MemeText?> observeSelectMemeText() =>
      selectedMemeTextSubject.distinct();

  Stream<String?> observeMemePath() => memePathSubject.distinct();

  void dispose() {
    memeTextSubject.close();
    selectedMemeTextSubject.close();
    memeTextOffsetsSubject.close();
    memePathSubject.close();

    newMemeTextOffsetSubscription?.cancel();
    saveMemeSubscription?.cancel();
    existentMemeSubscription?.cancel();
  }

  void _subscribeToExistentMeme() {
    existentMemeSubscription = MemesRepository.getInstance()
        .getMeme(this.id)
        .asStream()
        .listen((meme) {
      if (meme == null) {
        return;
      }
      final memeTexts = meme.texts.map((textWithPosition) {
        return MemeText(id: textWithPosition.id, text: textWithPosition.text);
      }).toList();

      final memeTextOffsets = meme.texts.map((textWithPosition) {
        return MemeTextOffset(
            id: textWithPosition.id,
            offset: Offset(
                textWithPosition.position.left, textWithPosition.position.top));
      }).toList();
      memeTextSubject.add(memeTexts);
      memeTextOffsetsSubject.add(memeTextOffsets);
      memePathSubject.add(meme.memePath);
    },
            onError: (error, stackTrace) =>
                print("Error in saveMemeSubs $error $stackTrace"));
  }
}
