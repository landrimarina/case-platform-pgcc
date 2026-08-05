package it.bdo.caseplatform.pgcc.application;

import it.bdo.caseplatform.pgcc.domain.HomePageMessage;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class GetHomePageMessage {

    public HomePageMessage execute() {
        return new HomePageMessage();
    }
}
