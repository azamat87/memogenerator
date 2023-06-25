
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotInteractor {

  static ScreenshotInteractor? _instance;

  factory ScreenshotInteractor.getInstance() => _instance ??= ScreenshotInteractor._internal();

  ScreenshotInteractor._internal();

  Future<void> shareScreenshot(final Future<Uint8List?> captureScreenshot) async {

    final image = await captureScreenshot;

    if (image == null) {

      return;
    }
    final tempDocs = await getTemporaryDirectory();
    final imageFile = File("${tempDocs.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.png");

    await imageFile.create();
    await imageFile.writeAsBytes(image);
    await Share.share(imageFile.path);

  }

  Future<void> saveThumbnail(final String memeId, final ScreenshotController controller) async {

    final image = await controller.capture();

    if (image == null) {

      return;
    }
    final tempDocs = await getApplicationDocumentsDirectory();
    final imageFile = File("${tempDocs.path}${Platform.pathSeparator}$memeId.png");

    await imageFile.create();
    await imageFile.writeAsBytes(image);
  }

}