package ru.fedusiv.jdbc;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import javax.sql.DataSource;

public class CreditsRepository {

    private JdbcTemplate jdbcTemplate;

    private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public CreditsRepository(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
    }

    public CreditsRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // language=SQL
    private String SQL_GET_CREDIT_INFO =
            "select sum, rate, term from applications where applicant_id = ?";

    private RowMapper<CreditInfo> rowMapper = (row, rowNum) ->
            CreditInfo.builder()
            .rate(row.getDouble("rate"))
            .term(row.getInt("term"))
            .sum(row.getDouble("sum"))
            .build();

    public CreditInfo getCreditInfoById(Long id) {
        return jdbcTemplate.query(SQL_GET_CREDIT_INFO, rowMapper, id).get(0);
    }

}
