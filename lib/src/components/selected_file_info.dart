import 'package:digicart/src/utils/helpers.dart';
import 'package:digicart/src/utils/text_format_style.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SelectedFileInfo extends StatelessWidget {
  final Duration remaining;
  final AnimationController animationController;
  final AnimationController animationController1;
  final bool isPlaying;
  final int? selectedIndex;
  final List<String?> fileNamesMedias;
  final String Function(Duration) formatTimeRemaining;

  const SelectedFileInfo({
    super.key,
    required this.remaining,
    required this.animationController,
    required this.animationController1,
    required this.isPlaying,
    required this.selectedIndex,
    required this.fileNamesMedias,
    required this.formatTimeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    if (remaining.inSeconds <= 10 && !animationController1.isAnimating) {
      animationController1.repeat(reverse: true);
    } else if (remaining.inSeconds > 10 && animationController1.isAnimating) {
      animationController1.stop();
      animationController1.value = 1.0;
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  selectedIndex != null &&
                          fileNamesMedias[selectedIndex!] != null
                      ? getFileName(fileNamesMedias[selectedIndex!]!)
                      : '',
                  style: textStyleCustom(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                    color: first,
                  ),
                ),
              ),
            ),
          ),

          if (isPlaying)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: remaining.inSeconds <= 10
                          ? animationController.value
                          : 1.0,
                      child: Text(
                        formatTimeRemaining(remaining),
                        style: textStyleCustom(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: remaining.inSeconds <= 10 ? 24 : 22,
                          color: remaining.inSeconds <= 10 ? Colors.red : first,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
