package it.bdo.caseplatform.pgcc.api;

import it.bdo.caseplatform.pgcc.application.GetMenuMessage;
import it.bdo.caseplatform.pgcc.domain.MenuMessage;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/api/pgcc/menu")
@Produces(MediaType.APPLICATION_JSON)
public class MenuMessageResource {

    private final GetMenuMessage getMenuMessage;

    @Inject
    public MenuMessageResource(GetMenuMessage getMenuMessage) {
        this.getMenuMessage = getMenuMessage;
    }

    @GET
    public MenuMessage getMenuMessage() {
        return getMenuMessage.execute();
    }
}
