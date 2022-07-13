package com.kubernetes.multi.charlie.proxy.controller;

import com.kubernetes.multi.charlie.proxy.dto.ResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("charlie/proxy/health")
public class HealthController {

    @GetMapping()
    public ResponseEntity<ResponseDto<String>> checkHealth() {

        var responseDto = new ResponseDto<String>();
        responseDto.setMessage("OK");
        responseDto.setStatusCode(HttpStatus.OK.value());

        return new ResponseEntity<>(
            responseDto,
            HttpStatus.OK
        );
    }
}
