package io.potatoy.syiary.dto.user;

import io.potatoy.syiary.domain.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor // 기본 생성자 추가
@AllArgsConstructor // 모든 필드 값을 파라미터로 받는 생성자 추가
@Getter
@Setter
public class AddUserRequest {
    private String email;
    private String password;

    public User toEntity() { // 생성자를 사용해 객체 생성
        return User.builder()
                .email(email)
                .password(password)
                .build();
    }

}
