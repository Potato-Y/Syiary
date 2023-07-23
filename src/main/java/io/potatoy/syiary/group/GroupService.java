package io.potatoy.syiary.group;

import java.util.List;
import java.util.Optional;

import io.potatoy.syiary.group.entity.GroupMember;
import io.potatoy.syiary.group.entity.GroupMemberRepository;
import io.potatoy.syiary.group.entity.GroupRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.potatoy.syiary.group.entity.Group;
import io.potatoy.syiary.user.entity.User;
import io.potatoy.syiary.enums.State;
import io.potatoy.syiary.group.dto.CreateGroupRequest;
import io.potatoy.syiary.group.dto.CreateGroupResponse;
import io.potatoy.syiary.group.dto.DeleteGroupRequest;
import io.potatoy.syiary.group.exception.GroupException;
import io.potatoy.syiary.user.entity.UserRepository;
import io.potatoy.syiary.util.GroupUriMaker;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class GroupService {

    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
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
        Long userId = user.get().getId();
        System.out.println("*************************");

        System.out.println(userDetails.getUsername());

        GroupUriMaker groupUriMaker = new GroupUriMaker(); // 그룹 id를 만들기 위해
        String groupUri;

        while (true) {
            groupUri = groupUriMaker.createName(); // 새로운 그룹 id 생성

            // 생성한 그룹 id가 이미 존재하는지 확인
            Optional<Group> loadGroup = groupRepository.findByGroupUri(groupUri);
            if (loadGroup.isEmpty()) {
                // 없을 경우 멈추기
                break;
            }

            // 이미 존재할 경우 다시 반복
        }

        // group 정보 저장
        Group group = groupRepository.save(
                Group.builder()
                        .groupUri(groupUri)
                        .groupName(dto.getGroupName())
                        .hostId(userId)
                        .state(State.ACTIVE)
                        .build());
        // group member에 만든 본인 추가
        groupMemberRepository.save(
                GroupMember.builder()
                        .userId(userId)
                        .group(group)
                        .build());

        return new CreateGroupResponse(group.getId(), group.getGroupUri(), group.getGroupName());
    }

    /**
     * 그룹 삭제 / group host만 가능하다.
     * 
     * @param groupUri
     * @param dto
     */
    public void deleteGroup(String groupUri, DeleteGroupRequest dto) {
        // User 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Optional<User> user = userRepository.findByEmail(userDetails.getUsername());
        Long userId = user.get().getId();

        Group loadGroup = groupRepository.findById(dto.getId()).get();

        /**
         * 요청한 사람이 group의 host인지 확인하고 처리한다.
         * 1. 유저 id와 host id가 동일한지 확인한다.
         * 2. 요청한 group uri와 db에서 불러온 group의 uri가 동일한지 확인한다.
         * 3. user가 작성한 sign과 group 이름과 동일한지 확인한다.
         */
        if (!userId.equals(loadGroup.getHostId())) {
            // host id와 요청자의 id가 동일하지 않음
            throw new GroupException("The group host and the requester's id are not the same.");
        }
        if (!groupUri.equals(loadGroup.getGroupUri())) {
            // 요청한 uri과 디비의 uri이 다름.
            throw new GroupException("Requested uri and db uri are different.");
        }
        if (!dto.getGroupNameSign().equals(loadGroup.getGroupName())) {
            // 사용자가 입력한 그룹 이름과 실제 그룹 이름이 같지 않음.
            throw new GroupException("The group name entered by the user and the actual group name are not the same.");
        }

        // 그룹에 해당되는 멤버를 모두 삭제
        List<GroupMember> groupMember = groupMemberRepository.findByGroup(loadGroup);
        groupMemberRepository.deleteAll(groupMember);

        groupRepository.delete(loadGroup);
    }

}
