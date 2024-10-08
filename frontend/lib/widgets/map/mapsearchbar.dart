import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:readygreen/widgets/map/speechsearch.dart';
import 'package:readygreen/constants/appcolors.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onSearchSubmitted;
  final Function(String) onSearchChanged;
  final Function()? onTap;
  final String? initialValue;

  const MapSearchBar({
    super.key,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    this.onTap,
    this.initialValue,
  });

  @override
  _MapSearchBarState createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening(BuildContext context) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _voiceInput = '';
      });

      // 5초 타이머 시작
      _startTimer(context);

      _speech.listen(onResult: (val) {
        if (mounted) {
          setState(() {
            _voiceInput = val.recognizedWords;
          });
        }

        // 음성 인식 결과 로그 출력
        print('Recognized Words: $_voiceInput');

        if (val.finalResult) {
          _stopListening(context);
        }
      });

      // 음성 인식 다이얼로그 표시
      SpeechSearchDialog.show(context, _voiceInput, 'assets/images/mic.png');
    } else {
      _showFailureDialog(context, '음성 인식 초기화 실패');
      print('음성 인식 초기화 실패');
    }
  }

  void _startTimer(BuildContext context) {
    // 5초 동안 말하지 않으면 음성 인식 중지 및 실패 알림
    _timer = Timer(const Duration(seconds: 5), () {
      if (_isListening) {
        _stopListening(context);
        _showFailureDialog(context, '음성 검색에 실패하였습니다. 다시 시도해 주세요.');
      }
    });
  }

  void _stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel(); // 타이머 중지
    }
  }

  void _stopListening(BuildContext context) {
    if (_isListening) {
      _speech.stop();
      _stopTimer(); // 타이머도 중지
      setState(() {
        _isListening = false;
      });
      SpeechSearchDialog.hide(context); // 다이얼로그 닫기
      if (_voiceInput.isNotEmpty) {
        print('음성 인식 결과 전달: $_voiceInput'); // 음성 인식 결과 로그 출력
        widget.onSearchSubmitted(_voiceInput); // 검색창에 음성 인식 결과 반영
      } else {
        print('음성 인식 결과가 비어 있습니다.');
      }
    }
  }

  // 음성 인식 실패 시 알림을 표시하는 다이얼로그
  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('음성 인식 실패'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _stopTimer(); // 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.black),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: widget.initialValue ?? '', // 초기값이 없으면 빈칸 처리
              decoration: const InputDecoration(
                hintText: '검색어를 입력하세요.',
                border: InputBorder.none,
              ),
              onTap: widget.onTap,
              onChanged: widget.onSearchChanged,
              onFieldSubmitted: widget.onSearchSubmitted,
            ),
          ),
          // IconButton(
          //   icon: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded,
          //       color: AppColors.black),
          //   onPressed: _isListening
          //       ? () => _stopListening(context)
          //       : () => _startListening(context),
          // ),
        ],
      ),
    );
  }
}
