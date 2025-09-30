import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

const APP_ID = "1d48332c5bb64d82ae0567d5e9cd47b5";
const TOKEN = null; // Temporary token or null for testing
const CHANNEL = "video";

class AgoraService {
  late final RtcEngine _engine;
  bool joined = false;
  int? remoteUid;
  bool localVideoEnabled = true;
  bool localAudioEnabled = true;

  AgoraService._();

  static Future<AgoraService> create() async {
    if (APP_ID.isEmpty) {
      throw Exception("Please set your Agora APP_ID");
    }

    final service = AgoraService._();
    service._engine = createAgoraRtcEngine();
    await service._engine.initialize(RtcEngineContext(appId: APP_ID));
    await service._engine.enableVideo();
    await service._engine.startPreview();

    // Event handlers
    service._engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint("Joined channel: ${connection.channelId}");
        service.joined = true;
      },
      onUserJoined: (connection, uid, elapsed) {
        debugPrint("Remote user joined: $uid");
        service.remoteUid = uid;
      },
      onUserOffline: (connection, uid, reason) {
        if (service.remoteUid == uid) service.remoteUid = null;
      },
    ));

    return service;
  }

  Future<void> join() async {
    await _engine.joinChannel(
      token: TOKEN,
      channelId: CHANNEL,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leave() async {
    await _engine.leaveChannel();
    joined = false;
    remoteUid = null;
  }

  void setAudioEnabled(bool enabled) {
    localAudioEnabled = enabled;
    _engine.muteLocalAudioStream(!enabled);
  }

  void setVideoEnabled(bool enabled) {
    localVideoEnabled = enabled;
    if (enabled) {
      _engine.startPreview();
      _engine.muteLocalVideoStream(false);
    } else {
      _engine.muteLocalVideoStream(true);
      _engine.stopPreview();
    }
  }

  RtcEngine get engine => _engine;
}
