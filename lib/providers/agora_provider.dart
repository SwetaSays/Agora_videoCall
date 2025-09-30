import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/agora_service.dart';

final agoraServiceProvider = FutureProvider<AgoraService>((ref) async {
  final service = await AgoraService.create();
  return service;
});
