package io.potatoy.syiary.service;

import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.potatoy.syiary.domain.Group;
import io.potatoy.syiary.domain.User;
import io.potatoy.syiary.domain.enums.State;
import io.potatoy.syiary.dto.group.CreateGroupRequest;
import io.potatoy.syiary.dto.group.CreateGroupResponse;
import io.potatoy.syiary.repository.GroupRepository;
import io.potatoy.syiary.repository.UserRepository;
import io.potatoy.syiary.util.GroupIDMaker;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class GroupService {

    private final GroupRepository groupRepository;
    private final UserRepository userRepository;

    /**
     * 새로운 그룹 생성
     * 
     * @param dto
     * @return
     */
    public CreateGroupResponse createGroup(CreateGroupRequest dto) {
        // User 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Optional<User> user = userRepository.findByEmail(userDetails.getUsername());

        GroupIDMaker groupIDMaker = new GroupIDMaker();
        String groupID;

        while (true) {
            groupID = groupIDMaker.createName(); // 새로운 그룹 id 생성

            // 생성한 그룹 id가 이미 존재하는지 확인
            Optional<Group> loadGroup = groupRepository.findByGroupId(groupID);
            if (loadGroup.isEmpty()) {
                // 없을 경우 멈추기
                break;
            }

            // 이미 존재할 경우 다시 반복
        }

        // group 정보 저장
        Group group = groupRepository.save(
                Group.builder()
                        .groupId(groupID)
                        .groupName(dto.getGroupName())
                        .hostId(user.get().getId())
                        .state(State.ACTIVE)
                        .build());

        return new CreateGroupResponse(group.getId(), group.getGroupId(), group.getGroupName());
    }

}
