BEGIN;

DROP TABLE IF EXISTS random_text;

CREATE TABLE random_text (
    id bigserial PRIMARY KEY,
    data text
);

-- N bytes worth data
DROP FUNCTION IF EXISTS random_text;
CREATE OR REPLACE FUNCTION random_text(data_length bigint)
RETURNS text
AS $$
BEGIN
  RETURN array_to_string(array(select substr('abcdefghijklmnopqrstuvwxyz0123456789', ((random()*(36-1)+1)::integer), 1) from generate_series(1,data_length)), '');
END
$$
LANGUAGE plpgsql
VOLATILE;

-- rows of 1 MB each
DROP FUNCTION IF EXISTS random_rows;
CREATE OR REPLACE FUNCTION random_rows(num_rows bigint)
RETURNS void
AS $FN$
DECLARE
  data_length int = 1000000;
  shift_length int = 100;
  generated_data text = random_text(data_length); -- 1 MB
BEGIN
  FOR counter IN 1..num_rows LOOP
    -- Just shift data a bit instead of generating an entirely new string from
    -- scratch because it's much faster. We shift it so that not every row has
    -- exactly the same value to head off any kind of TOAST deduplication logic
    -- there might be (I'm not 100% sure whether this is a thing, but I think it
    -- might be). This way every blob is unique.
    generated_data = substr(generated_data, shift_length+1, data_length-shift_length) || random_text(shift_length);

    EXECUTE $$ INSERT INTO random_text (data) VALUES ($1) $$
      USING generated_data;
  END LOOP;
END;
$FN$
LANGUAGE plpgsql
VOLATILE;

COMMIT;
