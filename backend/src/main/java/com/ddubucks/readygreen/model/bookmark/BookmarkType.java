package com.ddubucks.readygreen.model.bookmark;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum BookmarkType {
    HOME("집"),
    COMPANY("일반 사용자"),
    ETC("기타");

    private final String title;
}
