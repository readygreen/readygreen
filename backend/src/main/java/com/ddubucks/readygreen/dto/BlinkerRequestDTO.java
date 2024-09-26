package com.ddubucks.readygreen.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class BlinkerRequestDTO {

    @NotNull(message = "blinkerIDs cannot null")
    List<Integer> blinkerIDs;
}
