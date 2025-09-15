import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:digicart/src/components/snackbar_helper.dart';
import 'package:digicart/src/services/settings_service.dart';
import 'package:digicart/src/utils/text_format_style.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import '../components/media_collection_manager.dart';
import '../components/menu/context_menu.dart';
import '../components/menu/handle_context_menu_action.dart';
import '../components/selected_file_info.dart';
import '../components/hotkey_display.dart';
import '../components/player_controller.dart';
import '../components/volume_bars.dart';
import '../components/file_name_display.dart';
import '../services/media_collection_service.dart';
import '../screens/settings.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final List<String?> fileNamesMedias = List.generate(36, (_) => null);
  final List<String?> filePathsMedias = List.generate(36, (_) => null);
  final List<bool> isDragging = List.generate(36, (_) => false);
  final List<Color> backgroundColorMedias = List.generate(36, (_) => second);
  final List<Color> fontColorMedias = List.generate(
    36,
    (_) => fontColorDefault,
  );
  final List<double> volumeMedias = List.generate(36, (_) => 80.0);
  final List<String?> hotkeysMedias = List.generate(36, (_) => null);
  final List<bool> isCopying = List.generate(36, (_) => false);

  int? selectedIndex;
  late TabController _tabController;
  late AnimationController _animationController;
  bool _isBlinking = false;
  List<String> _mediaCollection = [];
  late final player = Player();
  List<AudioDevice> audioDevices = [];
  late AudioDevice selectedDevice = AudioDevice.auto();

  String mediaVideo = '';
  int? lastIndex;
  late AnimationController _animationController1;
  late Duration remaining;
  late double volume;
  late bool _isplaying = false;
  PlaylistMode playlistMode = PlaylistMode.none;
  String? selectedMediaCollection;
  final TextEditingController _mediaCollectionNameController =
      TextEditingController();
  bool showTextField = false;
  bool isSaving = false;
  String currentMediaCollection = '';
  FocusNode focusNode = FocusNode();
  late String targetFolder = kFolderMedia;

  final mediaCollectionService = MediaCollectionService();
  final savedDeviceAudio = SettingsService.selectedAudioDeviceName;
  String folderStorageMedia = SettingsService.mediaSavePath ?? kFolderMedia;

  @override
  void initState() {
    super.initState();

    _animationController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          setState(() {
            _isBlinking = _animationController.value < 0.5;
          });
        });

    _animationController.repeat(reverse: true);

    _tabController = TabController(length: 3, vsync: this);

    final savedDeviceAudio = SettingsService.selectedAudioDeviceName;

    debugPrint('🎧 savedDeviceAudio: $savedDeviceAudio');

    player.stream.audioDevices.listen((List<AudioDevice> devices) {
      setState(() {
        audioDevices = devices;

        if (savedDeviceAudio != null && audioDevices.isNotEmpty) {
          final matchedDevice = audioDevices.firstWhere(
            (device) => device.name == savedDeviceAudio,
            orElse: () {
              debugPrint(
                '⚠️ Dispositivo salvo não encontrado. Usando automático.',
              );
              return AudioDevice.auto();
            },
          );
          selectedDevice = matchedDevice;
        } else {
          debugPrint('⚠️ Nenhum salvo ou lista vazia. Usando automático.');
          selectedDevice = AudioDevice.auto();
        }

        player.setAudioDevice(selectedDevice);
        debugPrint('🎧 Dispositivo final: ${selectedDevice.name}');
      });
    });

    player.setPlaylistMode(playlistMode);

    player.stream.playing.listen((bool playing) {
      _isplaying = playing;
      volume = player.platform!.state.volume;
      if (playing) {
        debugPrint("🎵 Player is playing!");

        debugPrint("📀 Current Media: ${fileNamesMedias[selectedIndex!]}");
        debugPrint("📂 Path Media: ${filePathsMedias[selectedIndex!]}");

        player.stream.audioParams.listen((audioParams) {
          debugPrint("🎧 Audio Parameters:");
          debugPrint("- Sample Rate: ${audioParams.sampleRate} Hz");
          debugPrint("- Channels: ${audioParams.channels}");
          debugPrint("- Format: ${audioParams.format}");
        });

        debugPrint("🔄 PlayListMode: ${player.state.playlistMode}");
      } else {
        debugPrint("⏸️  Player is paused.");
      }
    });

    player.stream.position.listen((Duration position) {
      remaining = player.state.duration - player.state.position;
      volume = player.platform?.state.volume ?? 100.00;
    });

    _mediaCollection = mediaCollectionService.mediaCollectionNames;
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController1.dispose();
    _tabController.dispose();
    player.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void resetState() {
    setState(() {
      fileNamesMedias
        ..clear()
        ..addAll(List.generate(36, (_) => null));

      filePathsMedias
        ..clear()
        ..addAll(List.generate(36, (_) => null));

      isDragging
        ..clear()
        ..addAll(List.generate(36, (_) => false));

      backgroundColorMedias
        ..clear()
        ..addAll(List.generate(36, (_) => second));

      fontColorMedias
        ..clear()
        ..addAll(List.generate(36, (_) => fontColorDefault));

      volumeMedias
        ..clear()
        ..addAll(List.generate(36, (_) => 80.0));

      hotkeysMedias
        ..clear()
        ..addAll(List.generate(36, (_) => null));

      isCopying
        ..clear()
        ..addAll(List.generate(36, (_) => false));
      selectedIndex = null;
      selectedMediaCollection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final gridHeight = screenHeight * 0.68;
    const crossAxisCount = 6;
    const spacing = 5.0;
    final itemWidth =
        (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
    const totalSpacingHeight = (5 * spacing);
    final itemHeight = (gridHeight - totalSpacingHeight) / 6;
    final duration = player.state.duration;
    final position = player.state.position;
    remaining = duration - position;
    volume = 100;

    return Scaffold(
      backgroundColor: background,
      body: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,

        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
            List<String> combo = [];

            final isCtrl = pressedKeys.any(
              (k) =>
                  k == LogicalKeyboardKey.controlLeft ||
                  k == LogicalKeyboardKey.controlRight,
            );
            final isShift = pressedKeys.any(
              (k) =>
                  k == LogicalKeyboardKey.shiftLeft ||
                  k == LogicalKeyboardKey.shiftRight,
            );
            final isAlt = pressedKeys.any(
              (k) =>
                  k == LogicalKeyboardKey.altLeft ||
                  k == LogicalKeyboardKey.altRight,
            );

            if (isCtrl) combo.add("Ctrl");
            if (isShift) combo.add("Shift");
            if (isAlt) combo.add("Alt");

            final mainKey = event.logicalKey;

            // Atalhos especiais (coleção com Ctrl+Shift+ArrowUp/Down)
            if (isCtrl && isShift) {
              if (mainKey == LogicalKeyboardKey.arrowUp ||
                  mainKey == LogicalKeyboardKey.arrowDown) {
                if (_mediaCollection.isEmpty) {
                  debugPrint(
                    "⚠️ Nenhuma coleção disponível — atalho ignorado.",
                  );
                  return;
                }

                int idx = selectedMediaCollection == null
                    ? -1
                    : _mediaCollection.indexOf(selectedMediaCollection!);

                if (idx == -1) {
                  // inicializa na primeira coleção
                  setState(() {
                    selectedMediaCollection = _mediaCollection.first;
                  });
                  loadCollectionMedia(selectedMediaCollection!);
                  return;
                }

                if (mainKey == LogicalKeyboardKey.arrowUp && idx > 0) {
                  setState(() {
                    selectedMediaCollection = _mediaCollection[idx - 1];
                  });
                  loadCollectionMedia(selectedMediaCollection!);
                }

                if (mainKey == LogicalKeyboardKey.arrowDown &&
                    idx < _mediaCollection.length - 1) {
                  setState(() {
                    selectedMediaCollection = _mediaCollection[idx + 1];
                  });
                  loadCollectionMedia(selectedMediaCollection!);
                }

                return;
              }
            }

            // Se não for modificador, adiciona no comboString
            if (!(mainKey == LogicalKeyboardKey.controlLeft ||
                mainKey == LogicalKeyboardKey.controlRight ||
                mainKey == LogicalKeyboardKey.shiftLeft ||
                mainKey == LogicalKeyboardKey.shiftRight ||
                mainKey == LogicalKeyboardKey.altLeft ||
                mainKey == LogicalKeyboardKey.altRight ||
                mainKey == LogicalKeyboardKey.metaLeft ||
                mainKey == LogicalKeyboardKey.metaRight)) {
              combo.add(
                mainKey.keyLabel.isNotEmpty
                    ? mainKey.keyLabel
                    : mainKey.debugName ?? "",
              );
            }

            final comboString = combo.join(" + ");
            debugPrint("🖱️ Tecla(s) pressionada(s): $comboString");

            // Hotkeys normais
            if (combo.isNotEmpty &&
                combo.any((k) => ["Ctrl", "Shift", "Alt"].contains(k))) {
              int tecla = hotkeysMedias.indexOf(comboString);
              if (tecla >= 0) {
                clickItem(tecla);
              }
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SelectedFileInfo(
                remaining: remaining,
                animationController: _animationController,
                animationController1: _animationController1,
                isPlaying: _isplaying,
                selectedIndex: selectedIndex,
                fileNamesMedias: fileNamesMedias,
                formatTimeRemaining: formatTimeRemaining,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: gridHeight,
                  child: _buildGrid(
                    crossAxisCount,
                    spacing,
                    itemWidth,
                    itemHeight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomPlayerWidget(
                      remaining: remaining,
                      fileNames: fileNamesMedias,
                      audioDevices: audioDevices,
                      selectedDevice: selectedDevice,
                      selectedIndex: selectedIndex,
                      volume: (selectedIndex != null
                          ? volumeMedias[selectedIndex!]
                          : 80.0),
                      player: player,
                      playlistMode: playlistMode,
                      mediaVideoIsNotEmpty: mediaVideo.isNotEmpty,
                      onPlay: () {
                        debugPrint('▶️ [Play]: Playback started.');
                        player.open(Media(mediaVideo), play: false);
                        player.play();
                      },
                      onPause: () {
                        debugPrint('⏸️ [Pause]: Playback paused.');
                        player.pause();
                      },
                      onStop: () {
                        debugPrint('⏹️ [Stop]: Playback stopped.');
                        player.stop();
                      },
                      onEject: () {
                        debugPrint('⏏️ [Eject]: Media ejected.');
                        setState(() {
                          if (selectedIndex != null) {
                            if (mediaVideo == filePathsMedias[selectedIndex!]) {
                              debugPrint(
                                '⏏️ [Eject]: Clearing media from player and UI.',
                              );
                              player.stop();
                              player.remove(0);
                              mediaVideo = '';
                              playlistMode = PlaylistMode.none;
                              selectedIndex = null;
                            }
                          } else {
                            debugPrint(
                              '⚠️ [Eject]: selectedIndex is null. Nothing to clear.',
                            );
                          }
                        });
                      },
                      onFastForward: () {
                        debugPrint('⏩ [Fast Forward]: Not implemented.');
                      },
                      onRewind: () {
                        debugPrint('⏪ [Rewind]: Not implemented.');
                      },
                    ),
                    MediaCollectionCard(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      mediaCollection: _mediaCollection,
                      selectedMediaCollection: selectedMediaCollection,
                      mediaCollectionNameController:
                          _mediaCollectionNameController,
                      mediaCollectionService: mediaCollectionService,
                      filePathsMedias: filePathsMedias,
                      fileNamesMedias: fileNamesMedias,
                      backgroundColorMedias: backgroundColorMedias,
                      fontColorMedias: fontColorMedias,
                      volumeMedias: volumeMedias,
                      hotkeysMedias: hotkeysMedias,
                      primaryColor: first,
                      secondaryColor: second,
                      fontColorDefault: fontColorDefault,
                      gainDefault: kGainDefault,
                      hotkeyDefault: kHotkeyDefault,
                      selectedIndex: selectedIndex,
                      loadCollectionMedia: loadCollectionMedia,
                      setState: setState,
                      resetState: resetState,
                      onCollectionChanged: (String? newValue) {
                        setState(() {
                          selectedMediaCollection = newValue;
                        });
                      },
                    ),
                    Container(
                      width: screenWidth * .08,
                      // height: screenHeight * .3,
                      decoration: BoxDecoration(
                        border: Border.all(color: second, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Tooltip(
                                message: 'Configurações',
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: first,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SettingsPage(
                                          audioDevices: audioDevices,
                                          player: player,
                                          selectedDevice: selectedDevice,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
    int crossAxisCount,
    double spacing,
    double itemWidth,
    double itemHeight,
  ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: 36,
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    );
  }

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {
        clickItem(index);
      },
      onSecondaryTapDown: (details) {
        showMediaContextMenu(
          context: context,
          details: details,
          index: index,
          fileNamesMedias: fileNamesMedias,
          fontColorDefault: fontColorDefault,
          backgroundColorMedias: backgroundColorMedias,
          fontColorMedias: fontColorMedias,
          onSelected: (value, i, d) {
            handleContextMenuAction(
              context: context,
              value: value,
              index: i,
              details: d,
              backgroundColorMedias: backgroundColorMedias,
              fontColorMedias: fontColorMedias,
              volumeMedias: volumeMedias,
              hotkeysMedias: hotkeysMedias,
              fileNamesMedias: fileNamesMedias,
              filePathsMedias: filePathsMedias,
              predefinedColors: kPredefinedColors,
              isCopying: isCopying,
              secondaryColor: second,
              fontColorDefault: fontColorDefault,
              setState: setState,
              player: player,
              mediaVideo: mediaVideo,
              selectedIndex: selectedIndex,
              folderStorageMedia: targetFolder,
            );
          },
        );
      },
      child: DropTarget(
        onDragEntered: (_) => setState(() => isDragging[index] = true),
        onDragExited: (_) => setState(() => isDragging[index] = false),
        onDragDone: (details) async {
          setState(() {
            isDragging[index] = false;
            isCopying[index] = false;
          });

          if (details.files.isEmpty) return;

          final file = details.files.first;
          final ext = path
              .extension(file.name)
              .toLowerCase()
              .replaceAll('.', '');

          if (!kAllowedAudiosExtensions.contains(ext)) {
            showCustomSnackBar(
              context,
              message:
                  'Arquivo "${file.name}" não permitido. Tipos permitidos: ${kAllowedAudiosExtensions.join(', ')}',
              background: Colors.red,
              textColor: Colors.white,
              iconColor: Colors.red,
              icon: Icons.error,
            );

            return;
          }

          try {
            folderStorageMedia = SettingsService.mediaSavePath ?? kFolderMedia;
            targetFolder = Directory(folderStorageMedia).existsSync()
                ? folderStorageMedia
                : kFolderMedia;

            final destinationPath = path.join(targetFolder, file.name);

            setState(() {
              isCopying[index] = true;
            });

            await File(file.path).copy(destinationPath);
            await Future.delayed(const Duration(seconds: 1));

            setState(() {
              isCopying[index] = false;
              fileNamesMedias[index] = file.name;
              filePathsMedias[index] = destinationPath;
              hotkeysMedias[index] = kHotkeyDefault;
              volumeMedias[index] = kGainDefault;
              backgroundColorMedias[index] = defaultColor;
              fontColorMedias[index] = fontColorDefault;
            });
            showCustomSnackBar(
              context,
              message: 'Arquivo "${file.name}" copiado com sucesso!',
              background: first,
              textColor: second,
              icon: Icons.check_circle,
              iconColor: Colors.green,
            );
          } catch (e) {
            setState(() => isCopying[index] = false);

            showCustomSnackBar(
              context,
              message: 'Erro ao copiar o arquivo "${file.name}". erro $e',
              background: Colors.red,
              textColor: Colors.white,
              icon: Icons.error,
              iconColor: Colors.red,
            );
          }
        },

        child: Container(
          decoration: BoxDecoration(
            color: isDragging[index]
                ? Colors.black.withValues(alpha: 0.3)
                : backgroundColorMedias[index],
            border: Border.all(
              color: selectedIndex == index
                  ? (_isBlinking
                        ? (backgroundColorMedias[index] == Colors.black
                              ? Colors.white
                              : Colors.black)
                        : (backgroundColorMedias[index] == Colors.black
                              ? Colors.red
                              : backgroundColorMedias[index]))
                  : defaultColor,
              width: selectedIndex == index ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              _buildGridItemContent(index),
              if (isCopying[index])
                Container(
                  color: second.withValues(alpha: 0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: first),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItemContent(int index) {
    final hasFile = fileNamesMedias[index]?.isNotEmpty ?? false;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: hasFile
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                '${index + 1}',
                style: textStyleCustom(
                  fontSize: 12,
                  color: fontColorMedias[index],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            hasFile
                ? Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildFileNameDisplay(
                          fileNamesMedias[index]!,
                          fontColorMedias[index],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildVolumeBars(
                                volumeMedias[index],
                                fileNamesMedias[index]!,
                                fontColorMedias[index],
                              ),
                              buildHotkeyDisplay(
                                hotkeysMedias[index]!,
                                fileNamesMedias[index]!,
                                fontColorMedias[index],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void loadCollectionMedia(String mediaCollectionToLoad) {
    setState(() {
      _mediaCollection = mediaCollectionService.mediaCollectionNames;

      assignMediaFiles(
        mediaCollectionService
            .getMediaCollectionByName(mediaCollectionToLoad)!
            .mediaPaths,
      );

      assignBackgroundColors(
        mediaCollectionService
            .getMediaCollectionByName(mediaCollectionToLoad)!
            .backgroundColor,
      );

      assignGain(
        mediaCollectionService
            .getMediaCollectionByName(mediaCollectionToLoad)!
            .gains,
      );

      assignHotkeys(
        mediaCollectionService
            .getMediaCollectionByName(mediaCollectionToLoad)!
            .hotKeys,
      );
      assignFontColors(
        mediaCollectionService
            .getMediaCollectionByName(mediaCollectionToLoad)!
            .fontColor,
      );

      selectedIndex = null;
    });
  }

  void clickItem(int index) {
    final filePath = filePathsMedias[index];
    if (filePath == null || filePath.isEmpty || !File(filePath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arquivo inválido ou inacessível: $filePath'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_isplaying && selectedIndex == index) {
        player.stop();
        selectedIndex = null;
        mediaVideo = '';
      } else {
        if (_isplaying) player.stop();
        selectedIndex = index;
        mediaVideo = filePath;
        player.platform!.setVolume(volumeMedias[index]);
        player.open(Media(mediaVideo), play: true);
      }
    });
  }

  void assignMediaFiles(List<String?> filePathsList) {
    setState(() {
      for (
        int i = 0;
        i < filePathsList.length && i < fileNamesMedias.length;
        i++
      ) {
        if (filePathsList[i]!.isNotEmpty) {
          filePathsMedias[i] = filePathsList[i];
          fileNamesMedias[i] = path.basename(filePathsList[i]!);
        } else {
          filePathsMedias[i] = '';
          fileNamesMedias[i] = '';
        }
      }
    });
  }

  void assignBackgroundColors(List<Color?> newColorsList) {
    setState(() {
      for (
        int i = 0;
        i < newColorsList.length && i < backgroundColorMedias.length;
        i++
      ) {
        backgroundColorMedias[i] = (newColorsList[i])!;
      }
    });
  }

  void assignFontColors(List<Color?> newColorsList) {
    setState(() {
      for (
        int i = 0;
        i < newColorsList.length && i < fontColorMedias.length;
        i++
      ) {
        fontColorMedias[i] = (newColorsList[i])!;
      }
    });
  }

  void assignVolumes(List<double?> newVolumes) {
    setState(() {
      for (int i = 0; i < newVolumes.length && i < volumeMedias.length; i++) {
        volumeMedias[i] = newVolumes[i] ?? volumeMedias[i];
      }
    });
  }

  void assignDefaultColor(Color defaultColor) {
    setState(() {
      for (
        int i = 0;
        i < backgroundColorMedias.length && i < backgroundColorMedias.length;
        i++
      ) {
        backgroundColorMedias[i] = (defaultColor);
      }
    });
  }

  void assignGain(List<double?> newGainList) {
    setState(() {
      for (int i = 0; i < newGainList.length && i < volumeMedias.length; i++) {
        volumeMedias[i] = newGainList[i] ?? volumeMedias[i];
      }
    });
  }

  void assignHotkeys(List<String?> hotkeys) {
    setState(() {
      for (int i = 0; i < hotkeys.length && i < hotkeysMedias.length; i++) {
        hotkeysMedias[i] = hotkeys[i] ?? hotkeysMedias[i];
      }
    });
  }

  void assignDefaultGain(double defaultGain) {
    setState(() {
      for (int i = 0; i < kGains.length; i++) {
        kGains[i] = defaultGain;
      }
    });
  }
}
