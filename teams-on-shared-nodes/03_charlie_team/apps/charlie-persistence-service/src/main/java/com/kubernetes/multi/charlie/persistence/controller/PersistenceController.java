package com.kubernetes.multi.charlie.persistence.controller;

import com.kubernetes.multi.charlie.persistence.dto.ResponseDto;
import com.kubernetes.multi.charlie.persistence.entities.Value;
import com.kubernetes.multi.charlie.persistence.service.list.PersistenceListService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("persistence")
public class PersistenceController {

    @Autowired
    private PersistenceListService listService;

    @GetMapping("list")
    public ResponseEntity<ResponseDto<List<Value>>> list() {
        return listService.run();
    }
}
