package io.potatoy.syiary.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import io.potatoy.syiary.domain.GroupMember;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {

}
