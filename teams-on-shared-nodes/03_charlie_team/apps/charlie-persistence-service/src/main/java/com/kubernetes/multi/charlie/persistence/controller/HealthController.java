package com.kubernetes.multi.charlie.persistence.controller;

import com.kubernetes.multi.charlie.persistence.dto.ResponseDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("persistence/health")
public class HealthController {

    private final Logger logger = LoggerFactory.getLogger(HealthController.class);

    @GetMapping()
    public ResponseEntity<ResponseDto<String>> checkHealth(
            @RequestParam String name
    ) {
        logger.info("OK");

        var responseDto = new ResponseDto<String>();
        responseDto.setMessage("OK");
        responseDto.setStatusCode(HttpStatus.OK);

        return new ResponseEntity<>(
                responseDto,
                HttpStatus.OK
        );
    }
}
