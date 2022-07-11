package com.kubernetes.multi.charlie.proxy.service.persistence.create;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreateRequestDto {

    private String value;
    private String tag;
}
