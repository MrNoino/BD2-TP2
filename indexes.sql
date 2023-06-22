CREATE INDEX system_index on public."System"(id, owner_id);

CREATE INDEX alert_index on public."Alert"(id, sensor_id);

CREATE INDEX user_index on public."User"(email, password);