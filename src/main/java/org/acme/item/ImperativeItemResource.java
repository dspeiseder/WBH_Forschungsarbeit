package org.acme.item;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/imperative/items")
@Produces(MediaType.APPLICATION_JSON)
public class ImperativeItemResource {

    @Inject
    ImperativeItemService service;

    @GET
    @Path("{id}")
    public ItemDto getItem(@PathParam("id") long id) {
        return service.getItemById(id).orElseThrow(NotFoundException::new);
    }
}
