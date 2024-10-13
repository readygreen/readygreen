import 'package:flutter/material.dart';
import 'package:readygreen/constants/appcolors.dart';

class AgreeModal {
  static void showAgreementDialog(BuildContext context, Function onAgree) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 15),
                    // 모달 상단 타이틀
                    const Text(
                      '개인정보 수집 및 이용 동의',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // 스크롤 가능한 동의서 내용
                    const SizedBox(
                      height: 310, // 최대 높이 설정 (스크롤 가능)
                      child: SingleChildScrollView(
                        child: Text(
                          '''언제그린은 이용자의 개인정보를 중요시하며, 「개인정보 보호법」에 따라 이용자의 개인정보를 보호하고 이와 관련한 고충을 원활하게 처리할 수 있도록 아래와 같이 개인정보 수집 및 이용에 대한 동의를 구합니다.

1. 개인정보 수집 및 이용 목적
언제그린은 이용자의 개인정보를 다음의 목적으로 수집 및 이용합니다.

- 길 안내 서비스 제공 및 맞춤형 추천 장소 정보 제공
- 서비스 이용 기록 및 통계 분석을 통한 서비스 개선
- 회원 관리 및 인증 절차 수행
- 서비스 관련 공지 및 고객 문의 응대

2. 수집하는 개인정보 항목
언제그린은 서비스 제공을 위해 아래와 같은 개인정보를 수집합니다.

수집 항목: 이름, 이메일 주소, 생년월일, 위치 정보 (GPS), 알림 수신 동의 여부

3. 개인정보의 보유 및 이용 기간
언제그린 이용자의 개인정보를 수집 및 이용 목적이 달성될 때까지 보유하며, 회원 탈퇴 시 또는 수집된 개인정보의 이용 목적이 달성되었을 때 해당 정보를 지체 없이 파기합니다. 

4. 개인정보의 제공 및 공유
언제그린은 이용자의 동의 없이 개인정보를 제3자에게 제공하지 않으며, 법령에 의해 요구되는 경우에 한해 제공될 수 있습니다.

5. 동의 거부 권리
이용자는 개인정보 수집 및 이용에 대한 동의를 거부할 권리가 있습니다. 다만, 개인정보 활용 동의를 거부할 경우 언제그린의 서비스 이용이 제한될 수 있습니다.
                          ''',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 동의하기 버튼
                    ElevatedButton(
                      onPressed: () {
                        onAgree();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '동의하기',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // 닫기 아이콘 버튼 (오른쪽 상단에 위치)
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 30,
                    color: AppColors.greytext,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // 모달 닫기
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
