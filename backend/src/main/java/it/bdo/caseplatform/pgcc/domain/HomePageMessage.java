package it.bdo.caseplatform.pgcc.domain;

public record HomePageMessage(String message) {
    public HomePageMessage() {
        this("Benvenuto nella piattaforma PGCC. Qui puoi trovare tutte le informazioni necessarie per gestire i tuoi casi in modo efficiente.");
    }
}