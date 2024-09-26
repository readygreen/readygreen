import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final Function(String) onSearchSubmitted;
  // final Function() onVoiceSearch;
  final Function(String) onSearchChanged;
  final Function()? onTap;
  final String? initialValue;

  const MapSearchBar({
    super.key,
    required this.onSearchSubmitted,
    // required this.onVoiceSearch,
    required this.onSearchChanged,
    this.onTap,
    this.initialValue,
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
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: initialValue ?? '', // 초기값이 없으면 빈칸 처리
              decoration: const InputDecoration(
                hintText: '검색어를 입력하세요.',
                border: InputBorder.none,
              ),
              onTap: onTap,
              onChanged: onSearchChanged,
              onFieldSubmitted: onSearchSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.black54),
            onPressed: () {
              // 음성 검색 기능 추가 시 여기에 추가
            },
          ),
        ],
      ),
    );
  }
}
