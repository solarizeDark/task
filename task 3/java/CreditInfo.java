package ru.fedusiv.jdbc;

import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class CreditInfo {

    double rate;
    double sum;
    int term;

}
