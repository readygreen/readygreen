package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.bookmark.Bookmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BookmarkRepository extends JpaRepository<Bookmark, Integer> {
    @Query("SELECT b FROM Bookmark b WHERE b.member.email = :email " +
            "ORDER BY b.type DESC")
    List<Bookmark> findAllByEmailOrderByType(@Param("email") String email);

    @Query("SELECT COUNT(b) FROM Bookmark b WHERE b.id IN :bookmarkIDs AND b.member.email = :email")
    int countByIdIn(List<Integer> bookmarkIDs, String email);

    boolean existsByPlaceIdAndMemberEmail(String placeId, String email);

    void deleteByPlaceIdAndMemberEmail(String placeId, String email);
}

