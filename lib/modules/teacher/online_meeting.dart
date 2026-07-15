import 'package:flutter/material.dart';

class OnlineMeetingScreen extends StatefulWidget {
  const OnlineMeetingScreen({super.key});

  @override
  State<OnlineMeetingScreen> createState() =>
      _OnlineMeetingScreenState();
}

class _OnlineMeetingScreenState
    extends State<OnlineMeetingScreen> {
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;
  bool _speakerEnabled = true;

  bool _classStarted = false;

  int _elapsedSeconds = 0;

  final List<Map<String, dynamic>> _participants = [
    {
      'name': 'Rajina',
      'role': 'Teacher',
      'camera': true,
      'microphone': true,
    },
    {
      'name': 'Muhammed Humraz',
      'role': 'Student',
      'camera': true,
      'microphone': false,
    },
    {
      'name': 'Arya',
      'role': 'Student',
      'camera': false,
      'microphone': true,
    },
    {
      'name': 'Rahul',
      'role': 'Student',
      'camera': true,
      'microphone': false,
    },
  ];

  String get _formattedDuration {
    final minutes = _elapsedSeconds ~/ 60;

    final seconds = _elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _startClass() {
    setState(() {
      _classStarted = true;
    });

    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Live class started',
        ),
      ),
    );
  }

  Future<void> _startTimer() async {
    while (_classStarted && mounted) {
      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!_classStarted || !mounted) {
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });
    }
  }

  Future<void> _endClass() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'End Live Class?',
          ),
          content: const Text(
            'The live classroom session will be ended for all participants.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'End Class',
              ),
            ),
          ],
        );
      },
    );

    if (shouldEnd != true || !mounted) {
      return;
    }

    setState(() {
      _classStarted = false;
    });

    Navigator.pop(context);
  }

  Widget _buildParticipantTile(
    Map<String, dynamic> participant,
    int index,
  ) {
    final cameraEnabled =
        participant['camera'] == true;

    final microphoneEnabled =
        participant['microphone'] == true;

    final isTeacher =
        participant['role'] == 'Teacher';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF25262B),
        borderRadius: BorderRadius.circular(18),
        border: isTeacher
            ? Border.all(
                color: Colors.teal,
                width: 2,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraEnabled)
            Container(
              color: Colors.blueGrey.shade800,
              child: Center(
                child: Icon(
                  Icons.person,
                  size: index == 0 ? 100 : 60,
                  color: Colors.white24,
                ),
              ),
            )
          else
            Center(
              child: CircleAvatar(
                radius: index == 0 ? 50 : 35,
                backgroundColor: isTeacher
                    ? Colors.teal
                    : Colors.indigo,
                child: Text(
                  participant['name']
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: index == 0 ? 35 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    participant['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Icon(
                    microphoneEnabled
                        ? Icons.mic
                        : Icons.mic_off,
                    size: 17,
                    color: microphoneEnabled
                        ? Colors.white
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          if (isTeacher)
            const Positioned(
              top: 10,
              left: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    'HOST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
    Color? backgroundColor,
  }) {
    final buttonColor = backgroundColor ??
        (enabled
            ? const Color(0xFF34353B)
            : Colors.red.shade700);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(
              54,
              54,
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_classStarted) {
      return _buildPreJoinScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF16171A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF16171A),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Programming in C',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Live Classroom',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 9,
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE $_formattedDuration',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Center(
            child: Text(
              '${_participants.length} Participants',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          110,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                constraints.maxWidth > 850 ? 3 : 2;

            return GridView.builder(
              itemCount: _participants.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 9,
              ),
              itemBuilder: (context, index) {
                return _buildParticipantTile(
                  _participants[index],
                  index,
                );
              },
            );
          },
        ),
      ),
      bottomSheet: Container(
        height: 95,
        color: const Color(0xFF202124),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: _microphoneEnabled
                  ? Icons.mic
                  : Icons.mic_off,
              label: _microphoneEnabled
                  ? 'Mute'
                  : 'Unmute',
              enabled: _microphoneEnabled,
              onPressed: () {
                setState(() {
                  _microphoneEnabled =
                      !_microphoneEnabled;

                  _participants[0]['microphone'] =
                      _microphoneEnabled;
                });
              },
            ),
            const SizedBox(width: 18),
            _buildControlButton(
              icon: _cameraEnabled
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: _cameraEnabled
                  ? 'Camera'
                  : 'Camera Off',
              enabled: _cameraEnabled,
              onPressed: () {
                setState(() {
                  _cameraEnabled =
                      !_cameraEnabled;

                  _participants[0]['camera'] =
                      _cameraEnabled;
                });
              },
            ),
            const SizedBox(width: 18),
            _buildControlButton(
              icon: _speakerEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
              label: 'Speaker',
              enabled: _speakerEnabled,
              onPressed: () {
                setState(() {
                  _speakerEnabled =
                      !_speakerEnabled;
                });
              },
            ),
            const SizedBox(width: 18),
            _buildControlButton(
              icon: Icons.screen_share_outlined,
              label: 'Share',
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Screen sharing will connect with the video SDK.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 18),
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End',
              backgroundColor: Colors.red,
              onPressed: _endClass,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreJoinScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF16171A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16171A),
        foregroundColor: Colors.white,
        title: const Text(
          'Start Live Class',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 290,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25262B),
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: _cameraEnabled
                            ? const Icon(
                                Icons.person,
                                size: 110,
                                color: Colors.white24,
                              )
                            : const CircleAvatar(
                                radius: 52,
                                backgroundColor:
                                    Colors.teal,
                                child: Text(
                                  'R',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 18,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    _microphoneEnabled
                                        ? Colors.white
                                        : Colors.red,
                                foregroundColor:
                                    _microphoneEnabled
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _microphoneEnabled =
                                      !_microphoneEnabled;
                                });
                              },
                              icon: Icon(
                                _microphoneEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    _cameraEnabled
                                        ? Colors.white
                                        : Colors.red,
                                foregroundColor:
                                    _cameraEnabled
                                        ? Colors.black
                                        : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _cameraEnabled =
                                      !_cameraEnabled;
                                });
                              },
                              icon: Icon(
                                _cameraEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Ready to start your class?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Programming in C • Semester 1',
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(54),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _startClass,
                  icon: const Icon(
                    Icons.video_call,
                  ),
                  label: const Text(
                    'Start Live Class',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}