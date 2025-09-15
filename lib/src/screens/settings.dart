import 'package:digicart/src/utils/colors.dart';
import 'package:digicart/src/utils/text_format_style.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:digicart/src/utils/helpers.dart';
import 'package:digicart/src/services/settings_service.dart';
import 'package:file_picker/file_picker.dart';
import '../components/custom_button.dart';
import '../components/snackbar_helper.dart';

class SettingsPage extends StatefulWidget {
  List<AudioDevice> audioDevices;
  AudioDevice selectedDevice;
  Player player;

  SettingsPage({
    super.key,
    required this.audioDevices,
    required this.selectedDevice,
    required this.player,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _pathController;
  late AudioDevice _selectedDeviceTemp;

  Future<void> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _pathController.text = selectedDirectory;
      });
      debugPrint('📂 Pasta selecionada: $selectedDirectory');
    }
  }

  @override
  void initState() {
    super.initState();

    _pathController = TextEditingController(
      text: SettingsService.mediaSavePath ?? '',
    );
    widget.audioDevices.forEach(print);

    final savedName = SettingsService.selectedAudioDeviceName;

    if (savedName != null) {
      final matchedDevice = widget.audioDevices.firstWhere(
        (d) => d.name == savedName,
        orElse: () => widget.selectedDevice,
      );

      widget.selectedDevice = matchedDevice;
      widget.player.setAudioDevice(matchedDevice);

      debugPrint(
        '🔄 Dispositivo de áudio restaurado: ${formatAudioDeviceName(matchedDevice)}',
      );
    }

    _selectedDeviceTemp = widget.selectedDevice;
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  void _applySettings() {
    final path = _pathController.text.trim();

    if (path.isNotEmpty) {
      SettingsService.setMediaSavePath(path);
      debugPrint('💾 Caminho de mídia salvo: $path');
    }

    SettingsService.setSelectedAudioDeviceName(_selectedDeviceTemp.name);
    widget.player.setAudioDevice(_selectedDeviceTemp);
    debugPrint(
      '🎧 Dispositivo salvo: ${formatAudioDeviceName(_selectedDeviceTemp)}',
    );

    showCustomSnackBar(
      context,
      message: 'Configurações salvas com sucesso!',
      icon: Icons.check_circle,
      background: first,
      iconColor: Colors.green,
      textColor: second,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: IconThemeData(color: first),
        centerTitle: true,
        title: Text(
          'Configurações',
          style: textStyleCustom(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 24,
            color: first,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: second, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          width: 700,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Caminho para salvar mídias:',
                    style: textStyleCustom(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: textStyleCustom(
                          color: first,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                        controller: _pathController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Selecione uma pasta...',
                          hintStyle: textStyleCustom(),
                          fillColor: first.withValues(alpha: 0.05),
                          floatingLabelStyle: textStyleCustom(color: first),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _pickDirectory,
                      icon: const Icon(Icons.folder_open, color: first),
                      tooltip: 'Selecionar pasta',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecione o dispositivo áudio:',
                    style: textStyleCustom(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.audioDevices.isEmpty)
                  Text(
                    'Nenhum dispositivo de áudio disponível.',
                    style: textStyleCustom(fontWeight: FontWeight.normal),
                  )
                else
                  DropdownButton<AudioDevice>(
                    dropdownColor: Colors.white,
                    itemHeight: 60.0,
                    alignment: AlignmentDirectional.center,
                    isExpanded: true,
                    value: _selectedDeviceTemp,
                    items: widget.audioDevices.map((device) {
                      return DropdownMenuItem<AudioDevice>(
                        alignment: AlignmentDirectional.center,
                        value: device,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                formatAudioDeviceName(device),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: textStyleCustom(
                                  color: first,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (AudioDevice? device) {
                      if (device == null) return;
                      setState(() {
                        _selectedDeviceTemp = device;
                      });
                    },
                  ),

                const SizedBox(height: 60),

                CustomActionButton(
                  label: "Salvar Configurações",
                  backgroundColor: fontColorDefault,
                  textColor: second,
                  onPressed: _applySettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
