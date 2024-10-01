import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:readygreen/widgets/map/speechsearch.dart';
import 'package:lottie/lottie.dart';

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening(BuildContext context) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _voiceInput = '';
      });
      _speech.listen(onResult: (val) {
        setState(() {
          _voiceInput = val.recognizedWords;
        });

        // 음성 인식 결과 로그 출력
        print('Recognized Words: $_voiceInput');

        if (val.finalResult) {
          _stopListening(context);
        }
      });

      // 음성 인식 다이얼로그 표시
      SpeechSearchDialog.show(context, _voiceInput, 'assets/images/mic.png');
    }
  }

  void _stopListening(BuildContext context) {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    SpeechSearchDialog.hide(context); // 다이얼로그 닫기
    if (_voiceInput.isNotEmpty) {
      widget.onSearchSubmitted(_voiceInput); // 검색창에 음성 인식 결과 반영
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Icon(Icons.search, color: Colors.black54),
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
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.black54),
            onPressed: _isListening
                ? () => _stopListening(context)
                : () => _startListening(context),
          ),
        ],
      ),
    );
  }
}
