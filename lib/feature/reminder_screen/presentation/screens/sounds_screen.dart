import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({Key? key}) : super(key: key);

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  Future<List<FileSystemEntity>> getSoundFiles() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory soundsDir = Directory(path.join(appDir.path, 'sounds'));

    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }

    return soundsDir.listSync();
  }

  Future<void> deleteSound(BuildContext context, FileSystemEntity file) async {
    final ThemeData theme = Theme.of(context);

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Sound'),
        content: Text(
            'Are you sure you want to delete ${path.basename(file.path).replaceFirst('res_', '')}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await file.delete();
        setState(() {});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${path.basename(file.path)} deleted'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

      // Return just the filename to use in notifications
      return fileName;
    } catch (e) {
      print('Error copying sound file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Notification sounds",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: getSoundFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<FileSystemEntity> soundFiles = snapshot.data ?? [];

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = 180.0; // Minimum card width
              final int crossAxisCount =
                  (constraints.maxWidth / cardWidth).floor();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: soundFiles.length + 1, // +1 for "Add Sound" card
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddSoundCard(context);
                  }
                  return _buildSoundCard(context, soundFiles[index - 1]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddSoundCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: <String>['mp3', 'wav', 'aac', 'ogg'],
          );

          if (result != null) {
            File file = File(result.files.single.path!);
            await copySoundToResources(file);
            setState(() {});
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, size: 40),
            SizedBox(height: 8),
            Text('Add Sound',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(BuildContext context, FileSystemEntity file) {
    final String fileName = path.basename(file.path).replaceFirst('res_', '');
    final player = AudioPlayer();
    final theme = Theme.of(context);

    return HookBuilder(builder: (context) {
      final isPlaying = useState<bool>(false);
      useEffect(() {
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            isPlaying.value = false;
          }
        });
        return player.dispose;
      }, []);
      return Card(
        elevation: 2,
        color: isPlaying.value
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        child: InkWell(
          onTap: () {
            // TODO: Implement sound selection
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => deleteSound(context, file),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill),
                      onPressed: () async {
                        try {
                          isPlaying.value = true;
                          await player.setFilePath(file.path);
                          await player.play();
                        } catch (e) {
                          print('Error playing sound: $e');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
