import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

const APP_ID = "1d48332c5bb64d82ae0567d5e9cd47b5";
const TOKEN = "";
const CHANNEL = "video";

class AgoraService {
  final RtcEngine _engine;
  bool _joined = false;
  int? remoteUid;
  bool localVideoEnabled = true;
  bool localAudioEnabled = true;

  AgoraService._(this._engine);

  static Future<AgoraService> create() async {
    if (APP_ID.startsWith('<')) {
      throw Exception('Please set your Agora APP_ID in agora_service.dart');
    }
    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: APP_ID));
    await engine.enableVideo();
    await engine.startPreview();

    final service = AgoraService._(engine);
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          service._joined = true;
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          service.remoteUid = remoteUid;
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (service.remoteUid == remoteUid) {
            service.remoteUid = null;
          }
        },
      ),
    );

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
    _joined = false;
    remoteUid = null;
  }

  setAudioEnabled(bool enabled) {
    localAudioEnabled = enabled;
    _engine.muteLocalAudioStream(!enabled);
  }

  setVideoEnabled(bool enabled) {
    localVideoEnabled = enabled;
    if (enabled) {
      _engine.startPreview();
      _engine.muteLocalVideoStream(false);
    } else {
      _engine.muteLocalVideoStream(true);
      _engine.stopPreview();
    }
  }

  Future<void> startScreenShare() async {
    debugPrint('Screen share requested - platform-specific implementation required.');
  }

  RtcEngine get engine => _engine;
  bool get joined => _joined;
}
