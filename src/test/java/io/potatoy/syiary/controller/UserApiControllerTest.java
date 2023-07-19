package io.potatoy.syiary.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.potatoy.syiary.dto.user.AddUserRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest // 테스트용 애플리케이션 컨텍스트
@AutoConfigureMockMvc // MockMvc 생성
class UserApiControllerTest {

    @Autowired
    protected MockMvc mockMvc;
    @Autowired
    protected ObjectMapper objectMapper; // JSON 직렬화, 역직렬화를 위한 클래스

    @DisplayName("addUser: 새로운 유저 추가")
    @Test
    public void addUser() throws Exception {
        // given 새로운 유저 추가에 필요한 객체를 생성
        final String url = "/api/signup";
        final String email = "test@mail.com";
        final String password = "test";
        final AddUserRequest addUserRequest = new AddUserRequest(email, password);

        // 객체 JSON으로 직렬화
        final String requestBody = objectMapper.writeValueAsString(addUserRequest);

        // when 회원가입 요청을 보낸다.
        ResultActions result = mockMvc.perform(post(url)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(requestBody));

        // then 응답코드가 201인지 확인
        result
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email").value(email));

    }

}