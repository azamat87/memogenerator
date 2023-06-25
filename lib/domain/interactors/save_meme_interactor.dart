import 'dart:io';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/domain/interactors/screenshot_interactor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';
import 'package:screenshot/screenshot.dart';
import '../../data/models/text_with_position.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;

  static const memesPathName = "memes";

  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    required final ScreenshotController screenshotController,
    final String? imagePath,
  }) async {
    if (imagePath == null) {
      final meme = Meme(id: id, texts: textWithPositions);
      return MemesRepository.getInstance().addToMemes(meme);
    }
    await ScreenshotInteractor.getInstance().saveThumbnail(id, screenshotController);
    await createNewFile(imagePath);
    final meme = Meme(id: id, texts: textWithPositions, memePath: imagePath);
    return MemesRepository.getInstance().addToMemes(meme);
  }

  Future<void> createNewFile(final String imagePath) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}$memesPathName";
    final directory = Directory(memePath);
    await directory.create(recursive: true);

    final files = directory.listSync();

    final imageName = _getFileNameByPath(imagePath);
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final oldFile = files.firstWhereOrNull((element) =>
        _getFileNameByPath(element.path) == imageName && element is File);

    final tempFile = File(imagePath);
    if (oldFile == null) {
      await tempFile.copy(newImagePath);
      return;
    }
    final oldFileLength = await (oldFile as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return;
    }
    final index = imageName.lastIndexOf(".");
    if (index == -1) {
      await tempFile.copy(newImagePath);
      return;
    }
    final fileType = imageName.substring(index);
    final imageNameNew = imageName.substring(0, index);
    final indexLast = imageNameNew.lastIndexOf("_");
    if (indexLast == -1) {
      final newImagePath =
          "$memePath${Platform.pathSeparator}${imageNameNew}_1$fileType";
      await tempFile.copy(newImagePath);
      return ;
    } else {
      final number = imageNameNew.substring(indexLast + 1);
      final numInt = int.tryParse(number);
      if (numInt == null) {
        final newImagePath =
            "$memePath${Platform.pathSeparator}${imageNameNew}_1$fileType";
        await tempFile.copy(newImagePath);
      } else {
        final imageName = imageNameNew.substring(0, indexLast);
        final newImagePath =
            "$memePath${Platform.pathSeparator}${imageName}_${numInt + 1}$fileType";
        await tempFile.copy(newImagePath);
      }
    }
  }

  String _getFileNameByPath(String imagePath) {
    return imagePath.split(Platform.pathSeparator).last;
  }
}
