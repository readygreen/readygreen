package com.ddubucks.readygreen.dto;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FcmRequestDTO {

    @NotNull(message = "watch cannot null")
    private boolean isWatch;
    @NotNull(message = "messageType cannot null")
    private int messageType;
    // 1 : 길 안내 시 다른 디바이스에 알림
    // 2 : 스케줄러로 북마크 보내기

    private String message;

    private String distEmail;

}
