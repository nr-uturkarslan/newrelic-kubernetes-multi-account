package com.kubernetes.multi.charlie.persistence.repositories;

import com.kubernetes.multi.charlie.persistence.entities.Value;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ValueRepository extends JpaRepository<Value, UUID> {

    public Value findByValue(String value);
}
