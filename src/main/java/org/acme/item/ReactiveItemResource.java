package org.acme.item;

import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/reactive/items")
@Produces(MediaType.APPLICATION_JSON)
public class ReactiveItemResource {

    @Inject
    ReactiveItemService service;

    @GET
    @Path("{id}")
    public Uni<ItemDto> getItem(@PathParam("id") long id) {
        return service.getItemById(id);
    }
}
