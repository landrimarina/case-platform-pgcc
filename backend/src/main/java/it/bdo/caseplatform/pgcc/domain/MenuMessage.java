package it.bdo.caseplatform.pgcc.domain;

public record MenuMessage(String message) {
    public MenuMessage() {
        this("Menù PGCC in costruzione");
    }
}
