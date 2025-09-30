import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../providers/agora_provider.dart';
import '../services/agora_service.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});
  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  AgoraService? _service;
  bool _joined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _videoEnabled = true;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // request permissions first
    await _handlePermissions();
    final provider = ref.read(agoraServiceProvider.future);
    provider.then((service) async {
      _service = service;
      await service.join();
      setState(() => _joined = true);
      // listen for remoteUid changes via engine events: we'll poll engine's property, or
      // the provider can be re-created. For simplicity register a periodic update:
      service.engine.registerEventHandler(RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (connection, uid, reason) {
          setState(() {
            if (_remoteUid == uid) _remoteUid = null;
          });
        },
      ));
    }).catchError((e) {
      debugPrint('Agora init error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('RTC init failed: $e')));
    });
  }

  Future<void> _handlePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera & microphone permissions are required.')),
      );
    }
  }

  @override
  void dispose() {
    _service?.leave();
    super.dispose();
  }

  Widget _renderLocalPreview() {
    if (!_joined) {
      return const Center(child: Text('Joining...'));
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _service!.engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid == null) {
      return const Center(child: Text('Waiting for remote participant...'));
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _service!.engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: const RtcConnection(channelId: CHANNEL),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = Expanded(child: _renderLocalPreview());
    final remote = Expanded(child: _renderRemoteVideo());

    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: Column(children: [
        Expanded(
          child: Row(children: [
            Flexible(flex: 1, child: local),
            Flexible(flex: 1, child: remote),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              icon: Icon(_muted ? Icons.mic_off : Icons.mic),
              onPressed: () {
                setState(() => _muted = !_muted);
                _service?.setAudioEnabled(!_muted);
              },
            ),
            IconButton(
              icon: Icon(_videoEnabled ? Icons.videocam : Icons.videocam_off),
              onPressed: () {
                setState(() => _videoEnabled = !_videoEnabled);
                _service?.setVideoEnabled(_videoEnabled);
              },
            ),
            IconButton(
              icon: Icon(_sharing ? Icons.stop_screen_share : Icons.screen_share),
              onPressed: () async {
                setState(() => _sharing = !_sharing);
                if (_sharing) {
                  await _service?.startScreenShare();
                } else {
                  // stop share - stub
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              color: Colors.red,
              onPressed: () {
                _service?.leave();
                Navigator.of(context).pop();
              },
            ),
          ]),
        )
      ]),
    );
  }
}
