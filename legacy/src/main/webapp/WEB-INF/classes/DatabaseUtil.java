import java.sql.*;
import java.util.*;

public class DatabaseUtil {
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/creditcontrol";
    private static final String DB_USER = "postgres";
    private static final String DB_PASSWORD = "postgres";
    
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL JDBC Driver not found", e);
        }
    }
    
    public static void closeConnection(Connection conn, PreparedStatement stmt, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) {}
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException e) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) {}
        }
    }
}