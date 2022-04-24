package ru.fedusiv.jdbc;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.jdbc.core.JdbcTemplate;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Properties;

public class Main {

    public static HikariDataSource hikariDataSource() {

        Properties properties = new Properties();
        try (InputStream input = new FileInputStream("src\\main\\resources\\db.properties")) {
            properties.load(input);
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
        HikariConfig hikariConfig = new HikariConfig();
        hikariConfig.setJdbcUrl(properties.getProperty("db.url"));
        hikariConfig.setDriverClassName(properties.getProperty("db.driver"));
        hikariConfig.setUsername(properties.getProperty("db.username"));
        hikariConfig.setPassword(properties.getProperty("db.password"));
        hikariConfig.setMaximumPoolSize(Integer.parseInt(properties.getProperty("db.max-pool-size")));
        HikariDataSource dataSource = new HikariDataSource(hikariConfig);

        return dataSource;
    }

    public static JdbcTemplate jdbcTemplate() {
        JdbcTemplate jdbcTemplate = new JdbcTemplate(hikariDataSource());
        SqlExceptionsTranslator sqlViolation = new SqlExceptionsTranslator();
        sqlViolation.setDataSource(hikariDataSource());
        jdbcTemplate.setExceptionTranslator(sqlViolation);

        return jdbcTemplate;
    }

    public static void main(String[] args) {
        CreditsRepository repository = new CreditsRepository(jdbcTemplate());

        CreditInfo creditInfo = repository.getCreditInfoById(4L);
         calculation(creditInfo.getTerm(), creditInfo.getRate(), creditInfo.getSum());
    }

    // alternative() : payment = round2(sum * i / ( 1 - Math.pow(1 + i, -1 * months)));
    public static void calculation(int months, double rate, double sum) {
        // перевод процентной ставки из годовой в месячную
        double i = rate / 100 / 12;
        // временная переменная для расчета коэффициента
        double temp = Math.pow(1 + i, months);
        // коэффициент аннуитета
        double k = i * temp / (temp - 1);
        // ежемесячный платеж
        double payment = round2(k * sum);
        System.out.println("# month | payment | main duty | percents duty | main duty left");
        int month = 1;

        double dutyByPercents, mainDuty;

        while (sum > 0) {
            // долг по процентам
            dutyByPercents = round2(i * sum);
            // выплаченный основной долг
            mainDuty = round2(payment - dutyByPercents);
            System.out.printf("%7d | %.2f | %9.2f | %13.2f | %.2f \n", month++, payment, mainDuty,
                                dutyByPercents, (sum -= mainDuty) < 0 ? 0 : sum);
        }
    }

    // округление до 2 десятичных знаков
    public static double round2 (double value) {
        return new BigDecimal(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

}
