import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class CopyUniqueFileInteractor {

  static CopyUniqueFileInteractor? _instance;

  static const templatesPathName = "templates";

  factory CopyUniqueFileInteractor.getInstance() =>
      _instance ??= CopyUniqueFileInteractor._internal();

  CopyUniqueFileInteractor._internal();

  Future<String> copyUniqueFile({required final String directoryWithFiles,
    required final String filePath}) async {

    final docsPath = await getApplicationDocumentsDirectory();
    final memePath =
        "${docsPath.absolute.path}${Platform.pathSeparator}$directoryWithFiles";
    final directory = Directory(memePath);
    await directory.create(recursive: true);

    final files = directory.listSync();

    final imageName = _getFileNameByPath(filePath);
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final oldFileWithTheSameName = files.firstWhereOrNull((element) =>
    _getFileNameByPath(element.path) == imageName && element is File);

    final tempFile = File(filePath);
    if (oldFileWithTheSameName == null) {
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return imageName;
    }
    final index = imageName.lastIndexOf(".");
    if (index == -1) {
      await tempFile.copy(newImagePath);
      return imageName;
    }
    final fileType = imageName.substring(index);
    final imageNameNew = imageName.substring(0, index);
    final indexLast = imageNameNew.lastIndexOf("_");
    if (indexLast == -1) {
      final newImageName = "${imageNameNew}_1$fileType";
      final newImagePath =
          "$memePath${Platform.pathSeparator}${imageNameNew}_1$fileType";
      await tempFile.copy(newImagePath);
      return newImageName;
    } else {
      final number = imageNameNew.substring(indexLast + 1);
      final numInt = int.tryParse(number);
      if (numInt == null) {
        final newImageName = "${imageNameNew}_1$fileType";
        final newImagePath =
            "$memePath${Platform.pathSeparator}${imageNameNew}";
        await tempFile.copy(newImagePath);
        return newImageName;
      }
      final imageName = imageNameNew.substring(0, indexLast);
      final newImageName = "${imageName}_${numInt + 1}$fileType";
      final newImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(newImagePath);
      return newImageName;
    }

  }

  String _getFileNameByPath(String filePath) {
    return filePath.split(Platform.pathSeparator).last;
  }

}
