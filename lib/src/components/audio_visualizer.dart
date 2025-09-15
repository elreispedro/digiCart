import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AudioVisualizer extends StatelessWidget {
  final Stream<double> volumeStream;

  const AudioVisualizer({super.key, required this.volumeStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: volumeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        double volume = snapshot.data!;
        return BarGraph(volume: volume);
      },
    );
  }
}

class BarGraph extends StatelessWidget {
  final double volume;

  const BarGraph({super.key, required this.volume});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        double barHeight = volume * (index + 1) * 10;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 10,
            height: barHeight,
            color: first,
          ),
        );
      }),
    );
  }
}

class MediaPlayerWidget extends StatefulWidget {
  const MediaPlayerWidget({super.key});

  @override
  _MediaPlayerWidgetState createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  final StreamController<double> _volumeStreamController =
      StreamController<double>();
  double _currentVolume = 0.5;

  @override
  void dispose() {
    _volumeStreamController.close();
    super.dispose();
  }

  void _setVolume(double volume) {
    setState(() {
      _currentVolume = volume;
      _volumeStreamController.add(volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AudioVisualizer(volumeStream: _volumeStreamController.stream),
        Slider(
          min: 0.0,
          max: 1.0,
          value: _currentVolume,
          onChanged: (value) {
            _setVolume(value);
          },
        ),
      ],
    );
  }
}
