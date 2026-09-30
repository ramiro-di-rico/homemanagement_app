import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:record/record.dart';

import 'package:home_management_app/data/models/voice_transaction_draft.dart';
import 'package:home_management_app/data/repositories/transaction.repository.dart';
import 'package:home_management_app/data/services/error_notifier_service.dart';
import 'package:home_management_app/l10n/app_localizations.dart';

/// Mic button for the add-transaction form: tap to record, tap again to stop.
/// The clip is sent to the backend and the resulting draft is handed to [onDraft].
class VoiceDictationButton extends StatefulWidget {
  final int accountId;
  final ValueChanged<VoiceTransactionDraft> onDraft;

  const VoiceDictationButton(
      {super.key, required this.accountId, required this.onDraft});

  @override
  State<VoiceDictationButton> createState() => _VoiceDictationButtonState();
}

enum _DictationState { idle, recording, processing }

class _VoiceDictationButtonState extends State<VoiceDictationButton> {
  // 16 kHz mono PCM is what whisper works with internally, and streaming it
  // works the same on web, mobile and desktop (no temp files or blob URLs).
  static const int _sampleRate = 16000;
  static const Duration _maxDuration = Duration(seconds: 15);

  final AudioRecorder _recorder = AudioRecorder();
  final BytesBuilder _pcm = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _subscription;
  Timer? _maxDurationTimer;
  _DictationState _state = _DictationState.idle;

  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    _subscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final strings = AppLocalizations.of(context)!;
    if (!await _recorder.hasPermission()) {
      _notify(strings.microphonePermissionDenied, isError: true);
      return;
    }

    _pcm.clear();
    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
    ));
    _subscription = stream.listen(_pcm.add);
    _maxDurationTimer = Timer(_maxDuration, _stop);
    setState(() => _state = _DictationState.recording);
  }

  Future<void> _stop() async {
    if (_state != _DictationState.recording) return;
    _maxDurationTimer?.cancel();
    final strings = AppLocalizations.of(context)!;
    setState(() => _state = _DictationState.processing);

    try {
      await _recorder.stop();
      await _subscription?.cancel();
      _subscription = null;

      final draft = await GetIt.I<TransactionRepository>()
          .previewVoiceTransaction(widget.accountId, _toWav(_pcm.takeBytes()));
      if (!mounted) return;
      widget.onDraft(draft);
      _notify(strings.voiceHeard(draft.rawTranscription));
    } catch (_) {
      _notify(strings.voicePreviewFailed, isError: true);
    } finally {
      if (mounted) setState(() => _state = _DictationState.idle);
    }
  }

  void _notify(String message, {bool isError = false}) =>
      GetIt.I<NotifierService>().notify(message, isError: isError);

  static Uint8List _toWav(Uint8List pcm) {
    const channels = 1, bitsPerSample = 16;
    const byteRate = _sampleRate * channels * bitsPerSample ~/ 8;
    final header = ByteData(44)
      ..setUint32(0, 0x52494646) // "RIFF"
      ..setUint32(4, 36 + pcm.length, Endian.little)
      ..setUint32(8, 0x57415645) // "WAVE"
      ..setUint32(12, 0x666d7420) // "fmt "
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little) // PCM
      ..setUint16(22, channels, Endian.little)
      ..setUint32(24, _sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, channels * bitsPerSample ~/ 8, Endian.little)
      ..setUint16(34, bitsPerSample, Endian.little)
      ..setUint32(36, 0x64617461) // "data"
      ..setUint32(40, pcm.length, Endian.little);
    return (BytesBuilder(copy: false)
          ..add(header.buffer.asUint8List())
          ..add(pcm))
        .takeBytes();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    switch (_state) {
      case _DictationState.processing:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator()),
        );
      case _DictationState.recording:
        return IconButton(
          icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
          tooltip: strings.stopRecording,
          onPressed: _stop,
        );
      case _DictationState.idle:
        return IconButton(
          icon: const Icon(Icons.mic),
          tooltip: strings.dictateTransaction,
          onPressed: _start,
        );
    }
  }
}
