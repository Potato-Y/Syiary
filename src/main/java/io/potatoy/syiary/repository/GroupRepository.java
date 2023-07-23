package io.potatoy.syiary.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.domain.Group;

public interface GroupRepository extends JpaRepository<Group, Long> {
    Optional<Group> findByGroupUri(String groupUri);
}
