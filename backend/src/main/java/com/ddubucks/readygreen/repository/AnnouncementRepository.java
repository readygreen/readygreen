//package com.ddubucks.readygreen.repository;
//
//import com.ddubucks.readygreen.model.Announcement;
//import org.springframework.data.jpa.repository.JpaRepository;
//import org.springframework.data.jpa.repository.Query;
//
//import java.util.List;
//
//public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {
//
//    @Query("SELECT a FROM Announcement a ORDER BY a.isImportant DESC, a.createdAt DESC")
//    List<Announcement> findAllOrderedByImportanceAndDate();
//}
