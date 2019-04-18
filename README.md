
With a Docker contianer based on Alpine, we get this error at runtime with
ocaml-caqti:

> Failed: Request to <mariadb://root:_@db/goomba> failed: Error 1264,  Query: "INSERT INTO test_sql (i, s) VALUES (?, ?)".
> Fatal error: exception Request to <mariadb://root:_@db/goomba> failed: Error 1264,  Query: "INSERT INTO test_sql (i, s) VALUES (?, ?)".

To reproduce, in three separate terminal sessions run these commands in order:

1. `make start`
2. `make follow-db-logs`
3. `make run`