package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Bookmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface BookmarkRepository extends JpaRepository<Bookmark, Integer> {
    @Query("SELECT b FROM Bookmark b WHERE b.member.email = :email")
    List<Bookmark> findAllByEmail(String email);

    @Query("SELECT COUNT(b) FROM Bookmark b WHERE b.id IN :bookmarkIDs AND b.member.email = :email")
    int countByIdIn(List<Integer> bookmarkIDs, String email);
}

