package io.potatoy.syiary.dto.auth;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TokenRequest {
    private String accessToken;
    private String refreshToken;
}
