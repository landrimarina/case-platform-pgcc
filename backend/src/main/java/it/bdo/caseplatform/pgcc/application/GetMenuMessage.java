package it.bdo.caseplatform.pgcc.application;

import it.bdo.caseplatform.pgcc.domain.MenuMessage;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GetMenuMessage {

    public MenuMessage execute() {
        return new MenuMessage();
    }
}
