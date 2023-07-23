package io.potatoy.syiary.group.entity;

import io.potatoy.syiary.group.entity.GroupMember;
import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.group.entity.Group;

import java.util.List;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    List<GroupMember> findByGroup(Group group);
}
