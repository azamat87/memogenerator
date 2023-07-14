import 'dart:io';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/data/repositories/template_repository.dart';
import 'package:memogenerator/domain/interactors/screenshot_interactor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/text_with_position.dart';
import 'copy_uniqe_file_interactor.dart';

class SaveTemplateInteractor {
  static SaveTemplateInteractor? _instance;

  static const templatesPathName = "templates";

  factory SaveTemplateInteractor.getInstance() =>
      _instance ??= SaveTemplateInteractor._internal();

  SaveTemplateInteractor._internal();

  Future<bool> saveTemplate({
    required final String imagePath,
  }) async {

    final newImagePath = await CopyUniqueFileInteractor.getInstance()
        .copyUniqueFile(directoryWithFiles: templatesPathName,
        filePath: imagePath);
    final template = Template(id: Uuid().v4(), imageUrl: newImagePath);
    return TemplatesRepository.getInstance().addToTemplates(template);
  }

}
