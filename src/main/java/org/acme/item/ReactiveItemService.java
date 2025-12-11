package org.acme.item;

import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.sqlclient.Pool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.NotFoundException;

import java.time.Duration;

@ApplicationScoped
public class ReactiveItemService {

    private static final String ITEM_QUERY = "SELECT id, name, description FROM items WHERE id = $1";

    @Inject
    Pool client;

    public Uni<ItemDto> getItemById(long id) {
        return client
                .preparedQuery(ITEM_QUERY)
                .execute(Tuple.of(id))
                .onItem().transformToUni(this::mapRowSet)
                .onItem().transformToUni(item -> Uni.createFrom().item(item)
                        .onItem().delayIt().by(Duration.ofMillis(20)));
    }

    private Uni<ItemDto> mapRowSet(RowSet<Row> rows) {
        if (!rows.iterator().hasNext()) {
            return Uni.createFrom().failure(new NotFoundException());
        }
        Row row = rows.iterator().next();
        return Uni.createFrom().item(new ItemDto(row.getLong("id"), row.getString("name"), row.getString("description")));
    }
}
