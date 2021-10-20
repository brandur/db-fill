INSERT INTO random_data (data) 
    SELECT random_data(100000) -- ~100 kb
    -- FROM generate_series(1, 100) -- ~10 MB
    -- FROM generate_series(1, 5000) -- ~500 MB
    FROM generate_series(1, 76000) -- ~7600 MB
;