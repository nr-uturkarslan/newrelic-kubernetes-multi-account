package com.kubernetes.multi.charlie.proxy.controller;

import com.kubernetes.multi.charlie.proxy.dto.ResponseDto;
import com.kubernetes.multi.charlie.proxy.service.persistence.create.dto.CreateValueRequestDto;
import com.kubernetes.multi.charlie.proxy.service.persistence.create.CreateValueService;
import com.kubernetes.multi.charlie.proxy.service.persistence.list.ListValuesService;
import com.kubernetes.multi.charlie.proxy.service.persistence.list.dto.ListValuesResponseDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("charlie/proxy/persistence")
public class PersistenceController {

    private final Logger logger = LoggerFactory.getLogger(PersistenceController.class);

    @Autowired
    private CreateValueService createService;

    @Autowired
    private ListValuesService listService;

    @PostMapping("create")
    public ResponseEntity<ResponseDto<CreateValueRequestDto>> create(
        @RequestBody CreateValueRequestDto requestDto
    ) {
        logger.info("Create method is triggered...");

        var responseDto = createService.run(requestDto);

        logger.info("Create method is executed.");

        return responseDto;
    }

    @GetMapping("list")
    public ResponseEntity<ResponseDto<ListValuesResponseDto>> create() {
        logger.info("List method is triggered...");

        var responseDto = listService.run();

        logger.info("List method is executed.");

        return responseDto;
    }
}
