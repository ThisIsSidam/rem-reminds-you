import 'dart:io';

import 'package:Rem/feature/reminder_screen/presentation/providers/sounds_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;

import '../../../../shared/widgets/async_value_widget.dart';

class SoundsScreen extends ConsumerWidget {
  Future<void> deleteSound(
    BuildContext context,
    FileSystemEntity file,
    SoundsNotifier notifier,
  ) async {
    final ThemeData theme = Theme.of(context);

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Sound'),
        content: Text(
          'Are you sure you want to delete ${path.basename(file.path).replaceFirst('res_', '')}?',
        ),
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
        await notifier.deleteSound(file);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsNotifier = ref.read(soundsNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Notification sounds",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: AsyncValueWidget<List<FileSystemEntity>>(
        value: ref.watch(soundsNotifierProvider),
        data: (sounds) => LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = 180.0; // Minimum card width
            final int crossAxisCount =
                (constraints.maxWidth / cardWidth).floor();

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: sounds.length + 1, // +1 for "Add Sound" card
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddSoundCard(context, soundsNotifier);
                }
                return _buildSoundCard(
                  context,
                  sounds[index - 1],
                  soundsNotifier,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddSoundCard(BuildContext context, SoundsNotifier notifier) {
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
            notifier.copySoundToResources(file);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, size: 40),
            SizedBox(height: 8),
            Text(
              'Add Sound',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(
    BuildContext context,
    FileSystemEntity file,
    SoundsNotifier notifier,
  ) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => deleteSound(context, file, notifier),
                  ),
                  SizedBox(
                    width: 2,
                    height: 40,
                    child: const VerticalDivider(
                      thickness: 1.5,
                    ),
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
      );
    });
  }
}
