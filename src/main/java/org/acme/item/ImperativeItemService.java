package org.acme.item;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

@ApplicationScoped
public class ImperativeItemService {

    private static final String ITEM_QUERY = "SELECT id, name, description FROM items WHERE id = ?";

    @Inject
    DataSource dataSource;

    public Optional<ItemDto> getItemById(long id) {
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(ITEM_QUERY)) {
            statement.setLong(1, id);

            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return Optional.empty();
                }

                // Simulate latency of an external HTTP call
                Thread.sleep(20);

                return Optional.of(new ItemDto(rs.getLong("id"), rs.getString("name"), rs.getString("description")));
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Interrupted while querying item " + id, e);
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to query item " + id, e);
        }
    }
}
