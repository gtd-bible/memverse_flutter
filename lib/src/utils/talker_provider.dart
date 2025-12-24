import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'talker_provider.g.dart';

@riverpod
Talker talker(TalkerRef ref) {
  return TalkerFlutter.init();
}
