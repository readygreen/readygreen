package com.ddubucks.readygreen.model.bookmark;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum BookmarkType {
    HOME("집"),
    COMPANY("회사"),
    ETC("기타");

    private final String title;
}
