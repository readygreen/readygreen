import 'package:flutter/material.dart';

class MapSearchBackBar extends StatelessWidget {
  final String placeName;
  final Function(String) onSearchSubmitted;
  final Function() onVoiceSearch;
  final Function(String) onSearchChanged;
  final Function()? onTap;

  const MapSearchBackBar({
    super.key,
    required this.placeName,
    required this.onSearchSubmitted,
    required this.onVoiceSearch,
    required this.onSearchChanged,
    this.onTap,
  });

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
          Expanded(
            child: TextField(
              controller: TextEditingController(text: placeName),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onTap: onTap,
              onChanged: onSearchChanged,
              onSubmitted: (value) {
                onSearchSubmitted(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.black54),
            onPressed: () {
              onVoiceSearch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black54),
            onPressed: () {
              // X 버튼을 누르면 지도 화면으로 돌아가기
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
