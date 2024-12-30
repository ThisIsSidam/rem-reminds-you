import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sounds_provider.g.dart';

@riverpod
class SoundsNotifier extends _$SoundsNotifier {
  @override
  Future<List<FileSystemEntity>> build() {
    return getSoundFiles();
  }

  Future<List<FileSystemEntity>> getSoundFiles() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory soundsDir = Directory(path.join(appDir.path, 'sounds'));

    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }

    return soundsDir.listSync();
  }

  Future<void> deleteSound(
    FileSystemEntity file,
  ) async {
    await file.delete();
    state = const AsyncValue.loading();
    final updatedFiles = await getSoundFiles();
    state = AsyncValue.data(updatedFiles);
  }

  Future<String?> copySoundToResources(File soundFile) async {
    try {
      String fileName = path.basename(soundFile.path);

      // Add 'res_' in front of fileName if not present.
      if (!fileName.startsWith('res_')) {
        fileName = 'res_$fileName';
      }

      // Get the application documents directory
      Directory appDir = await getApplicationDocumentsDirectory();
      String resourcePath = path.join(appDir.path, 'sounds', fileName);

      // Create the sounds directory if it doesn't exist
      await Directory(path.join(appDir.path, 'sounds')).create(recursive: true);

      await soundFile.copy(resourcePath);

      state = const AsyncValue.loading(); // Indicate loading state
      final updatedFiles = await getSoundFiles();
      state = AsyncValue.data(updatedFiles);

      return fileName;
    } catch (e, stk) {
      state = AsyncValue.error(e, stk);
      return null;
    }
  }
}
