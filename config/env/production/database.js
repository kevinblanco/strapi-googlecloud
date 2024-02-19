module.exports = ({ env }) => ({
    connection: {
      client: "postgres",
      connection: {
        host: `/cloudsql/${env("INSTANCE_CONNECTION_NAME")}`,
        database: env("DATABASE_NAME"),
        user: env("DATABASE_USER"),
        password: env("DATABASE_PASSWORD"),
      },
    },
 });