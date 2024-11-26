<div align="center">

<img width="150px" src="green.png" />

# 🚦 언제그린 🚦
**삼성 청년 SW 아카데미 11기 특화 프로젝트 - 빅데이터 분산 우수상 🏆**

보행자를 위한 실시간 횡단보도 잔여시간 제공 네비게이션 서비스 </br>  
2024.08.19 ~ 2024.10.11

<br/>

</div>


## 📜 Contents
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

<br/>   
 

## ✨ 언제그린의 목적
- 초행길에서 효율적인 경로 제안
- 사용자의 편의성을 위한 신호 변경 알림
- 보행자 신호등 잔여 시간을 제공 

<br/>   

## 📱 서비스 화면
**`모바일`, `웨어러블 기기(갤럭시 워치)` 지원**
</br>  

## 지도 화면 🗺️ </br>  

| <img src="https://github.com/user-attachments/assets/27f88c23-d9ce-4299-af4e-5da3d800650b" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/ab57242c-fb50-4754-a209-fc20b93c8975" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/3d94ddd5-19f1-4cc9-940f-dea8f8f33338" style="width: 300px;"> |
|:--------:|:--------:|:--------:|
|   **지도 메인 화면**  |   **장소 검색 화면**  |   **장소 추천 화면**  | 
|   신호 잔여 시간 제공  |   주변 장소 검색 가능  |  주변 장소를 카테고리 별 제공  |  

---

## 길 찾기🧭 </br>  

|  <img src="https://github.com/user-attachments/assets/7c2ace1f-88cf-4cf7-aab2-57aac93754df" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/482aea7f-2f0c-47a6-8da9-92cc06314b93" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/1a570796-09a3-49db-8c70-776c76462702" style="width: 300px;"> | 
|:--------:|:--------:|:--------:|
|   **장소 클릭 화면**  |   **경고창**  |   **길 찾기 진행 중 화면**  |  
|   장소에 대한 자세한 정보 제공  |  실제 상황과 다를 수 있음을 알림으로서 사용자의 안전을 지킬 수 있음  |   경로 설명을 통해 간편한 길 찾기 제공  | 
 
---  

## 메인화면📲 </br>  

|  <img src="https://github.com/user-attachments/assets/a65581f6-8664-4e9d-a774-50d2a1647881" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/b1d62a36-06b9-4a70-a46c-403ba0869442" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/f308e00e-e9d0-4fbd-bd39-48f6ffbca36c" style="width: 300px;"> | <img src="https://github.com/user-attachments/assets/5ddf3767-e3f7-4b62-a6ca-f82fa2153aaf" style="width: 300px;"> | 
|:--------:|:--------:|:--------:|:--------:|
|   **메인 화면**  |   **현재 날씨**  |  **오늘의 운세**  |   **로그인 화면**  |
|   한 눈에 모든 기능을 제공  |   보행자에게 날씨를 제공함으로서 편리함 강화  |   사용자의 생년월일을 통해 운세 제공 |   카카오 소셜 로그인을 제공  |  
</br>

### 지도 페이지
- 주변 보행자 신호등 정보 표시
- 장소 검색 제공
- 웨어러블 기기 연동
<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/130f6497-90e6-4ef5-802f-b00179871371" width="10%">
</div>


### 길안내
- `tts`를 이용한 도착지 검색 기능
- 목적지 길안내 제공
- 웨어러블 기기 연동
<div margin: 10px>
 
    <img src="https://github.com/user-attachments/assets/15e9406c-8ada-4b90-81e2-a159fe434d5a" width="10%">
        <img src="https://github.com/user-attachments/assets/4c830ac4-2482-49cc-aef4-728101c662c2" width="10%">
            <img src="https://github.com/user-attachments/assets/6158e134-5864-499f-97b1-58126e1286be" width="10%">
                
</div>

### 주변 장소 추천
- 주변 장소 데이터 `분산 처리`

<div>
  <img src="https://github.com/user-attachments/assets/3d94ddd5-19f1-4cc9-940f-dea8f8f33338" width="20%">
</div>

### 메인화면
- 오늘의 날씨, 운제를 제공
- 자주가는 목적지와 최근 목적지 바로 길찾기 제공

<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/a65581f6-8664-4e9d-a774-50d2a1647881" width="20%">
  <img src="https://github.com/user-attachments/assets/b1d62a36-06b9-4a70-a46c-403ba0869442" width="20%">
  <img src="https://github.com/user-attachments/assets/f308e00e-e9d0-4fbd-bd39-48f6ffbca36c" width="20%">
  <img src="https://github.com/user-attachments/assets/51f4eb3e-1685-4dfa-86f4-943fa9e71661" width="10%">
</div>

### 로그인
- `카카오 소셜` 로그인
<div margin: 10px>
<img src="https://github.com/user-attachments/assets/5ddf3767-e3f7-4b62-a6ca-f82fa2153aaf" width="20%">
</div>
  
### 마이페이지
- `대표 뱃지 설정`
- `생일 등록 및 변경`
- `자주가는 목적지` 등록 및 수정
<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/c9194c23-d7b2-4528-afd7-0f1120eed7ec" width="20%">
  <img src="https://github.com/user-attachments/assets/c9c01386-dad6-4add-b786-c78fa7fbbdde" width="20%">
  <img src="https://github.com/user-attachments/assets/7b4126aa-f154-49bf-82ae-edad71311f31" width="20%">
</div>



### 포인트 페이지
- `걸음 수`, `총 걸음수` 측정 제공
- `총 포인트`, `포인트 상세 내역` 조회
- `걸음 수`, `운세`, `제보`에 대한 포인트 부여
<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/79e1d1da-3b98-4094-9771-665e297f8422" width="20%">
  <img src="https://github.com/user-attachments/assets/4379dd0f-a9f4-41bd-b333-864928248483" width="20%">
</div>


### 고객지원
- `관리자`의 공지사항
- 사용자의 `건의사항들`을 조회
- `잘못된 데이터`를 제보하는 건의 등록
<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/f154afc2-883e-4e36-aae2-5cc6033081db" width="20%">
  <img src="https://github.com/user-attachments/assets/91d419a6-13fe-4f42-8fd9-b345d75a3c1d" width="20%">
  <img src="https://github.com/user-attachments/assets/9f4cc153-da88-4861-aa21-375c00f85518" width="20%">
</div>

  
### 워치 연동
- `웨어러블` 연결
- 이메일과 모바일에서 제공하는 `인증번호` 입력시 연동
<div margin: 10px>
  <img src="https://github.com/user-attachments/assets/40794819-58d4-42e2-a3dd-6ac40aac3a52" width="20%"/>
  <img src="https://github.com/user-attachments/assets/dc3edb0f-9d09-4dc2-91de-90cb26fc530e" width="10%"/>
  <img src="https://github.com/user-attachments/assets/1a610dd0-2afb-445c-9ac2-916fe20828ee" width="10%"/>
</div>

<br/>   

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
   
<br/>   


## 🖥️ 개발 환경

### 🐳 Backend
<div> 
	<img src="https://img.shields.io/badge/Java-007396?style=for-the-badge&logo=Java&logoColor=white">
	<img src="https://img.shields.io/badge/Ubuntu-20.1.0-E95420?style=for-the-badge&logo=Ubuntu&logoColor=white">
	<img src="https://img.shields.io/badge/SpringBoot-6DB33F?style=for-the-badge&logo=Spring-Boot&logoColor=white">
	<img src="https://img.shields.io/badge/Gradle-02303A?style=for-the-badge&logo=Gradle&logoColor=white">
	<img src="https://img.shields.io/badge/Swagger-85EA2D?style=for-the-badge&logo=Swagger&logoColor=black">
	<img src="https://img.shields.io/badge/Spring%20Security-6DB33F?style=for-the-badge&logo=Spring-Security&logoColor=white">
	<img src="https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=Apache-Spark&logoColor=white">
</div>
<br/>

### 🦊 Frontend
<div>
	<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=Dart&logoColor=white">
	<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white">
	<img src="https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=Provider&logoColor=white">
	<img src="https://img.shields.io/badge/Google%20Maps-4285F4?style=for-the-badge&logo=Google-Maps&logoColor=white">
	<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=black">
</div>
<br/>

 
### 🦊 WearOS
<div>
	<img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=Kotlin&logoColor=white">
	<img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=Android&logoColor=white">
	<img src="https://img.shields.io/badge/Retrofit-FF6F00?style=for-the-badge&logo=Retrofit&logoColor=white">
	<img src="https://img.shields.io/badge/Google%20Maps-4285F4?style=for-the-badge&logo=Google-Maps&logoColor=white">
	<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=black">	
	<img src="https://img.shields.io/badge/Lottie-8DD6F9?style=for-the-badge&logo=Lottie&logoColor=white">
</div>
<br/>

### 🗂️ DB
<div>
	<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=MySQL&logoColor=white">
	<img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=MongoDB&logoColor=white">
	<img src="https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=Redis&logoColor=white">	
</div>
<br/>


### 🌐 Server
<div>
	<img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=Ubuntu&logoColor=white">
	<img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=Nginx&logoColor=white">
	<img src="https://img.shields.io/badge/PuTTY-023161?style=for-the-badge&logo=PuTTY&logoColor=white">
	<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=Docker&logoColor=white">
	<img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white">
</div>
<br/>


### 🔨 IDE
<div>
	<img src="https://img.shields.io/badge/IntelliJ%20IDEA-000000?style=for-the-badge&logo=IntelliJ-IDEA&logoColor=white">
	<img src="https://img.shields.io/badge/MySQL%20Workbench-4479A1?style=for-the-badge&logo=MySQL&logoColor=white">
	<img src="https://img.shields.io/badge/VSCode-007ACC?style=for-the-badge&logo=Visual-Studio-Code&logoColor=white">
	<img src="https://img.shields.io/badge/Android%20Studio-3DDC84?style=for-the-badge&logo=Android-Studio&logoColor=white">	
</div>
<br/>


## 💫 시스템 아키텍처

<img src="https://github.com/user-attachments/assets/0132b0bc-10ed-4246-aa8e-cdba38da28d0" alt="시스템 아키텍처" width="80%">


<br/>     

## ✨ 기술 특이점
- 신호등 대기 시간을 적용한 최적 경로 제공
- 서브 서버에서 주변 장소 추천을 위한 `스파크`를 활용해 장소 데이터 수집
- 사용자 편의성을 위한 웨어러블 연동
- 음성인식으로 목적지 검색 제공
- 사용자 제보로 데이터 개선
- 오늘의 날씨, 운세, 걸음 수 등 데일리 컨텐츠 제공
- 포인트와 뱃지 기능으로 유저 유입 증가 목적

<br/>   

## ✨ 추후 고도화 
- 유저의 속도를 분석후 속도에 맞는 맞춤형 경로 안내 제공
- 신호등 대기 시간을 적용한 더 많은 경로 제공
- 실시간 신호등 데이터를 분산처리
- 제보 데이터 자동 분석
- 삼성웰렛과 연동

<br/>   

# 📂 기획 및 설계 산출물

### [💭 기능 명세](https://obsidian-boar-5f3.notion.site/0de7338d07c045e584d3879cbac76a44?pvs=74)

<img width="100%" alt="기능 명세" src="https://github.com/user-attachments/assets/4913b826-8ebe-49e1-81ae-76b7463548a2"><br>

### [🎨 화면 설계서](https://www.figma.com/design/P73jaKuUZsdERNRuDRBdtm/%EC%96%B8%EC%A0%9C%EA%B7%B8%EB%A6%B0?node-id=301-1535&node-type=canvas&t=tXJLJwuCp1h2XQ3D-0)


<img width="100%" alt="화면설계서" src="https://github.com/user-attachments/assets/1c31c32a-8187-42c8-8f9e-624bf4da41b3"><br>

### [✨ ER Diagram](https://www.erdcloud.com/d/57wJHqjZPLPw7w2ve)

<img width="100%" alt="erd" src="https://github.com/user-attachments/assets/9de9eeba-8fba-4930-a9a1-8b2b3bfc3844" ><br>

<br/>   

# ✨ Conventions 
언제그린 팀원들의 원활한 `Gitlab`, `Jira` 사용을 위한 [✨컨벤션✨](https://obsidian-boar-5f3.notion.site/bfbb93c1ebbb412fa1b9bb03042f4ebc?pvs=74) 입니다 :)

<br/>   

## 👥 팀원 소개

<div>
<table>
    <tr>
        <td align="center">
        <a href="https://github.com/sommnee">
          <img src="https://avatars.githubusercontent.com/sommnee" width="120px;" alt="wooqqq">
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/yongwonkim1">
          <img src="https://avatars.githubusercontent.com/yongwonkim1" width="120px;" alt="Basaeng">
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/ensk26">
          <img src="https://avatars.githubusercontent.com/ensk26" width="120px;" alt="jiwon718">
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/seungminleeee">
          <img src="https://avatars.githubusercontent.com/seungminleeee" width="120px;" alt="KBG1">
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/JinAyeong">
          <img src="https://avatars.githubusercontent.com/JinAyeong" width="120px;" alt="taessong">
        </a>
      </td>
      <td align="center">
        <a href="https://github.com/chajoyhoi">
          <img src="https://avatars.githubusercontent.com/chajoyhoi" width="120px;" alt="hhsssu">
        </a>
      </td>
  </tr>
  <tr>
    <td align="center">
      <a href="https://github.com/sommnee">
        이소민
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/yongwonkim1">
        김용원
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/wnsk26">
        서두나
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/seungminleeee">
        이승민
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/JinAyeong">
        진아영
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/chajoyhoi">
        차유림
      </a>
    </td>
  </tr>
  <tr>
    <td align="center">
        팀장, BE, Data
    </td>
    <td align="center">
      Infra, BE, FE
    </td>
    <td align="center">
      BE
    </td>
    <td align="center">
      FE
    </td>
    <td align="center">
      FE
    </td>
    <td align="center">
      FE
    </td>
  </tr>
</table>
</div>
