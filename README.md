# 🚦 언제그린

### 📜 Contents
 1. [Overview](#-overview)
 2. [서비스 화면](#-서비스-화면)
 3. [주요 기능](#-주요-기능)
 4. [개발 환경](#%EF%B8%8F-개발-환경)
 5. [시스템 아키텍처](#-시스템-아키텍처)
 6. [기술 특이점](#-기술-특이점)
 7. [추후 고도화](#-추후-고도화)
 8. [기획 및 설계 산출물](#-기획-및-설계-산출물)
 9. [Conventions](#-conventions)
 10. [팀원 소개](#-팀원-소개)
 
## ✨ Overview

> 신호등 시간을 고려한 최적의 경로를 추천해주는 웹 서비스

## ✨ 언제그린의 목적
- 신호 대기 시간을 고려한 효율적인 경로로 시간 절약
- 초행길에서 효율적인 경로 제안
- 사용자의 편의성을 위한 신호 변경 알림 


## 👀 서비스 화면
### ✨ `모바일`, `웨어러블 기기(갤럭시 워치)` 지원

### 지도 페이지
- 주변 보행자 신호등 정보 표시
- 갤럭시 워치의 지도페이지도 함께 표시
<div>
  <img src="point.gif" width="75%">
  <img src="point.gif" width="20%">
</div>


### 길안내
- 북마크 길안내
- 갤럭시 워치의 길안내도 함께 표시
<div>
  <img src="point.gif" width="75%">
  <img src="point.gif" width="20%">
</div>

### 주변 장소 추천
- 장소 데이터 분산 데이터 처리

<div>
  <img src="point.gif" width="75%">
  <img src="point.gif" width="20%">
</div>

### 메인화면
- 오늘의 날씨, 운제를 제공
- 걸음수와 자주가는 목적지 바로가기

<div width="100%">
<img src="point.gif" width="75%">
<img src="point.gif" width="20%">
</div>

### 회원가입 & 로그인 & 로그아웃
- `카카오 소셜 로그인/회원가입
<div>
<img src="point.gif" width="75%">
<img src="point.gif" width="20%">
</div>
  
### 마이페이지
- `대표 뱃지 설정`
- `생일 등록 및 변경`
- `자주가는 목적지` 등록 및 수정
<div>
  <img src="https://github.com/user-attachments/assets/f4dbfdb0-cf8e-4bcd-90c6-76e98586ddbb" width="20%">
  <img src="https://github.com/user-attachments/assets/7b6df2ec-8c50-45d9-aa49-2a2f0d88f4d1" width="20%">
  <img src="https://github.com/user-attachments/assets/044ba92f-435e-4f73-ade2-cae75e3f389a" width="20%">
  <img src="https://github.com/user-attachments/assets/68e27f34-f53b-4afc-a302-836ed05cfac4" width="20%">
</div>



### 포인트 페이지
- `걸음 수`, `총 걸음수` 측정 제공
- `총 포인트`, `포인트 상세 내역` 조회
- `걸음 수`, `운세`, `제보`에 대한 포인트 부여
<div>
  <img src="https://github.com/user-attachments/assets/877df1d9-5995-45ff-b180-c69eeae0e199" width="20%">
  <img src="https://github.com/user-attachments/assets/89f3e8bd-b58d-4046-a1e4-d2c72a20aa4d" width="20%">
</div>


### 공지사항
- 공지사항
- 내건의함
- 건의하기
<div>
  <img src="https://github.com/user-attachments/assets/ec5f9e45-c0d0-48a5-8eb7-9b41c54182ce" width="20%">
  <img src="https://github.com/user-attachments/assets/e48f43da-0bbc-4739-a145-5897a522840d" width="20%">
  <img src="https://github.com/user-attachments/assets/1807bb38-1ffa-466f-8305-168303e47179" width="20%">
</div>

  
### 갤럭시 워치
- 웨어러블 연결
- 음성 검색
- 메인 페이지
- 자주가는 목적지
<div>
<img src="https://github.com/user-attachments/assets/ec34945d-ff8b-4cb1-885e-306f3a9e5429" width="20%"/>
  <img src="https://github.com/user-attachments/assets/ec34945d-ff8b-4cb1-885e-306f3a9e5429" width="20%"/>
  <img src="https://github.com/user-attachments/assets/ec34945d-ff8b-4cb1-885e-306f3a9e5429" width="20%"/>
  <img src="https://github.com/user-attachments/assets/ec34945d-ff8b-4cb1-885e-306f3a9e5429" width="20%"/>
</div>

## ✨ 주요 기능

- `경로 안내`
    - 신호등 시간 분석을 통해 최적의 경로 제공
    - 백그라운드 상태에서도 경로 내 신호 변경 알림

- `신호등 정보 제공`
	- 현재 위치에서 지도 줌 레벨에 따른 신호등 정보 제공


- `주변 장소 추천`
    - 데이터 분산 처리를 이용한 주변 장소 데이터 30개를 제공

- `웨어러블 기기 연동`
    - 모바일에서 경로 안내와 지도 보기 등 기능 연동
    - 사용자 편의성을 위한 목적지 음성 검색
    - tts를 이용한 길안내
    - 신호 알림을 위한 진동 알림

- `오늘의 날씨와 운세 제공`
	- 유저의 흥미도 상승

- `걸음수 총 걸음수 제공`
	- 하버사인을 활용한 경로 거리 계산 및 걸음수 계산

- `신호등 데이터 개선을 위한 제보`
	- 사용자의 제보로 지속적인 데이터 개선
   

## 🖥️ 개발 환경

**🐳 Backend**
- Java `17`
- Ubutu `20.1.0`
- SpringBoot `3.3.3`
- Gradle `7.5`
- Swagger
- Spring Security
- spark `3.4.0`

**🦊 Frontend**
- lang: dart `16.16.0`
- framework: flutter `3.24.3`
- 상태관리 : provider `6.1.2`

```
sdk: flutter
  cupertino_icons: ^1.0.8
  permission_handler: ^8.3.0
  google_maps_flutter: ^2.9.0
  flutter_google_places: ^0.3.0
  google_maps_webservice: ^0.0.19
  location: ^6.0.2
  geolocator: ^13.0.1
  geocoding: ^3.0.0
  provider: ^6.1.2
  http: ^0.13.6
  speech_to_text: ^7.0.0
  flutter_secure_storage: ^9.2.2
  kakao_flutter_sdk_user: ^1.9.6
  intl: ^0.17.0
  firebase_messaging: ^15.1.2
  googleapis_auth: ^1.4.1
  flutter_local_notifications: ^17.2.3
  lottie: ^2.2.0
  confetti: ^0.8.0
```
 
**🦊WearOS**
- Kotlin `1.8`
- Retrofit `2.9.0`
- Google Maps `4.4.1`
- Lottie ` 6.0.0`
- Firebase Messaging
 

**🗂️ DB**
- MySQL `8.0.30`
- MongoDB
- Redis

**🌐 Server**
- Ubuntu `20.0.4`
- Nginx `1.23`
- PuTTY `0.77`
- Docker `20.10.18`
- Jenkins `Jenkins/jenkins:lts-jdk11`

**🔨 IDE**
- IntelliJ `2024.2.1`
- MySQL Workbench `8.0.29`
- VSCode `1.69.2`
- Android Studio `2024.1.2`

## 💫 시스템 아키텍처

<img src="https://github.com/user-attachments/assets/0132b0bc-10ed-4246-aa8e-cdba38da28d0" alt="시스템 아키텍처" width="80%">



## ✨ 기술 특이점
- 신호등 대기 시간을 적용한 최적 경로 제공
- 서브 서버에서 주변 장소 추천을 위한 `스파크`를 활용해 장소 데이터 수집
- 사용자 편의성을 위한 웨어러블 연동
- 음성인식으로 목적지 검색 제공
- 사용자 제보로 데이터 개선
- 오늘의 날씨, 운세, 걸음 수 등 데일리 컨텐츠 제공
- 포인트와 뱃지 기능으로 유저 유입 증가 목적

## ✨ 추후 고도화 
- 유저의 속도를 분석후 속도에 맞는 맞춤형 경로 안내 제공
- 신호등 대기 시간을 적용한 더 많은 경로 제공
- 실시간 신호등 데이터를 분산처리
- 제보 데이터 자동 분석
- 삼성웰렛과 연동

# 📂 기획 및 설계 산출물

### [💭 기능 명세](https://obsidian-boar-5f3.notion.site/0de7338d07c045e584d3879cbac76a44?pvs=74)

<img width="100%" alt="기능 명세" src="https://github.com/user-attachments/assets/4913b826-8ebe-49e1-81ae-76b7463548a2"><br>

### [🎨 화면 설계서](https://www.figma.com/design/P73jaKuUZsdERNRuDRBdtm/%EC%96%B8%EC%A0%9C%EA%B7%B8%EB%A6%B0?node-id=0-1&t=cTjzOCfPTE8c1GE1-1)

<img width="100%" alt="화면설계서" src="https://github.com/user-attachments/assets/89a31ee3-366b-4915-a4e2-7f97bb1ce747"><br>

### [✨ ER Diagram](https://www.erdcloud.com/d/57wJHqjZPLPw7w2ve)

<img width="100%" alt="erd" src="https://github.com/user-attachments/assets/9de9eeba-8fba-4930-a9a1-8b2b3bfc3844" ><br>

# ✨ Conventions 
언제그린 팀원들의 원활한 `Gitlab`, `Jira` 사용을 위한 [✨컨벤션✨](https://obsidian-boar-5f3.notion.site/bfbb93c1ebbb412fa1b9bb03042f4ebc?pvs=74) 입니다 :)
