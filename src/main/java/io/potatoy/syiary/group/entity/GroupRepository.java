package io.potatoy.syiary.group.entity;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.group.entity.Group;

public interface GroupRepository extends JpaRepository<Group, Long> {
    Optional<Group> findByGroupUri(String groupUri);
}
