package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.bookmark.BookmarkType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalTime;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class BookmarkRequestDTO {
    @NotNull(message = "blinkerIDs cannot null")
    private String name;

    @NotNull(message = "blinkerIDs cannot null")
    private String destinationName;

    @NotNull(message = "latitude cannot null")
    private double latitude;

    @NotNull(message = "longitude cannot null")
    private double longitude;

    @DateTimeFormat(pattern = "HH:mm:ss")
    private LocalTime alertTime;

    @NotNull(message = "Bookmark Type cannot be null")
    private BookmarkType type;
}
