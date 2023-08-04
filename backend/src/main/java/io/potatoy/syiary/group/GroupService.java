package io.potatoy.syiary.group;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import io.potatoy.syiary.group.entity.GroupMember;
import io.potatoy.syiary.group.entity.GroupMemberRepository;
import io.potatoy.syiary.group.entity.GroupRepository;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import io.potatoy.syiary.group.entity.Group;
import io.potatoy.syiary.user.entity.User;
import io.potatoy.syiary.enums.State;
import io.potatoy.syiary.group.dto.CreateGroupRequest;
import io.potatoy.syiary.group.dto.CreateGroupResponse;
import io.potatoy.syiary.group.dto.DeleteGroupRequest;
import io.potatoy.syiary.group.dto.GroupInfoResponse;
import io.potatoy.syiary.group.dto.SecessionGroupRequest;
import io.potatoy.syiary.group.dto.SignupGroupRequest;
import io.potatoy.syiary.group.exception.GroupException;
import io.potatoy.syiary.group.exception.GroupMemberException;
import io.potatoy.syiary.security.util.SecurityUtil;
import io.potatoy.syiary.user.entity.UserRepository;
import io.potatoy.syiary.user.exception.NotFoundUserException;
import io.potatoy.syiary.util.UriMaker;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class GroupService {

    private final Logger logger = LogManager.getLogger(GroupService.class);
    private final GroupRepository groupRepository;
    private final GroupMemberRepository groupMemberRepository;
    private final UserRepository userRepository;
    private final SecurityUtil securityUtil;

    /**
     * GroupMember 객체를 생성하여 반환한다.
     * 
     * @param user
     * @param group
     * @return
     */
    private GroupMember createGroupMemberEntity(User user, Group group) {
        return GroupMember.builder()
                .user(user)
                .group(group)
                .build();
    }

    /**
     * 새로운 그룹 생성
     * 
     * @param dto
     * @return
     */
    public CreateGroupResponse createGroup(CreateGroupRequest dto) {
        // User 정보 가져오기
        User user = securityUtil.getCurrentUser();

        UriMaker groupUriMaker = new UriMaker(); // 그룹 id를 만들기 위해
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
                        .hostUser(user)
                        .state(State.ACTIVE)
                        .build());
        // group member에 만든 본인 추가
        groupMemberRepository.save(
                createGroupMemberEntity(user, group));

        logger.info("createGroup. userId={}, groupId={}, groupUri={}, groupName={}", user.getId(), group.getId(),
                group.getGroupUri(), group.getGroupName());

        return new CreateGroupResponse(group.getId(), group.getGroupUri(), group.getGroupName());
    }

    /**
     * User가 속해있는 group들의 정보를 반환한다.
     * 
     * @return
     */
    public List<GroupInfoResponse> loadGroups() {
        // User 정보 가져오기
        User user = securityUtil.getCurrentUser();

        // User 정보를 통해 속해있는 group 리스트 가져오기
        List<GroupMember> inMembers = groupMemberRepository.findByUser(user);

        ArrayList<GroupInfoResponse> groups = new ArrayList<>();

        for (GroupMember member : inMembers) {
            Group group = member.getGroup();
            GroupInfoResponse response = new GroupInfoResponse(group.getId(), group.getGroupUri(),
                    group.getGroupName());

            groups.add(response);
        }

        logger.info("loadGroups. userId={}", user.getId());
        return groups;
    }

    /**
     * 그룹 삭제 / group host만 가능하다.
     * 
     * @param groupUri
     * @param dto
     */
    public void deleteGroup(String groupUri, DeleteGroupRequest dto) {
        // User 정보 가져오기
        User user = securityUtil.getCurrentUser();
        Long userId = user.getId();

        Group loadGroup = groupRepository.findById(dto.getId()).get();

        /**
         * 요청한 사람이 group의 host인지 확인하고 처리한다.
         * 1. 유저 id와 host id가 동일한지 확인한다.
         * 2. 요청한 group uri와 db에서 불러온 group의 uri가 동일한지 확인한다.
         * 3. user가 작성한 sign과 group 이름과 동일한지 확인한다.
         */
        if (!userId.equals(loadGroup.getHostUser().getId())) {
            // host id와 요청자의 id가 동일하지 않음
            String message = "The group host and the requester's id are not the same.";
            logger.warn("deleteGroup:GroupException. message={}", message);

            throw new GroupException(message);
        }
        if (!groupUri.equals(loadGroup.getGroupUri())) {
            // 요청한 uri과 디비의 uri이 다름.
            String message = "Requested uri and db uri are different.";
            logger.warn("deleteGroup:GroupException. message={}", message);

            throw new GroupException(message);
        }
        if (!dto.getGroupNameSign().equals(loadGroup.getGroupName())) {
            // 사용자가 입력한 그룹 이름과 실제 그룹 이름이 같지 않음.
            String message = "The group name entered by the user and the actual group name are not the same.";
            logger.warn("deleteGroup:GroupException. message={}", message);

            throw new GroupException(message);
        }

        // 그룹에 해당되는 멤버를 모두 삭제
        List<GroupMember> groupMember = groupMemberRepository.findByGroup(loadGroup);
        groupMemberRepository.deleteAll(groupMember);

        logger.info("deleteGroup. userId={}, groupId={}", userId, loadGroup.getId());
        groupRepository.delete(loadGroup);
    }

    /**
     * Host가 사용자를 group에 추가한다.
     * 
     * @param groupUri
     * @param dto
     */
    public void signupGroup(String groupUri, SignupGroupRequest dto) {
        // 유저 정보를 가져온다.
        User user = securityUtil.getCurrentUser();

        // 그룹 정보를 불러온다.
        Group group = groupRepository.findById(dto.getGroupId()).get();

        // 요청자가 host가 맞는지 확인한다.
        if (!group.getHostUser().getId().equals(user.getId())) {
            // Group의 Host User와 User가 동일하지 않습니다.
            String message = "Group Host User and User are not the same.";
            logger.warn("signupGroup:GroupException. userId={}, groupId={}\nmessage={}", user.getId(), group.getId(),
                    message);

            throw new GroupException(message);
        }

        // 초대하고자 하는 유저가 존재하는지 확인하고, 존재하면 불러온다.
        Optional<User> guestUser = userRepository.findByEmail(dto.getUserEmail());
        if (guestUser.isEmpty()) {
            String message = "User not found.";
            logger.warn("signupGroup:NotFoundUserEmailException. message={}", message);

            throw new NotFoundUserException(message);
        }

        // 이미 추가되어 있는 유저인지 확인한다.
        Optional<GroupMember> member = groupMemberRepository.findByUserAndGroup(guestUser.get(), group);
        if (member.isPresent()) {
            // 유저가 이미 그룹에 있음.
            String message = "User is already in a group.";
            logger.warn("signupGroup:GroupException. groupId={}, userId={}, guestUserId={}", group.getId(),
                    user.getId(), guestUser.get().getId());

            throw new GroupException(message);
        }

        // 유저 추가 및 저장
        groupMemberRepository.save(
                createGroupMemberEntity(guestUser.get(), group));
    }

    /**
     * host가 group에 속해있는 특정 user를 탈퇴시킨다.
     * 
     * @param groupUri
     * @param dto
     */
    public void secessionGroup(String groupUri, SecessionGroupRequest dto) {
        // 유저 정보를 가져온다.
        User user = securityUtil.getCurrentUser();

        // 그룹 정보를 불러온다.
        Group group = groupRepository.findById(dto.getGroupId()).get();

        // 요청자가 host가 맞는지 확인한다.
        if (!group.getHostUser().getId().equals(user.getId())) {
            // Group의 Host User와 User가 동일하지 않습니다.
            String message = "Group Host User and User are not the same.";
            logger.warn("secessionGroup:GroupException. userId={}, groupId={}\nmessage={}", user.getId(), group.getId(),
                    message);

            throw new GroupException(message);
        }

        // 탈퇴하고자 하는 유저가 존재하는지 확인하고, 존재하면 불러온다.
        Optional<User> leaveUser = userRepository.findByEmail(dto.getUserEmail());
        if (leaveUser.isEmpty()) {
            String message = "User not found.";
            logger.warn("secessionGroup:NotFoundUserEmailException. userId={}, leaveUserEmail={}\nmessage={}",
                    user.getId(), dto.getUserEmail(), message);

            throw new NotFoundUserException(message);
        }

        // 멤버 디비에서 불러온다.
        Optional<GroupMember> memberUser = groupMemberRepository.findByUserAndGroup(leaveUser.get(), group);
        if (memberUser.isEmpty()) {
            String message = "There are no users in the member list.";
            logger.warn("secessionGroup:GroupMemberException. userId={}, groupId={}, leaveUserId={}\nmessage={}",
                    user.getId(), group.getId(), leaveUser.get().getId(), message);

            throw new GroupMemberException(message);
        }

        groupMemberRepository.delete(memberUser.get());
    }

}