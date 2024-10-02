package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.member.SocialType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class SignupRequestDTO {

    @NotBlank(message = "Email cannot be empty")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Nickname cannot be empty")
    private String nickname;

    private String profileImg;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birth;

    @NotBlank(message = "Social ID cannot be empty")
    private String socialId;

    @NotNull(message = "Social Type cannot be null")
    private SocialType socialType;

    @NotNull(message = "devicesToken cannot be null")
    private String smartphone;

}
