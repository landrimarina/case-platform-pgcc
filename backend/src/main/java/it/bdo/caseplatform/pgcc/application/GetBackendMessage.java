package it.bdo.caseplatform.pgcc.application;

import it.bdo.caseplatform.pgcc.domain.BackendMessage;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GetBackendMessage {

    public BackendMessage execute() {
        return new BackendMessage("PGCC backend is running");
    }
}
