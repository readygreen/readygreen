import 'package:flutter/material.dart';
import 'package:readygreen/api/user_api.dart';
import 'package:readygreen/constants/appcolors.dart';
import 'package:readygreen/main.dart';
import 'package:readygreen/widgets/modals/agree_modal.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController(); // 비밀번호 확인 컨트롤러

  final NewUserApi userApi = NewUserApi();
  bool isAgreed = false; // 동의 여부를 저장하는 변수

  Future<void> _signUp(BuildContext context) async {
    String email = emailController.text;
    String nickname = nicknameController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text; // 비밀번호 확인 값
    String socialType = "BASIC";
    String profileImg = '';

    // 동의 체크박스가 선택되지 않았다면 경고 메시지
    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서비스 이용약관에 동의해주세요.')),
      );
      return;
    }

    if (email.isNotEmpty &&
        nickname.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }

      // 비밀번호가 일치할 때 회원가입 요청
      bool success = await userApi.signUp(
          email: email,
          nickname: nickname,
          password: password,
          socialType: socialType,
          profileImg: profileImg);

      if (success) {
        // 회원가입 성공 후 자동 로그인 시도
        String? accessToken = await userApi.login(
          email: email,
          password: password,
          nickname: nickname,
          socialType: socialType,
          profileImg: profileImg,
        );

        if (accessToken != null) {
          // 로그인 성공 시 메인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MainPage()), // 메인 페이지로 이동
          );
        } else {
          // 로그인 실패 시 처리
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입은 완료되었지만 로그인에 실패했습니다.')),
          );
        }
      } else {
        // 회원가입 실패 시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: deviceHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/map.png',
                    height: 180,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '언제그린',
                    style: TextStyle(
                      fontFamily: 'LogoFont',
                      color: AppColors.green,
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 이메일 입력 필드
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: '이메일',
                        labelStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.grey, width: 1), // 비활성화 시 테두리 색상
                          borderRadius: BorderRadius.circular(8), // 테두리 둥글기 설정
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.green, width: 2), // 포커스 시 테두리 색상
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 닉네임 입력 필드
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: TextFormField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        labelStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 비밀번호 입력 필드
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true, // 비밀번호 필드
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        labelStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 비밀번호 확인 입력 필드
                  SizedBox(
                    width: deviceWidth * 0.8,
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        labelStyle: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.green, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  // 동의 체크박스
                  SizedBox(
                    width: deviceWidth * 0.86,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // 가운데 정렬
                      children: <Widget>[
                        Checkbox(
                          hoverColor: AppColors.green,
                          activeColor: AppColors.green,
                          checkColor: AppColors.white,
                          value: isAgreed,
                          onChanged: (bool? value) {
                            setState(() {
                              if (isAgreed) {
                                // 이미 체크되어 있으면 해제
                                isAgreed = false;
                              } else {
                                // 체크가 안 되어 있으면 모달 띄움
                                AgreeModal.showAgreementDialog(context, () {
                                  setState(() {
                                    isAgreed = true; // 동의 체크
                                  });
                                });
                              }
                            });
                          },
                        ),
                        const Text('(필수) 언제그린 서비스 이용약관에 동의합니다.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 회원가입 버튼
                  getSignUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSignUpButton() {
    final deviceWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        _signUp(context); // 회원가입 버튼 클릭 시 API 호출
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 50,
          width: deviceWidth * 0.79,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "회원가입하기",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
