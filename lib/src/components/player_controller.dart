import 'package:digicart/src/components/audio_player_slider.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../utils/colors.dart';
import '../utils/text_format_style.dart';

class CustomPlayerWidget extends StatefulWidget {
  final int? selectedIndex;
  final List<String?> fileNames;
  final List<AudioDevice> audioDevices;
  late AudioDevice selectedDevice;
  final PlaylistMode playlistMode;
  final Player player;
  final bool mediaVideoIsNotEmpty;
  final Function onPlay;
  final Function onPause;
  final Function onStop;
  final Function onEject;
  final Function onFastForward;
  final Function onRewind;
  late double volume;
  late Duration remaining;

  CustomPlayerWidget({
    super.key,
    this.selectedIndex,
    required this.fileNames,
    required this.player,
    required this.playlistMode,
    required this.mediaVideoIsNotEmpty,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onEject,
    required this.volume,
    required this.remaining,
    required this.onFastForward,
    required this.onRewind,
    required this.audioDevices,
    required this.selectedDevice,
  });

  @override
  State<CustomPlayerWidget> createState() => _CustomPlayerWidgetState();
}

late AnimationController _animationController;
bool _isBlinking = false;
double _currentPlaybackRate = 1.0;
AudioDevice? _selectedDevice;
final List<double> values = [];
bool _isLooping = false;

class _CustomPlayerWidgetState extends State<CustomPlayerWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    widget.player.setVolume(100);
    widget.player.setRate(_currentPlaybackRate);

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
    _selectedDevice = widget.selectedDevice;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * .48,
      constraints: const BoxConstraints(minWidth: 600),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: second, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.player.platform!.state.playing
                  ? 
                  
                  Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.selectedIndex != null &&
                                    widget.fileNames[widget.selectedIndex!] !=
                                        null
                                ? widget.fileNames[widget.selectedIndex!] ?? ''
                                : '',
                            style: textStyleCustom(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: widget.mediaVideoIsNotEmpty
                                  ? first
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              AudioPlayerSlider(
                positionStream: widget.player.stream.position,
                durationStream: widget.player.stream.duration,
                onSeek: (duration) async {
                  await widget.player.seek(duration);
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Play',
                    icon: Icon(
                      Icons.play_arrow,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onPlay()
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Pause',
                    icon: Icon(
                      Icons.pause,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onPause()
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Stop',
                    icon: Icon(
                      Icons.stop,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onStop()
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Ejetar',
                    icon: Icon(
                      Icons.eject,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onEject()
                        : null,
                  ),
                  Tooltip(
                    message: 'Controle de velocidade de reprodução',
                    child: SizedBox(
                      width: 100,
                      child: DropdownButton<double>(
                        iconEnabledColor: first,
                        menuWidth: 100,
                        alignment: AlignmentDirectional.center,
                        isExpanded: true,
                        value: _currentPlaybackRate,
                        items: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((
                          rate,
                        ) {
                          return DropdownMenuItem<double>(
                            alignment: AlignmentDirectional.center,
                            value: rate,
                            child: Text(
                              '${rate.toStringAsFixed(2)} x',
                              style: textStyleCustom(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.mediaVideoIsNotEmpty
                                    ? first
                                    : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: widget.mediaVideoIsNotEmpty
                            ? (value) {
                                setState(() {
                                  _currentPlaybackRate = value!;
                                  widget.player.setRate(value);
                                });
                              }
                            : null,
                        disabledHint: Text(
                          'Desabilitado',
                          style: textStyleCustom(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Diminuir volume',
                    icon: Icon(
                      Icons.volume_down,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed:
                        (widget.mediaVideoIsNotEmpty && widget.volume > 0)
                        ? () {
                            debugPrint('🔉 [Volume Down]: Reducing volume...');
                            _adjustVolume(-1.0);
                          }
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: 'Controle de volume',
                    child: SizedBox(
                      width: 70,
                      child: DropdownButton<double>(
                        iconEnabledColor: first,
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,
                        menuWidth: 100,
                        value: widget.volume.floorToDouble(),
                        items: List.generate(101, (index) => index).reversed
                            .map((value) {
                              return DropdownMenuItem<double>(
                                alignment: AlignmentDirectional.center,
                                value: value.toDouble(),
                                child: Text(
                                  '$value%',
                                  style: textStyleCustom(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: widget.mediaVideoIsNotEmpty
                                        ? first
                                        : Colors.grey,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                        onChanged: widget.mediaVideoIsNotEmpty
                            ? (value) {
                                setState(() {
                                  widget.volume = value!;
                                  widget.player.setVolume(value);
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Aumentar volume',
                    icon: Icon(
                      Icons.volume_up,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed:
                        (widget.mediaVideoIsNotEmpty && widget.volume < 100)
                        ? () {
                            debugPrint('🔊 [Volume Up]: Increasing volume...');
                            _adjustVolume(1.0);
                          }
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Retroceder',
                    icon: Icon(
                      Icons.fast_rewind,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onRewind()
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Avançar',
                    icon: Icon(
                      Icons.fast_forward,
                      color: widget.mediaVideoIsNotEmpty ? first : Colors.grey,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () => widget.onFastForward()
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Loop',
                    icon: Icon(
                      _isLooping ? Icons.repeat : Icons.repeat_one,
                      color: widget.mediaVideoIsNotEmpty
                          ? _isLooping
                                ? first
                                : Colors.grey
                          : null,
                    ),
                    onPressed: widget.mediaVideoIsNotEmpty
                        ? () {
                            setState(() {
                              _isLooping = !_isLooping;
                              widget.player.setPlaylistMode(
                                _isLooping
                                    ? PlaylistMode.loop
                                    : PlaylistMode.none,
                              );
                              debugPrint(
                                "🔄 PlaylistMode: ${widget.player.platform?.state.playlistMode.toString()}",
                              );
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _adjustVolume(double delta) {
    final double previousVolume = widget.volume;

    setState(() {
      widget.volume = (widget.volume + delta).clamp(0, 100).toDouble();
      widget.player.setVolume(widget.volume);

      debugPrint(
        '🔊 [Volume Adjusted]: Previous volume: $previousVolume%, New volume: $widget.volume%',
      );
      if (widget.volume == 0) {
        debugPrint('🔇 [Volume Muted]: Volume set to 0.');
      } else if (widget.volume == 100) {
        debugPrint('🔊 [Volume Maxed Out]: Volume set to maximum (100%).');
      }
    });
  }
}
