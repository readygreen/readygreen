package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.bookmark.BookmarkType;
import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class BookmarkEditDTO {
        private int id; // 수정할 북마크의 ID
        private BookmarkType type; // 변경할 북마크 타입 (HOME, COMPANY, ETC)
}
