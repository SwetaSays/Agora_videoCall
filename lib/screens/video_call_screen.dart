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

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Request permissions
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera & microphone permissions required')),
      );
      return;
    }

    // Initialize Agora
    final service = await ref.read(agoraServiceProvider.future);
    _service = service;
    await service.join();
    setState(() => _joined = true);

    // Event handlers
    service.engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, uid, elapsed) {
        setState(() => _remoteUid = uid);
      },
      onUserOffline: (connection, uid, reason) {
        if (_remoteUid == uid) setState(() => _remoteUid = null);
      },
    ));
  }

  @override
  void dispose() {
    _service?.leave();
    super.dispose();
  }

  Widget _renderLocal() {
    if (!_joined || _service == null) return const Center(child: Text("Joining..."));
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _service!.engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemote() {
    if (_remoteUid == null) return const Center(child: Text("Waiting for remote..."));
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _service!.engine,
        canvas: VideoCanvas(uid: _remoteUid!),
        connection: const RtcConnection(channelId: "video"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _renderLocal()),
                Expanded(child: _renderRemote()),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                icon: const Icon(Icons.call_end),
                color: Colors.red,
                onPressed: () {
                  _service?.leave();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
