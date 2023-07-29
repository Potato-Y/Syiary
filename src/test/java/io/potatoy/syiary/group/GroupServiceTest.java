package io.potatoy.syiary.group;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.fasterxml.jackson.databind.ObjectMapper;

import io.potatoy.syiary.config.jwt.TokenProvider;
import io.potatoy.syiary.enums.State;
import io.potatoy.syiary.group.dto.CreateGroupRequest;
import io.potatoy.syiary.group.entity.Group;
import io.potatoy.syiary.group.entity.GroupMember;
import io.potatoy.syiary.group.entity.GroupMemberRepository;
import io.potatoy.syiary.group.entity.GroupRepository;
import io.potatoy.syiary.user.entity.User;
import io.potatoy.syiary.user.entity.UserRepository;
import io.potatoy.syiary.util.GroupUriMaker;

@SpringBootTest // 테스트용 애플리케이션 컨텍스트
@AutoConfigureMockMvc // MockMvc 생성
@ActiveProfiles("local")
public class GroupServiceTest {

    @Autowired
    protected MockMvc mockMvc;
    @Autowired
    protected ObjectMapper objectMapper; // JSON 직렬화, 역직렬화를 위한 클래스
    @Autowired
    private WebApplicationContext context;
    @Autowired
    BCryptPasswordEncoder bCryptPasswordEncoder;
    @Autowired
    UserRepository userRepository;
    @Autowired
    GroupRepository groupRepository;
    @Autowired
    GroupMemberRepository groupMemberRepository;

    @BeforeEach
    public void mockMvcSetup() {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
        userRepository.deleteAll();
        groupRepository.deleteAll();
        groupMemberRepository.deleteAll();
    }

    @DisplayName("createGroup(): 그룹 만들기 성공")
    @WithMockUser(username = "test@mail.com")
    @Test
    public void successCreateGroup() throws Exception {
        // given 그룹 생성에 필요한 객체들 생성
        final String url = "/api/groups";
        final String email = "test@mail.com";
        final String password = "test";
        final String groupName = "test_group";

        User user = userRepository.save(createTestUser(email, password));
        CreateGroupRequest request = new CreateGroupRequest();
        request.setGroupName(groupName);

        // 객체 JSON으로 직렬화
        final String requestBody = objectMapper.writeValueAsString(request);

        // when 로그인 요청
        ResultActions resultActions = mockMvc.perform(post(url)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(requestBody));

        // then 응답 코드가 201인지 확인, 값들이 전부 잘 들어왔는지 확인.
        resultActions
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.groupName").value(groupName));
    }

    private User createTestUser(String email, String password) {
        return User.builder()
                .email(email)
                .password(bCryptPasswordEncoder.encode(password))
                .build();
    }

    private Group createTestGroup(User hostUser, String groupName) {
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

        return Group.builder()
                .groupUri(groupUri)
                .groupName(groupName)
                .hostUser(hostUser)
                .state(State.ACTIVE)
                .build();
    }

    private GroupMember createGroupMember(User user, Group group) {
        return GroupMember.builder()
                .user(user)
                .group(group)
                .build();
    }
}
