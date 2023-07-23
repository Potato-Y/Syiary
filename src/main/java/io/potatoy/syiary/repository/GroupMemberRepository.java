package io.potatoy.syiary.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.domain.Group;
import io.potatoy.syiary.domain.GroupMember;
import java.util.List;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {
    List<GroupMember> findByGroup(Group group);
}
