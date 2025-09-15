import 'package:digicart/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/text_format_style.dart';
import '../../custom_button.dart';

Future<void> showShortcutDialog({
  required BuildContext context,
  required int index,
  required List<String?> hotkeysMedias,
  required void Function(String? shortcut, int index) onSaved,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      String? shortcut = hotkeysMedias[index];
      FocusNode focusNode = FocusNode();

      return AlertDialog(
        backgroundColor: second,
        title: Text(
          'Definir tecla de atalho',
          style: textStyleCustom(
            fontSize: 16,
            color: first,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Pressione uma combinação de teclas usando ao menos uma tecla modificadora (Ctrl, Shift ou Alt).\n'
                  'As teclas de função (F1–F12) não são permitidas.',
                  style: textStyleCustom(fontSize: 14, color: first),
                ),
                const SizedBox(height: 10),
                KeyboardListener(
                  focusNode: focusNode,
                  autofocus: true,
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent) {
                      final keys = <String>[];

                      // Obtém todas as teclas atualmente pressionadas
                      final pressedKeys =
                          HardwareKeyboard.instance.logicalKeysPressed;

                      if (pressedKeys.contains(
                            LogicalKeyboardKey.controlLeft,
                          ) ||
                          pressedKeys.contains(
                            LogicalKeyboardKey.controlRight,
                          )) {
                        keys.add('Ctrl');
                      }
                      if (pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
                          pressedKeys.contains(LogicalKeyboardKey.shiftRight)) {
                        keys.add('Shift');
                      }
                      if (pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
                          pressedKeys.contains(LogicalKeyboardKey.altRight)) {
                        keys.add('Alt');
                      }

                      // Tecla principal
                      final keyLabel = event.logicalKey.keyLabel;

                      // Verifica se NÃO é F1-F12
                      final isFunctionKey =
                          keyLabel.startsWith('F') &&
                          int.tryParse(keyLabel.substring(1)) != null &&
                          int.parse(keyLabel.substring(1)) >= 1 &&
                          int.parse(keyLabel.substring(1)) <= 12;

                      if (keyLabel.isNotEmpty && !isFunctionKey) {
                        keys.add(keyLabel);
                      }

                      // Registra apenas se houver pelo menos 1 modificador válido
                      if (keys.isNotEmpty &&
                          keys.any(
                            (k) => ['Ctrl', 'Shift', 'Alt'].contains(k),
                          )) {
                        shortcut = keys.join(' + ');
                        setState(() {});
                      }
                    }
                  },
                  child: GestureDetector(
                    onTap: () => focusNode.requestFocus(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        shortcut ?? 'Nenhuma combinação selecionada',
                        style: textStyleCustom(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: first,
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
          CustomActionButton(
            label: "Cancelar",
            backgroundColor: first,
            textColor: second,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomActionButton(
            label: "Salvar",
            backgroundColor: first,
            textColor: second,
            onPressed: () {
              if (shortcut != null) {
                if (hotkeysMedias.contains(shortcut) &&
                    hotkeysMedias.indexOf(shortcut) != index) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Erro',
                        style: textStyleCustom(
                          fontSize: 16,
                          color: first,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Essa combinação já está configurada em outra posição.',
                        style: textStyleCustom(fontSize: 14, color: first),
                      ),
                      actions: [
                        CustomActionButton(
                          label: "Ok",
                          backgroundColor: first,
                          textColor: second,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                } else {
                  onSaved(shortcut, index);
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}
