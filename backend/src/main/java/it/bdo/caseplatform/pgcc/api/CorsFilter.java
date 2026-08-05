package it.bdo.caseplatform.pgcc.api;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;

@Provider
public class CorsFilter implements ContainerResponseFilter {

    @Override
    public void filter(ContainerRequestContext request, ContainerResponseContext response) {
        String origin = request.getHeaderString("Origin");
        if (origin != null && (origin.startsWith("http://localhost:3000") || origin.startsWith("http://localhost:3001"))) {
            response.getHeaders().putSingle("Access-Control-Allow-Origin", origin);
            response.getHeaders().putSingle("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
            response.getHeaders().putSingle("Access-Control-Allow-Headers", "Content-Type,Authorization,Accept");
        }
    }
}
