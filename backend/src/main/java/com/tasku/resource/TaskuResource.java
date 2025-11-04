package com.tasku.resource;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/taskus")
public class TaskuResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Tasku API está funcionando";
    }
}

