import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class BgcontainerMypage extends StatelessWidget {
  final Widget? child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const BgcontainerMypage({
    super.key,
    this.child,
    this.backgroundColor = AppColors.greybg, // 배경색
    this.padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // 기본 패딩 설정
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor, // 배경색 설정
        borderRadius: BorderRadius.circular(12), // 둥근 모서리
      ),
      // SingleChildScrollView로 스크롤 가능하게 설정
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
