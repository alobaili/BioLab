import FluentMySQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Create and register a MySQL database config.
    var databaseConfig: MySQLDatabaseConfig
    var databases = DatabasesConfig()
    if let url = Environment.get("JAWSDB_URL") {
        databaseConfig = try! MySQLDatabaseConfig(url: url)!
    } else {
        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
        let username = Environment.get("DATABASE_USER") ?? "vapor"
        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
        let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databaseConfig = MySQLDatabaseConfig(hostname: hostname,
                                             username: username,
                                             password: password,
                                             database: databaseName)
    }
    let database = MySQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.mysql)
    migrations.add(model: Sample.self, database: DatabaseIdentifier<Sample.Database>.mysql)
    services.register(migrations)
    
    // Set the preferred view renderer
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
