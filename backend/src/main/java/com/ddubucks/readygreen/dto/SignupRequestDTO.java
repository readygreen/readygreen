package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.member.SocialType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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

    @NotBlank(message = "Social ID cannot be empty")
    private String socialId;

    @NotNull(message = "Social Type cannot be null")
    private SocialType socialType;

}
