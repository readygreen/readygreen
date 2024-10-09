package com.ddubucks.readygreen.controller;

import com.ddubucks.readygreen.dto.*;
import com.ddubucks.readygreen.model.RouteRecord;
import com.ddubucks.readygreen.model.member.Member;
import com.ddubucks.readygreen.repository.RouteRecordRepository;
import com.ddubucks.readygreen.service.MainService;
import com.ddubucks.readygreen.service.MapService;
import com.ddubucks.readygreen.service.MemberService;
import com.ddubucks.readygreen.service.PointService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Random;

@RestController
@RequiredArgsConstructor
@RequestMapping("/main")
public class MainController {

    private final MainService mainService;
    private final MemberService memberService;
    private final PointService pointService;
    private final RouteRecordRepository routeRecordRepository;
    private final MapService mapService;

    @Autowired
    private RestTemplate template;


    @GetMapping("/weather")
    public ResponseEntity<List<WeatherResponseDTO>> weather(@RequestParam("x")String x, @RequestParam("y") String y) throws Exception {
//        List<WeatherResponse> list = mainService.weather(x,y);
//        if(list.isEmpty())return new ResponseEntity<>("날씨 조회 실패", HttpStatus.NOT_FOUND);
//        return ResponseEntity.ok(list);
        List<WeatherResponseDTO> list = mainService.weathers(x,y);
        if(list.isEmpty())return ResponseEntity.noContent().build();
        return ResponseEntity.ok(list);
    }

    @GetMapping
    public ResponseEntity<MainResponseDTO> mainPage(@AuthenticationPrincipal UserDetails userDetails) throws Exception {

        RouteRecord routeRecord = routeRecordRepository.findTopByMemberEmailOrderByCreateDateDesc(userDetails.getUsername())
                .orElse(null);

        // Check if routeRecord is not null before extracting data
        RouteRecordDTO routeRecordDTO = null;
        if (routeRecord != null) {
            routeRecordDTO = RouteRecordDTO.builder()
                    .id(routeRecord.getId())
                    .startName(routeRecord.getStartName())
                    .startLatitude(routeRecord.getStartCoordinate().getY())  // Y is latitude
                    .startLongitude(routeRecord.getStartCoordinate().getX()) // X is longitude
                    .endName(routeRecord.getEndName())
                    .endLatitude(routeRecord.getEndCoordinate().getY())      // Y is latitude
                    .endLongitude(routeRecord.getEndCoordinate().getX())     // X is longitude
                    .build();
        }
        System.out.print("여기부터");
//        System.out.println(routeRecord);
        BookmarkResponseDTO bookmarkResponseDTO = mapService.getBookmark(userDetails.getUsername());
        MainResponseDTO mainResponseDTO = MainResponseDTO.builder()
                .routeRecordDTO(routeRecordDTO)
                .bookmarkResponseDTO(bookmarkResponseDTO)
                .build();
        return ResponseEntity.ok(mainResponseDTO);
    }

    @GetMapping("/fortune")
    public ResponseEntity<String> chat(@AuthenticationPrincipal UserDetails userDetails){
        Member member = memberService.getMemberInfo(userDetails.getUsername());

        if (member.getBirth() == null) {
            return ResponseEntity.badRequest().body("생일 정보가 없습니다.");
        }
        Random random = new Random();
        int luckyNumber = random.nextInt(100) + 1;
        PointRequestDTO pointRequestDTO = PointRequestDTO.builder().point(luckyNumber).description("운세 운세 확인").build();
        pointService.addPoint(userDetails.getUsername(), pointRequestDTO);
        System.out.println(luckyNumber);

        // 프롬프트 생성
        String prompt = String.format("저의 이름은 %s이고, 생일은 %s입니다. 오늘의 운세를 알려주세요. 운세는 반드시 다음 형식을 따르세요: \n" +
                        "일: 일 관련된 운세 \n" +
                        "사랑: 사랑 관련된 운세 \n" +
                        "건강: 건강 관련된 운세 \n" +
                        "금전: 금전 관련된 운세 \n" +
                        "행운의 숫자: %d\n" +
                        "그리고 마지막에 총운을 알려주세요\n" +
                        "각 측면은 간단하고 긍정적으로 설명해 주세요. 글자 수는 최대 200자로 제한합니다.",
                member.getNickname(), member.getBirth().toString(),luckyNumber);
        String apiURL = "https://api.openai.com/v1/chat/completions";
        String model = "gpt-4-turbo";
        ChatGPTRequestDTO request = new ChatGPTRequestDTO(model, prompt);
        System.out.println(apiURL+" "+request);
        ChatGPTResponseDTO chatGPTResponse =  template.postForObject(apiURL, request, ChatGPTResponseDTO.class);
        return ResponseEntity.ok(chatGPTResponse.getChoices().get(0).getMessage().getContent());
    }
}
