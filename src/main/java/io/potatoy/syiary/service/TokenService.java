package io.potatoy.syiary.service;

import java.time.Duration;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.potatoy.syiary.config.jwt.TokenProvider;
import io.potatoy.syiary.domain.RefreshToken;
import io.potatoy.syiary.domain.User;
import io.potatoy.syiary.dto.auth.AuthenticateRequest;
import io.potatoy.syiary.dto.auth.AuthenticateResponse;
import io.potatoy.syiary.dto.auth.TokenRequest;
import io.potatoy.syiary.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class TokenService {

    public static final Duration REFRESH_TOKEN_DURATION = Duration.ofDays(14);
    public static final Duration ACCESS_TOKEN_DURATION = Duration.ofDays(1);

    private final TokenProvider tokenProvider;
    private final RefreshTokenService refreshTokenService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final UserService userService;

    /**
     * 새로운 Access Token을 생성
     * 
     * @param refreshToken
     * @return
     */
    public String createNewAccessToken(TokenRequest dto) {
        // 토큰 유효성 검사에 실패하면 예외 발생
        if (!tokenProvider.validToken(dto.getRefreshToken().toString())) {
            throw new IllegalArgumentException("Unexpected token");
        }

        ////
        // access token이 비어있지 않은지 검증
        // access token이 본 서버에서 발급한 것이 맞는 지 검증
        // access token만 왔는지 검증
        // 을 통해 공격 차단 로직 위치
        ////

        Long userId = refreshTokenService.findByRefreshToken(dto.getRefreshToken()).getUserId();
        User user = userService.findById(userId);

        return tokenProvider.generateToken(user, ACCESS_TOKEN_DURATION);
    }

    /**
     * 새로운 Access Token과 Refresh Token을 생성
     * 
     * @param dto
     * @return
     */
    public AuthenticateResponse createNewTokenSet(AuthenticateRequest dto) {
        // 유저의 이메일과 패스워드를 통해 유저를 확인
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                dto.getEmail(), dto.getPassword());
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);

        // 정상적으로 수행될 경우 user 객체 생성
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        User user = userService.findByEmail(userDetails.getUsername());

        // refresh token 생성
        String refreshToken = tokenProvider.generateToken(user, REFRESH_TOKEN_DURATION);
        // 기존에 저장된 refresh token이 있을 경우 교체, 없을 경우 새로 저장
        RefreshToken refreshTokenModel = refreshTokenRepository.findByUserId(user.getId())
                .map(entity -> entity.update(refreshToken))
                .orElse(new RefreshToken(user.getId(), refreshToken));
        refreshTokenRepository.save(refreshTokenModel);

        // access token 생성
        String accessToken = tokenProvider.generateToken(user, ACCESS_TOKEN_DURATION);

        return new AuthenticateResponse(accessToken, refreshTokenModel.getRefreshToken());
    }
}
