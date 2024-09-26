package com.ddubucks.readygreen.repository;

import com.ddubucks.readygreen.model.Blinker;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface BlinkerRepository extends JpaRepository<Blinker, Integer> {
    Optional<Blinker> findById(Integer id);
}

