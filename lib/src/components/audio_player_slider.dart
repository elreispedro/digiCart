import 'dart:async';
import 'package:digicart/src/utils/helpers.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_format_style.dart';

class AudioPlayerSlider extends StatefulWidget {
  final Stream<Duration> positionStream;
  final Stream<Duration> durationStream;
  final Future<void> Function(Duration) onSeek;

  const AudioPlayerSlider({
    super.key,
    required this.positionStream,
    required this.durationStream,
    required this.onSeek,
  });

  @override
  _AudioPlayerSliderState createState() => _AudioPlayerSliderState();
}

class _AudioPlayerSliderState extends State<AudioPlayerSlider> {
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isDragging = false;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;

  @override
  void initState() {
    super.initState();

    _positionSubscription = widget.positionStream.listen((position) {
      if (!_isDragging) {
        if (mounted) {
          setState(() {
            _currentPosition = position > _totalDuration
                ? _totalDuration
                : position;
          });
        }
      }
    });

    _durationSubscription = widget.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
          if (_currentPosition > _totalDuration) {
            _currentPosition = _totalDuration;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatDuration(_currentPosition),
                style: textStyleCustom(
                  color: _totalDuration.inMilliseconds != 0
                      ? first
                      : Colors.grey.withValues(alpha: .3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: _currentPosition.inSeconds.toDouble().clamp(
                  0.0,
                  _totalDuration.inSeconds.toDouble(),
                ),
                max: _totalDuration.inSeconds > 0
                    ? _totalDuration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) {
                  setState(() {
                    _isDragging = true;
                    _currentPosition = Duration(seconds: value.toInt());
                  });
                },
                onChangeEnd: (value) async {
                  setState(() {
                    _isDragging = false;
                  });
                  await widget.onSeek(Duration(seconds: value.toInt()));
                },
                activeColor: _totalDuration.inMilliseconds != 0
                    ? first
                    : Colors.grey.withValues(alpha: .3),
                inactiveColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatDuration(_totalDuration - _currentPosition),
                style: textStyleCustom(
                  color: _totalDuration.inMilliseconds == 0
                      ? Colors.grey.withValues(alpha: 0.3)
                      : (_totalDuration - _currentPosition).inSeconds <= 10
                      ? Colors.red
                      : first,

                  fontStyle: (_totalDuration - _currentPosition).inSeconds <= 10
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
