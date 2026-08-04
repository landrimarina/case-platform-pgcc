package it.bdo.caseplatform.pgcc.api;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;

@QuarkusTest
class BackendMessageResourceTest {

    @Test
    void shouldReturnBackendMessage() {
        given()
            .when()
            .get("/api/pgcc/message")
            .then()
            .statusCode(200)
            .body("message", is("PGCC backend is running"));
    }
}
