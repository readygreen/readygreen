package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.bookmark.Bookmark;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Getter
public class AlarmDTO {
    private String smartphones;
    private Bookmark bookmark;
}
