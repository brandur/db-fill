# db-fill

Some simple scripts to artificially fill a Postgres database.

    # edit $TEST_DATABASE_URL
    cp .envrc.sample .envrc
    direnv allow

    # reset schema
    psql $TEST_DATABASE_URL < schema.sql

    # edit file to set MBs to generate
    psql $TEST_DATABASE_URL < fill2.sql

    # get current size
    psql $TEST_DATABASE_URL < size.sql
