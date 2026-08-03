package it.bdo.caseplatform.pgcc.api;

import it.bdo.caseplatform.pgcc.application.GetBackendMessage;
import it.bdo.caseplatform.pgcc.domain.BackendMessage;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/api/pgcc/message")
@Produces(MediaType.APPLICATION_JSON)
public class BackendMessageResource {

    private final GetBackendMessage getBackendMessage;

    @Inject
    public BackendMessageResource(GetBackendMessage getBackendMessage) {
        this.getBackendMessage = getBackendMessage;
    }

    @GET
    public BackendMessage getMessage() {
        return getBackendMessage.execute();
    }
}
