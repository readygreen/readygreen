package com.ddubucks.readygreen.dto;

import com.ddubucks.readygreen.model.Bookmark;
import lombok.*;

import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class BookmarkResponseDTO {
    List<Bookmark> bookmarks;
}
