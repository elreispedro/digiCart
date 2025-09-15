import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_format_style.dart';
import '../../custom_button.dart';

Future<void> showAudioGainDialog({
  required BuildContext context,
  required int index,
  required List<double> volumeMedias,
  required Color fontColorDefault,
  required void Function(double nivelAudio, int index) onSaved,
}) async {
  double nivelAudio = volumeMedias[index];

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Selecione o nível do volume de áudio',
              style: textStyleCustom(
                fontSize: 16,
                color: fontColorDefault,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  activeColor: fontColorDefault,
                  value: nivelAudio,
                  onChanged: (value) {
                    setState(() => nivelAudio = value);
                  },
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: nivelAudio.floor().toString(),
                ),
                Text(
                  'Volume: ${nivelAudio.floor()}',
                  style: textStyleCustom(fontSize: 14, color: fontColorDefault),
                ),
              ],
            ),
            actions: [
              CustomActionButton(
                label: "Cancelar",
                backgroundColor: fontColorDefault,
                textColor: second,
                onPressed: () => Navigator.of(context).pop(),
              ),
              CustomActionButton(
                label: "Salvar",
                backgroundColor: fontColorDefault,
                textColor: second,
                onPressed: () {
                  onSaved(nivelAudio, index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
