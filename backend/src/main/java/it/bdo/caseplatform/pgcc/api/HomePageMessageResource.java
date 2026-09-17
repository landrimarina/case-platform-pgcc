package it.bdo.caseplatform.pgcc.api;

import it.bdo.caseplatform.pgcc.application.GetHomePageMessage;
import it.bdo.caseplatform.pgcc.domain.HomePageMessage;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/api/pgcc/home")
@Produces(MediaType.APPLICATION_JSON)
public class HomePageMessageResource {

    private final GetHomePageMessage getHomePageMessage;

    @Inject
    public HomePageMessageResource(GetHomePageMessage getHomePageMessage) {
        this.getHomePageMessage = getHomePageMessage;
    }

    @GET
    public HomePageMessage getMessage() {
        return getHomePageMessage.execute();
    }
}
