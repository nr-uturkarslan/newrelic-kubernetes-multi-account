package com.kubernetes.multi.charlie.proxy.controller;

import com.kubernetes.multi.charlie.proxy.dto.ResponseDto;
import com.kubernetes.multi.charlie.proxy.service.persistence.create.CreateRequestDto;
import com.kubernetes.multi.charlie.proxy.service.persistence.create.PersistenceCreateService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("proxy/persistence")
public class PersistenceController {

    private final Logger logger = LoggerFactory.getLogger(PersistenceController.class);

    @Autowired
    private PersistenceCreateService createService;

    @PostMapping("create")
    public ResponseEntity<ResponseDto<CreateRequestDto>> create(
        @RequestBody CreateRequestDto requestDto
    ) {
        logger.info("Create method is triggered...");

        var responseDto = createService.run(requestDto);

        logger.info("Create method is executed.");

        return responseDto;
    }
}
