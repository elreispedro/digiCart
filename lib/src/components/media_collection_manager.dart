import 'custom_button.dart';
import 'package:flutter/material.dart';
import '../services/media_collection_service.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../models/media_collection.dart';
import '../utils/text_format_style.dart';
import 'snackbar_helper.dart';

class MediaCollectionCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<String> mediaCollection;
  final String? selectedMediaCollection;
  final TextEditingController mediaCollectionNameController;
  final MediaCollectionService mediaCollectionService;
  final List<String?> filePathsMedias;
  final List<String?> fileNamesMedias;
  final List<Color> backgroundColorMedias;
  final List<Color> fontColorMedias;
  final List<double> volumeMedias;
  final List<String?> hotkeysMedias;
  final Color primaryColor;
  final Color secondaryColor;
  final Color fontColorDefault;
  final double gainDefault;
  final String hotkeyDefault;
  final int? selectedIndex;
  final Function(String) loadCollectionMedia;
  final Function(VoidCallback fn) setState;
  final Function(String?) onCollectionChanged;
  final Function() resetState;

  const MediaCollectionCard({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.mediaCollection,
    required this.selectedMediaCollection,
    required this.mediaCollectionNameController,
    required this.mediaCollectionService,
    required this.filePathsMedias,
    required this.fileNamesMedias,
    required this.backgroundColorMedias,
    required this.fontColorMedias,
    required this.volumeMedias,
    required this.hotkeysMedias,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontColorDefault,
    required this.gainDefault,
    required this.hotkeyDefault,
    required this.selectedIndex,
    required this.loadCollectionMedia,
    required this.setState,
    required this.onCollectionChanged,
    required this.resetState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * .35,
      decoration: BoxDecoration(
        border: Border.all(color: secondaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Coleções',
                style: textStyleCustom(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: first,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.3,
              height: 40,
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                style: textStyleCustom(fontSize: 16, color: first),
                value: mediaCollection.contains(selectedMediaCollection)
                    ? selectedMediaCollection
                    : null,
                hint: Text(
                  "Selecione uma coleção de mídias",
                  style: textStyleCustom(fontSize: 16, color: first),
                ),
                alignment: AlignmentDirectional.center,
                icon: const Icon(Icons.arrow_drop_down, color: first),
                isExpanded: true,
                onChanged: onCollectionChanged,
                items: mediaCollection.map<DropdownMenuItem<String>>((name) {
                  return DropdownMenuItem<String>(
                    alignment: AlignmentDirectional.center,
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLoadButton(context),
                  _buildDeleteButton(context),
                  _buildSaveButton(context),
                  _buildAddButton(context),
                  _buildRestoreButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadButton(BuildContext context) {
    return Tooltip(
      message: selectedMediaCollection != null
          ? 'Carregar coleção de mídias'
          : 'Nenhuma Coleção de mídias disponível para carregar',
      textStyle: textStyleCustom(fontSize: 16, color: second),

      child: IconButton(
        icon: Icon(
          Icons.upload_file,
          color: selectedMediaCollection != null
              ? primaryColor
              : secondaryColor,
        ),
        onPressed: selectedMediaCollection != null
            ? () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Confirmar",
                      style: textStyleCustom(
                        fontSize: 16,
                        color: first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      "Deseja carregar a coleção de mídias '$selectedMediaCollection'?",
                      style: textStyleCustom(fontSize: 16, color: first),
                    ),
                    actions: [
                      CustomActionButton(
                        label: "Cancelar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),

                      CustomActionButton(
                        label: "Carregar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  loadCollectionMedia(selectedMediaCollection!);
                }
              }
            : null,
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Tooltip(
      message: selectedMediaCollection != null
          ? 'Excluir Coleção de Mídias Selecionada'
          : 'Nenhuma Coleção de Mídias selecionada para excluir',
      textStyle: textStyleCustom(fontSize: 16, color: second),
      child: IconButton(
        icon: Icon(
          Icons.delete,
          color: selectedMediaCollection != null && selectedIndex == null
              ? Colors.red
              : secondaryColor,
        ),
        onPressed: selectedMediaCollection != null && selectedIndex == null
            ? () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Confirmar exclusão",
                      style: textStyleCustom(
                        fontSize: 16,
                        color: first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      "Tem certeza que deseja excluir a coleção de mídias \"$selectedMediaCollection\"?",
                      style: textStyleCustom(fontSize: 16, color: first),
                    ),
                    actions: [
                      CustomActionButton(
                        label: "Cancelar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                      CustomActionButton(
                        label: "Excluir",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  mediaCollectionService.deleteMediaCollection(
                    selectedMediaCollection!,
                  );

                  setState(() {
                    mediaCollection
                      ..clear()
                      ..addAll(mediaCollectionService.mediaCollectionNames);

                    onCollectionChanged(null);

                    for (int i = 0; i < filePathsMedias.length; i++) {
                      filePathsMedias[i] = null;
                      fileNamesMedias[i] = null;
                      backgroundColorMedias[i] = secondaryColor;
                      fontColorMedias[i] = fontColorDefault;
                      volumeMedias[i] = gainDefault;
                      hotkeysMedias[i] = hotkeyDefault;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: first,
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Coleção de Mídias "$selectedMediaCollection" excluída com sucesso!',
                              style: textStyleCustom(
                                fontSize: 16,
                                color: second,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Tooltip(
      message: selectedMediaCollection != null
          ? 'Salvar na coleção de mídias selecionada'
          : 'Nenhuma coleção de mídias selecionada para salvar',
      textStyle: textStyleCustom(fontSize: 16, color: second),
      child: IconButton(
        icon: Icon(
          Icons.save,
          color: selectedMediaCollection != null
              ? primaryColor
              : secondaryColor,
        ),
        onPressed: selectedMediaCollection != null
            ? () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Confirmar",
                      style: textStyleCustom(
                        fontSize: 16,
                        color: first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      "Deseja salvar a alteração na coleção de mídias '$selectedMediaCollection'?",
                      style: textStyleCustom(fontSize: 16, color: first),
                    ),
                    actions: [
                      CustomActionButton(
                        label: "Cancelar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                      CustomActionButton(
                        label: "Salvar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    MediaCollection updatedCollection = MediaCollection(
                      collectionName: selectedMediaCollection!,
                      mediaPaths: getAllMediaPaths(
                        replaceDragHere(filePathsMedias),
                      ),
                      backgroundColor: getAllBackgroundColors(
                        backgroundColorMedias,
                      ),
                      fontColor: getAllFontColors(
                        fontColorMedias,
                        fontColorDefault,
                      ),
                      gains: getAllGains(volumeMedias, gainDefault),
                      hotKeys: getAllHotkeys(hotkeysMedias, hotkeyDefault),
                    );

                    mediaCollectionService.updateMediaCollection(
                      selectedMediaCollection!,
                      updatedCollection,
                    );

                    setState(() {
                      mediaCollection.clear();
                      mediaCollection.addAll(
                        mediaCollectionService.mediaCollectionNames,
                      );

                      mediaCollectionNameController.clear();
                    });

                    showCustomSnackBar(
                      context,
                      message:
                          'Alterações salvas na coleção de mídias "$selectedMediaCollection" com sucesso!',
                      background: first,
                      textColor: second,
                      iconColor: Colors.greenAccent,
                      icon: Icons.check_circle,
                    );
                  } catch (e) {
                    showCustomSnackBar(
                      context,
                      message:
                          'Erro ao salvar na coleção de mídias "$selectedMediaCollection". Tente novamente.',
                      background: Colors.red,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      icon: Icons.error,
                    );
                  }
                }
              }
            : null,
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    bool hasMedia = filePathsMedias.any((p) => p != null && p.isNotEmpty);

    return Tooltip(
      message: hasMedia
          ? 'Limpar seleção e criar nova coleção'
          : 'Nenhum arquivo válido para restaurar',
      textStyle: textStyleCustom(fontSize: 16, color: second),
      child: IconButton(
        icon: Icon(
          Icons.restore,
          color: hasMedia ? primaryColor : secondaryColor,
        ),
        onPressed: hasMedia ? () async {
          resetState();
        } : null,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Tooltip(
      message: filePathsMedias.any((p) => p != null && p.isNotEmpty)
          ? 'Adicionar nova coleção de mídias'
          : 'Nenhum arquivo válido para adicionar à coleção de mídias',
      textStyle: textStyleCustom(fontSize: 16, color: second),
      child: IconButton(
        icon: Icon(
          Icons.playlist_add,
          color: filePathsMedias.any((p) => p != null && p.isNotEmpty)
              ? primaryColor
              : secondaryColor,
        ),
        onPressed: filePathsMedias.any((p) => p != null && p.isNotEmpty)
            ? () async {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Nova Coleção de Mídias",
                      style: textStyleCustom(fontSize: 16, color: first),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Insira o nome da nova playlist:",
                          style: textStyleCustom(fontSize: 16, color: first),
                        ),

                        const SizedBox(height: 10),
                        TextField(
                          maxLength: 50,
                          controller: mediaCollectionNameController,
                          decoration: InputDecoration(
                            labelText: 'Nome da Playlist',
                            labelStyle: textStyleCustom(
                              fontSize: 16,
                              color: first,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      CustomActionButton(
                        label: "Cancelar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),

                      CustomActionButton(
                        label: "Salvar",
                        backgroundColor: first,
                        textColor: second,
                        onPressed: () {
                          String newName = mediaCollectionNameController.text
                              .trim();

                          if (newName.isEmpty) {
                            showCustomSnackBar(
                              context,
                              message:
                                  'Por favor, insira um nome para a playlist.',
                              background: Colors.red,
                              textColor: Colors.white,
                              icon: Icons.warning,
                              iconColor: Colors.yellowAccent,
                            );
                          } else if (mediaCollection
                              .map((e) => e.toLowerCase())
                              .contains(newName.toLowerCase())) {
                            showCustomSnackBar(
                              context,
                              message:
                                  'A playlist "$newName" já está cadastrada.',
                              background: Colors.red,
                              textColor: Colors.white,
                              icon: Icons.error,
                              iconColor: Colors.white,
                            );
                          } else {
                            try {
                              MediaCollection newCollection = MediaCollection(
                                collectionName: newName,
                                mediaPaths: getAllMediaPaths(
                                  replaceDragHere(filePathsMedias),
                                ),
                                backgroundColor: getAllBackgroundColors(
                                  backgroundColorMedias,
                                ),
                                fontColor: getAllFontColors(
                                  fontColorMedias,
                                  fontColorDefault,
                                ),
                                gains: getAllGains(volumeMedias, gainDefault),
                                hotKeys: getAllHotkeys(
                                  hotkeysMedias,
                                  hotkeyDefault,
                                ),
                              );

                              mediaCollectionService.saveMediaCollection(
                                newCollection,
                              );

                              setState(() {
                                mediaCollection.clear();
                                mediaCollection.addAll(
                                  mediaCollectionService.mediaCollectionNames,
                                );
                                mediaCollectionNameController.clear();
                              });
                              showCustomSnackBar(
                                context,
                                message:
                                    'Coleção de Mídias "$newName" salva com sucesso!',
                                background: first,
                                textColor: second,
                                icon: Icons.check_circle,
                                iconColor: Colors.greenAccent,
                              );

                              Navigator.of(ctx).pop();
                            } catch (e) {
                              showCustomSnackBar(
                                context,
                                message:
                                    'Erro ao salvar a coleção de mídias "$newName". Tente novamente.',
                                background: Colors.red,
                                textColor: Colors.white,
                                icon: Icons.error,
                                iconColor: Colors.white,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
            : null,
      ),
    );
  }
}
