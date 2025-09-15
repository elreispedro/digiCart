import 'dart:io';
import 'package:digicart/src/services/media_collection_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import '../components/hotkey_display.dart';
import '../components/player_controller.dart';
import '../components/volume_bars.dart';
import '../components/file_name_display.dart';
import '../screens/settings.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/media_collection.dart';

class DragAndDropGrid extends StatefulWidget {
  const DragAndDropGrid({super.key});

  @override
  _DragAndDropGridState createState() => _DragAndDropGridState();
}

class _DragAndDropGridState extends State<DragAndDropGrid>
    with TickerProviderStateMixin {
  final List<String?> fileNamesMedias = List.generate(36, (_) => null);
  final List<String?> filePathsMedias = List.generate(36, (_) => null);
  final List<bool> isDragging = List.generate(36, (_) => false);
  final List<Color> backgroundColorMedias = List.generate(
    36,
    (_) => defaultColor,
  );
  final List<Color> fontColorMedias = List.generate(
    36,
    (_) => fontColorDefault,
  );
  final List<double> volumeMedias = List.generate(36, (_) => 80.0);
  final List<String?> hotkeysMedias = List.generate(36, (_) => null);

  int? selectedIndex;
  late TabController _tabController;
  late AnimationController _animationController;
  bool _isBlinking = false;
  List<String> _mediaCollection = [];
  late final player = Player();
  String mediaVideo = '';
  int? lastIndex;
  late AnimationController _animationController1;
  late Duration remaining;
  late double volume;
  late bool _isplaying = false;
  PlaylistMode playlistMode = PlaylistMode.none;
  List<AudioDevice> audioDevices = [];
  late AudioDevice selectedDevice;
  String? selectedMediaCollection;
  final TextEditingController _mediaCollectionNameController =
      TextEditingController();
  bool showTextField = false;
  bool isSaving = false;
  String currentMediaCollection = '';
  FocusNode focusNode = FocusNode();
  final _mediaCollections = Hive.box('mediaCollections');
  final mediaService = MediaCollectionService();

  // void saveMediaCollection(MediaCollection mediaCollection) {
  //   _mediaCollections.add(mediaCollection);

  //   _mediaCollection = _mediaCollections.values
  //       .cast<MediaCollection>()
  //       .map((mediaCollection) => mediaCollection.collectionName)
  //       .toList();
  // }

  // void deleteMediaCollection(String collectionName) {
  //   final collectionKey = _mediaCollections.keys.firstWhere(
  //     (key) => _mediaCollections.get(key)?.collectionName == collectionName,
  //     orElse: () => null,
  //   );

  //   if (collectionKey != null) {
  //     _mediaCollections.delete(collectionKey);
  //     debugPrint('Coleção "$collectionName" excluída com sucesso.');
  //   } else {
  //     debugPrint('Coleção "$collectionName" não encontrada.');
  //   }

  //   _mediaCollection = _mediaCollections.values
  //       .map((mediaCollection) => mediaCollection.collectionName as String)
  //       .toList();
  // }

  // void updateMediaCollection(
  //   String collectionName,
  //   MediaCollection updatedCollection,
  // ) {
  //   final collectionKey = _mediaCollections.keys.firstWhere(
  //     (key) => _mediaCollections.get(key)?.collectionName == collectionName,
  //     orElse: () => null,
  //   );

  //   if (collectionKey != null) {
  //     _mediaCollections.put(collectionKey, updatedCollection);
  //     debugPrint('Coleção "$collectionName" atualizada com sucesso.');
  //   } else {
  //     debugPrint('Coleção "$collectionName" não encontrada.');
  //   }

  //   _mediaCollection = _mediaCollections.values
  //       .map((mediaCollection) => mediaCollection.collectionName as String)
  //       .toList();
  // }

  MediaCollection? getMediaCollectionByName(String collectionName) {
    // Procura a MediaCollection pelo nome da playlist
    return _mediaCollections.values.firstWhere(
      (mediaCollection) => mediaCollection.collectionName == collectionName,
      orElse: () => null, // Retorna null se não encontrar a coleção
    );
  }

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

    audioDevices = player.state.audioDevices;

    selectedDevice = AudioDevice.auto();

    player.stream.audioDevices.listen((List<AudioDevice> devices) {
      setState(() {
        audioDevices = devices;
      });
    });

    player.setPlaylistMode(playlistMode);

    player.stream.playing.listen((bool playing) {
      _isplaying = playing;
      volume = player.platform!.state.volume;

      if (playing) {
        debugPrint("🎵 Player is playing!");
        player.stream.audioParams.listen((audioParams) {
          debugPrint("🎧 Audio Parameters:");
          debugPrint("- Sample Rate: ${audioParams.sampleRate} Hz");
          debugPrint("- Channels: ${audioParams.channels}");
          debugPrint("- Format: ${audioParams.format}");
        });
        debugPrint(
          "🔄 PlayListMode: ${player.platform?.state.playlistMode.toString()}",
        );
      } else {
        debugPrint("⏸️  Player is paused.");
      }
    });

    player.stream.position.listen((Duration position) {
      remaining = player.state.duration - player.state.position;
      volume = player.platform?.state.volume ?? 100.00;
    });

    _mediaCollection = _mediaCollections.values
        .map((mediaCollection) => mediaCollection.collectionName as String)
        .toList();

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final gridHeight = screenHeight * 0.62;
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
      body: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final keyPressed = event.logicalKey.keyLabel;

            debugPrint('Tecla pressionada: $keyPressed');

            // Verificando se a tecla pressionada é F1 até F12
            if (keyPressed.startsWith('F') &&
                int.tryParse(keyPressed.substring(1)) != null) {
              int fKey = int.parse(keyPressed.substring(1));
              if (fKey >= 1 && fKey <= 12) {
                debugPrint('Tecla F$fKey pressionada');

                if (fKey - 1 < _mediaCollection.length) {
                  if (_mediaCollection[fKey - 1] != '') {
                    loadCollectionMedia(_mediaCollection[fKey - 1]);
                    selectedMediaCollection = _mediaCollection[fKey - 1];
                    debugPrint('Carregada a coleção: $selectedMediaCollection');
                  }
                } else {
                  debugPrint(
                    'Índice inválido: ${fKey - 1}, tamanho da coleção: ${_mediaCollection.length}',
                  );
                }
              }
            } else {
              int tecla = getStringIndex(keyPressed, hotkeysMedias);
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
              _buildSelectedFileInfo(),
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
                    Container(
                      width: screenWidth * .35,
                      // height: screenHeight * .3,
                      decoration: BoxDecoration(
                        border: Border.all(color: second, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Coleções',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.3,
                              height: 40,
                              child: DropdownButton<String>(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                value:
                                    _mediaCollection.contains(
                                      selectedMediaCollection,
                                    )
                                    ? selectedMediaCollection
                                    : null,
                                hint: const Text(
                                  "Selecione uma coleção de mídias",
                                ),
                                alignment: AlignmentDirectional.center,
                                icon: const Icon(Icons.arrow_drop_down),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMediaCollection = newValue;
                                  });
                                },
                                items: _mediaCollection
                                    .map<DropdownMenuItem<String>>((
                                      playlistName,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        alignment: AlignmentDirectional.center,
                                        value: playlistName,
                                        child: Text(playlistName),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //Carregar
                                  Tooltip(
                                    message: (selectedMediaCollection != null)
                                        ? 'Carregar coleção de mídias'
                                        : 'Nenhuma Coleção de mídias disponível para carregar',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.upload_file,
                                        color: (selectedMediaCollection != null)
                                            ? first
                                            : second,
                                      ),
                                      onPressed:
                                          (selectedMediaCollection != null)
                                          ? () async {
                                              String mediaCollectionToLoad =
                                                  selectedMediaCollection!;

                                              bool?
                                              confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Confirmar",
                                                    ),
                                                    content: Text(
                                                      "Deseja carregar a coleção de mídias '$mediaCollectionToLoad'?",
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(false);
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true);
                                                        },
                                                        child: const Text(
                                                          "Carregar",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                loadCollectionMedia(
                                                  mediaCollectionToLoad,
                                                );
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                  //Excluir
                                  Tooltip(
                                    message:
                                        selectedMediaCollection != null &&
                                            selectedIndex == null
                                        ? 'Excluir Coleção de Mídias Selecionada'
                                        : 'Nenhuma Coleção de Mídias selecionada para excluir',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color:
                                            selectedMediaCollection != null &&
                                                selectedIndex == null
                                            ? Colors.red
                                            : second,
                                      ),
                                      onPressed:
                                          (selectedMediaCollection != null &&
                                              selectedIndex == null)
                                          ? () async {
                                              String mediaCollectionToDelete =
                                                  selectedMediaCollection!;
                                              bool?
                                              confirmDelete = await showDialog<bool>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Confirmar exclusão",
                                                    ),
                                                    content: Text(
                                                      "Tem certeza que deseja excluir a coleção de mídias \"$mediaCollectionToDelete\"?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(false);
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true);
                                                        },
                                                        child: const Text(
                                                          "Excluir",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirmDelete == true) {
                                                mediaService
                                                    .deleteMediaCollection(
                                                      mediaCollectionToDelete,
                                                    );
                                                selectedMediaCollection = null;

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Coleção de Mídias "$mediaCollectionToDelete" excluída com sucesso!',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                  //Salvar
                                  Tooltip(
                                    message: selectedMediaCollection != null
                                        ? 'Salvar na coleção de mídias selecionada'
                                        : 'Nenhuma coleção de mídias selecionada para salvar',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.save,
                                        color: selectedMediaCollection != null
                                            ? first
                                            : second,
                                      ),
                                      onPressed: selectedMediaCollection != null
                                          ? () async {
                                              bool?
                                              confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Confirmar",
                                                    ),
                                                    content: Text(
                                                      "Deseja salvar a alteração na coleção de mídias '$selectedMediaCollection'?",
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(false);
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true);
                                                        },
                                                        child: const Text(
                                                          "Salvar",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirm == true) {
                                                try {
                                                  MediaCollection
                                                  updatedCollection = MediaCollection(
                                                    collectionName:
                                                        selectedMediaCollection!,
                                                    mediaPaths:
                                                        getAllMediaPaths(
                                                          replaceDragHere(
                                                            filePathsMedias,
                                                          ),
                                                        ),
                                                    backgroundColor:
                                                        getAllBackgroundColors(
                                                          backgroundColorMedias,
                                                        ),
                                                    fontColor: getAllFontColors(
                                                      fontColorMedias,
                                                      fontColorDefault,
                                                    ),
                                                    gains: getAllGains(
                                                      volumeMedias,
                                                      kGainDefault,
                                                    ),
                                                    hotKeys: getAllHotkeys(
                                                      hotkeysMedias,
                                                      kHotkeyDefault,
                                                    ),
                                                  );
                                                  mediaService
                                                      .updateMediaCollection(
                                                        selectedMediaCollection!,
                                                        updatedCollection,
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Alterações salvas na coleção de mídias "$selectedMediaCollection" com sucesso!',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Erro ao salvar na coleção de mídias "$selectedMediaCollection". Tente novamente.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                  //Adicionar
                                  Tooltip(
                                    message:
                                        filePathsMedias.any(
                                          (path) =>
                                              path != null && path.isNotEmpty,
                                        )
                                        ? 'Adicionar nova coleção de mídias'
                                        : 'Nenhum arquivo válido para adicionar à coleção de mídias',
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.playlist_add,
                                        color:
                                            filePathsMedias.any(
                                              (path) =>
                                                  path != null &&
                                                  path.isNotEmpty,
                                            )
                                            ? first
                                            : second,
                                      ),
                                      onPressed:
                                          filePathsMedias.any(
                                            (path) =>
                                                path != null && path.isNotEmpty,
                                          )
                                          ? () async {
                                              await showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Nova Coleção de Mídias",
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          "Insira o nome da nova playlist:",
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        TextField(
                                                          maxLength: 50,
                                                          controller:
                                                              _mediaCollectionNameController,
                                                          decoration: const InputDecoration(
                                                            labelText:
                                                                'Nome da Playlist',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: const Text(
                                                          "Cancelar",
                                                        ),
                                                      ),
                                                      TextButton(
                                                        style:
                                                            TextButton.styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                        onPressed: () async {
                                                          String
                                                          newMediaCollection =
                                                              _mediaCollectionNameController
                                                                  .text
                                                                  .trim();

                                                          if (newMediaCollection
                                                              .isEmpty) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'Por favor, insira um nome para a playlist.',
                                                                ),
                                                              ),
                                                            );
                                                          } else if (_mediaCollection
                                                              .map(
                                                                (
                                                                  mediaCollection,
                                                                ) => mediaCollection
                                                                    .toLowerCase(),
                                                              )
                                                              .contains(
                                                                newMediaCollection
                                                                    .toLowerCase(),
                                                              )) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'A playlist "$newMediaCollection" já está cadastrada.',
                                                                ),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            );
                                                          } else {
                                                            try {
                                                              MediaCollection
                                                              mediaCollectionCurrent = MediaCollection(
                                                                collectionName:
                                                                    newMediaCollection,
                                                                mediaPaths: getAllMediaPaths(
                                                                  replaceDragHere(
                                                                    filePathsMedias,
                                                                  ),
                                                                ),
                                                                backgroundColor:
                                                                    getAllBackgroundColors(
                                                                      backgroundColorMedias,
                                                                    ),
                                                                fontColor: getAllFontColors(
                                                                  fontColorMedias,
                                                                  fontColorDefault,
                                                                ),
                                                                gains: getAllGains(
                                                                  volumeMedias,
                                                                  kGainDefault,
                                                                ),
                                                                hotKeys: getAllHotkeys(
                                                                  hotkeysMedias,
                                                                  kHotkeyDefault,
                                                                ),
                                                              );
                                                              mediaService
                                                                  .saveMediaCollection(
                                                                    mediaCollectionCurrent,
                                                                  );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Coleção de Mídias "$newMediaCollection" salva com sucesso!',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                              );

                                                              setState(() {
                                                                _mediaCollectionNameController
                                                                    .clear();
                                                              });

                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                            } catch (e) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Erro ao salvar a coleção de mídias "$newMediaCollection". Tente novamente.',
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: const Text(
                                                          "Salvar",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  icon: const Icon(Icons.settings),
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

  void loadCollectionMedia(String mediaCollectionToLoad) {
    setState(() {
      _mediaCollection = _mediaCollections.values
          .map((mediaCollection) => mediaCollection.collectionName as String)
          .toList();

      assignMediaFiles(
        getMediaCollectionByName(mediaCollectionToLoad)!.mediaPaths,
      );

      assignBackgroundColors(
        getMediaCollectionByName(mediaCollectionToLoad)!.backgroundColor,
      );

      assignGain(getMediaCollectionByName(mediaCollectionToLoad)!.gains);

      assignHotkeys(getMediaCollectionByName(mediaCollectionToLoad)!.hotKeys);
      assignFontColors(
        getMediaCollectionByName(mediaCollectionToLoad)!.fontColor,
      );

      selectedIndex = null;
    });
  }

  Widget _buildSelectedFileInfo() {
    if (remaining.inSeconds <= 10 && !_animationController1.isAnimating) {
      _animationController1.repeat(reverse: true);
    } else if (remaining.inSeconds > 10 && _animationController1.isAnimating) {
      _animationController1.stop();
      _animationController1.value = 1.0;
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                selectedIndex != null && fileNamesMedias[selectedIndex!] != null
                    ? fileNamesMedias[selectedIndex!] ?? ''
                    : '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          _isplaying
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: remaining.inSeconds <= 10
                          ? _animationController.value
                          : 1.0,
                      child: Text(
                        formatTimeRemaining(remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: remaining.inSeconds <= 10
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                )
              : Container(),
        ],
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
      onSecondaryTapDown: (details) => _showContextMenu(details, index),
      child: DropTarget(
        onDragEntered: (_) => setState(() => isDragging[index] = true),
        onDragExited: (_) => setState(() => isDragging[index] = false),
        onDragDone: (details) {
          setState(() {
            if (details.files.isNotEmpty) {
              fileNamesMedias[index] = details.files.first.name;
              filePathsMedias[index] = details.files.first.path;
            }
            isDragging[index] = false;
          });
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
          child: _buildGridItemContent(index),
        ),
      ),
    );
  }

  void clickItem(int index) {
    setState(() {
      if (filePathsMedias[index] != null &&
          filePathsMedias[index]!.isNotEmpty &&
          filePathsMedias[index] != '' &&
          File(filePathsMedias[index]!).existsSync()) {
        mediaVideo = filePathsMedias[index]!;
        if (selectedIndex == index && _isplaying) {
          player.stop();
          selectedIndex = null;
          mediaVideo = '';
        } else {
          if (_isplaying) {
            player.stop();
          }
          selectedIndex = index;
          print(selectedIndex);
          print(volumeMedias[selectedIndex!]);
          setState(() {
            player.platform!.setVolume(volumeMedias[selectedIndex!]);
          });
          player.open(Media(mediaVideo), play: true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'O caminho da mídia é inválido ou o arquivo "${filePathsMedias[index]}" não está acessível.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint(
          "O caminho da mídia é inválido ou o arquivo não está acessível.",
        );
      }
    });
  }

  Widget _buildGridItemContent(int index) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              fileNamesMedias[index] != null || fileNamesMedias[index] == ''
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: fontColorMedias[index],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            fileNamesMedias[index] != null || fileNamesMedias[index] == ''
                ? Padding(
                    padding: const EdgeInsets.all(4),
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

  void _showContextMenu(TapDownDetails details, int index) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 1,
        details.globalPosition.dy + 1,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'select',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.audio_file_sharp),
                  SizedBox(width: 4),
                  Text('Selecionar o arquivo de mídia'),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.transparent),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'remove',
          enabled:
              fileNamesMedias[index] != null &&
              fileNamesMedias[index]!.isNotEmpty,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 4),
                  Text('Remover arquivo'),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.transparent),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'choose_color',
          enabled:
              fileNamesMedias[index] != null &&
              fileNamesMedias[index]!.isNotEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.color_lens_outlined,
                    color: fileNamesMedias[index] != null
                        ? Colors.black
                        : second,
                  ),
                  const SizedBox(width: 4),
                  const Text('Escolher a cor'),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: fileNamesMedias[index] != null
                    ? fontColorDefault
                    : second,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'choose_color_font',
          enabled:
              fileNamesMedias[index] != null &&
              fileNamesMedias[index]!.isNotEmpty,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.color_lens_outlined,
                    color: fileNamesMedias[index] != null
                        ? Colors.black
                        : second,
                  ),
                  const SizedBox(width: 4),
                  const Text('Escolher a cor da fonte'),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: fileNamesMedias[index] != null
                    ? fontColorDefault
                    : second,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'select_audio_gain',
          enabled:
              fileNamesMedias[index] != null &&
              fileNamesMedias[index]!.isNotEmpty,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.volume_up),
              SizedBox(width: 4),
              Text('Selecionar volume do áudio'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'set_shortcut',
          enabled:
              fileNamesMedias[index] != null &&
              fileNamesMedias[index]!.isNotEmpty,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.keyboard),
              SizedBox(width: 4),
              Text('Definir tecla de atalho'),
            ],
          ),
        ),
      ],
    ).then((value) => _handleContextMenuAction(value, index, details));
  }

  void _handleContextMenuAction(
    String? value,
    int index,
    TapDownDetails details,
  ) async {
    if (value == 'remove') {
      setState(() {
        backgroundColorMedias[index] = (second);
        if (mediaVideo == filePathsMedias[index]) {
          player.stop();
          mediaVideo = '';
          selectedIndex = null;
        }
        fileNamesMedias[index] = null;
        filePathsMedias[index] = null;
        setState(() {});
      });
    } else if (value == 'select') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['mp3', 'wav', 'ogg', 'flac'],
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          fileNamesMedias[index] = result.files.single.name;
          filePathsMedias[index] = result.files.single.path;
          mediaVideo = filePathsMedias[index]!;
        });
      }
    } else if (value == 'choose_color') {
      _showBackgroundColorMenu(details, index);
    } else if (value == 'select_audio_gain') {
      _showAudioGainDialog(index);
    } else if (value == 'choose_color_font') {
      _showFontColorMenu(details, index);
    } else if (value == 'select_audio_gain') {
      _showAudioGainDialog(index);
    } else if (value == 'set_shortcut') {
      _showShortcutDialog(index);
    }
  }

  void _showAudioGainDialog(int index) {
    double nivelAudio = volumeMedias[index];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione o nível do volume de áudio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    activeColor: fontColorDefault,
                    value: nivelAudio,
                    onChanged: (value) {
                      setState(() {
                        nivelAudio = value;
                      });
                    },
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: nivelAudio.floor().toString(),
                  ),
                  Text('Volume: ${nivelAudio.floor()}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      volumeMedias[index] = nivelAudio; // Atualiza o volume
                    });
                    debugPrint(
                      'Nível do volume de áudio selecionado: ${nivelAudio.toStringAsFixed(0)}',
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShortcutDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String? shortcut = hotkeysMedias[index];
        FocusNode focusNode = FocusNode();

        return AlertDialog(
          title: const Text('Definir tecla de atalho'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pressione uma tecla para definir como atalho'),
                  const SizedBox(height: 10),
                  KeyboardListener(
                    focusNode: focusNode,
                    autofocus: true,
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent) {
                        // Verificando se a tecla pressionada é uma tecla F1 até F12
                        if (event.logicalKey.keyLabel.startsWith('F') &&
                            int.tryParse(
                                  event.logicalKey.keyLabel.substring(1),
                                ) !=
                                null) {
                          // Impede a definição de teclas F1 a F12
                          debugPrint(
                            'Tecla F1 a F12 não permitida como atalho',
                          );
                        } else {
                          setState(() {
                            shortcut = event.logicalKey.keyLabel;
                          });
                        }
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        focusNode.requestFocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: shortcut ?? 'Nenhuma tecla selecionada',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (shortcut != null) {
                  if (hotkeysMedias.contains(shortcut) &&
                      hotkeysMedias.indexOf(shortcut) != index) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Erro'),
                        content: const Text(
                          'Essa tecla já está configurada em outra posição.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    debugPrint('Tecla de atalho definida: $shortcut');
                    hotkeysMedias[index] = shortcut;
                    Navigator.of(context).pop();
                  }
                } else {
                  debugPrint('Nenhuma tecla selecionada.');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showFontColorMenu(TapDownDetails details, int index) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = details.globalPosition;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: List.generate((kPredefinedColors.length / 4).ceil(), (row) {
        return PopupMenuItem<String>(
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: kPredefinedColors
                .skip(row * 4)
                .take(4)
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(color.value.toString());
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }),
    ).then((value) {
      if (value != null) {
        final selectedColor = kPredefinedColors.firstWhere(
          (color) => color.value.toString() == value,
        );
        setState(() => fontColorMedias[index] = selectedColor);
      }
    });
  }

  void _showBackgroundColorMenu(TapDownDetails details, int index) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = details.globalPosition;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: List.generate((kPredefinedColors.length / 4).ceil(), (row) {
        return PopupMenuItem<String>(
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: kPredefinedColors
                .skip(row * 4)
                .take(4)
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(color.value.toString());
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }),
    ).then((value) {
      if (value != null) {
        final selectedColor = kPredefinedColors.firstWhere(
          (color) => color.value.toString() == value,
        );
        setState(() => backgroundColorMedias[index] = selectedColor);
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

  void assignVolumes(List<double?> volumes) {
    setState(() {
      for (int i = 0; i < volumes.length && i < volumes.length; i++) {
        volumes[i] = (volumes[i])!;
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
      for (int i = 0; i < newGainList.length && i < newGainList.length; i++) {
        volumeMedias[i] = newGainList[i]!;
      }
    });
  }

  void assignHotkeys(List<String?> hotkeys) {
    setState(() {
      for (int i = 0; i < hotkeys.length && i < hotkeys.length; i++) {
        hotkeysMedias[i] = hotkeys[i]!;
      }
    });
  }

  void assignDefaultGain(double defaultGain) {
    setState(() {
      for (int i = 0; i < kGains.length && i < kGains.length; i++) {
        kGains[i] = defaultGain;
      }
    });
  }
}
