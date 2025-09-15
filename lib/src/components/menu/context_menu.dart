// import 'package:flutter/material.dart';
// import '../../utils/colors.dart';
// import '../../utils/text_format_style.dart';

// Future<void> showMediaContextMenu({
//   required BuildContext context,
//   required TapDownDetails details,
//   required int index,
//   required List<String?> fileNamesMedias,
//   required Color fontColorDefault,
//   required List<Color> backgroundColorMedias,
//   required List<Color> fontColorMedias,

//   required void Function(String? value, int index, TapDownDetails details)
//   onSelected,
// }) async {
//   final value = await showMenu<String>(
//     context: context,
//     position: RelativeRect.fromLTRB(
//       details.globalPosition.dx,
//       details.globalPosition.dy,
//       details.globalPosition.dx + 1,
//       details.globalPosition.dy + 1,
//     ),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     color: second,
//     items: [
//       PopupMenuItem<String>(
//         value: 'select',
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.audio_file_sharp, color: first),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Selecionar o arquivo de mídia',
//                   style: textStyleCustom(fontSize: 14, color: first),
//                 ),
//               ],
//             ),
//             const Icon(Icons.chevron_right, color: Colors.transparent),
//           ],
//         ),
//       ),
//       PopupMenuItem<String>(
//         value: 'remove',
//         enabled:
//             fileNamesMedias[index] != null &&
//             fileNamesMedias[index]!.isNotEmpty,
//         child: Visibility(
//           visible: fileNamesMedias[index] != null,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.delete, color: first),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Remover arquivo',
//                     style: textStyleCustom(fontSize: 14, color: first),
//                   ),
//                 ],
//               ),
//               const Icon(Icons.chevron_right, color: Colors.transparent),
//             ],
//           ),
//         ),
//       ),
//       PopupMenuItem<String>(
//         value: 'choose_color',
//         enabled:
//             fileNamesMedias[index] != null &&
//             fileNamesMedias[index]!.isNotEmpty,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.color_lens_outlined,
//                   color: fileNamesMedias[index] != null ? first : second,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Escolher a cor',
//                   style: textStyleCustom(
//                     fontSize: 14,
//                     color: fileNamesMedias[index] != null ? first : second,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Visibility(
//                   visible: fileNamesMedias[index] != null,
//                   child: Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: backgroundColorMedias[index],
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.black12),
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.chevron_right,
//                   color: fileNamesMedias[index] != null
//                       ? fontColorDefault
//                       : second,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       PopupMenuItem<String>(
//         value: 'choose_color_font',
//         enabled:
//             fileNamesMedias[index] != null &&
//             fileNamesMedias[index]!.isNotEmpty,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.text_fields,
//                   color: fileNamesMedias[index] != null ? first : second,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Escolher a cor da fonte',
//                   style: textStyleCustom(
//                     fontSize: 14,
//                     color: fileNamesMedias[index] != null ? first : second,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Visibility(
//                   visible: fileNamesMedias[index] != null,
//                   child: Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: fontColorMedias[index],
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.black12),
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.chevron_right,
//                   color: fileNamesMedias[index] != null
//                       ? fontColorDefault
//                       : second,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       PopupMenuItem<String>(
//         value: 'select_audio_gain',
//         enabled:
//             fileNamesMedias[index] != null &&
//             fileNamesMedias[index]!.isNotEmpty,
//         child: Visibility(
//           visible: fileNamesMedias[index] != null,
//           child: Row(
//             children: [
//               Icon(Icons.volume_up, color: first),
//               const SizedBox(width: 6),
//               Text(
//                 'Selecionar volume do áudio',
//                 style: textStyleCustom(fontSize: 14, color: first),
//               ),
//             ],
//           ),
//         ),
//       ),
//       PopupMenuItem<String>(
//         value: 'set_shortcut',
//         enabled:
//             fileNamesMedias[index] != null &&
//             fileNamesMedias[index]!.isNotEmpty,
//         child: Visibility(
//           visible: fileNamesMedias[index] != null,
//           child: Row(
//             children: [
//               Icon(Icons.keyboard, color: first),
//               const SizedBox(width: 6),
//               Text(
//                 'Definir tecla de atalho',
//                 style: textStyleCustom(fontSize: 14, color: first),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );

//   onSelected(value, index, details);
// }

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_format_style.dart';

PopupMenuItem<String> buildMenuItem({
  required String value,
  required IconData icon,
  required String text,
  required int index,
  required List<String?> fileNamesMedias,
  required Color fontColorDefault,
  bool alwaysEnabled = false,
  Color? circleColor,
  bool showCircle = false,
}) {
  final isEnabled =
      alwaysEnabled ||
      (fileNamesMedias[index] != null && fileNamesMedias[index]!.isNotEmpty);

  return PopupMenuItem<String>(
    value: value,
    enabled: isEnabled,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: isEnabled ? first : second),
            const SizedBox(width: 6),
            Text(
              text,
              style: textStyleCustom(
                fontSize: 14,
                color: isEnabled ? first : second,
              ),
            ),
          ],
        ),
        if (showCircle && circleColor != null && isEnabled)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
      ],
    ),
  );
}

Future<void> showMediaContextMenu({
  required BuildContext context,
  required TapDownDetails details,
  required int index,
  required List<String?> fileNamesMedias,
  required Color fontColorDefault,
  required List<Color> backgroundColorMedias,
  required List<Color> fontColorMedias,
  required void Function(String? value, int index, TapDownDetails details)
  onSelected,
}) async {
  final items = <PopupMenuItem<String>>[
    buildMenuItem(
      value: 'select',
      icon: Icons.audio_file_sharp,
      text: 'Selecionar o arquivo de mídia',
      index: index,
      fileNamesMedias: fileNamesMedias,
      fontColorDefault: fontColorDefault,
      alwaysEnabled: true,
    ),
  ];

  if (fileNamesMedias[index] != null && fileNamesMedias[index]!.isNotEmpty) {
    items.addAll([
      buildMenuItem(
        value: 'remove',
        icon: Icons.delete,
        text: 'Remover arquivo',
        index: index,
        fileNamesMedias: fileNamesMedias,
        fontColorDefault: fontColorDefault,
      ),
      buildMenuItem(
        value: 'choose_color',
        icon: Icons.color_lens_outlined,
        text: 'Escolher a cor',
        index: index,
        fileNamesMedias: fileNamesMedias,
        fontColorDefault: fontColorDefault,
        circleColor: backgroundColorMedias[index],
        showCircle: true,
      ),
      buildMenuItem(
        value: 'choose_color_font',
        icon: Icons.text_fields,
        text: 'Escolher a cor da fonte',
        index: index,
        fileNamesMedias: fileNamesMedias,
        fontColorDefault: fontColorDefault,
        circleColor: fontColorMedias[index],
        showCircle: true,
      ),
      buildMenuItem(
        value: 'select_audio_gain',
        icon: Icons.volume_up,
        text: 'Selecionar volume do áudio',
        index: index,
        fileNamesMedias: fileNamesMedias,
        fontColorDefault: fontColorDefault,
      ),
      buildMenuItem(
        value: 'set_shortcut',
        icon: Icons.keyboard,
        text: 'Definir tecla de atalho',
        index: index,
        fileNamesMedias: fileNamesMedias,
        fontColorDefault: fontColorDefault,
      ),
    ]);
  }

  final value = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx + 1,
      details.globalPosition.dy + 1,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: second,
    items: items,
  );

  onSelected(value, index, details);
}
