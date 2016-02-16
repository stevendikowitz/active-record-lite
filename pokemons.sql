CREATE TABLE pokemons (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  gym_leader_id INTEGER,

  FOREIGN KEY(gym_leader_id) REFERENCES gym_leader_id(id)
);

CREATE TABLE gym_leaders (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  gym_id INTEGER,

  FOREIGN KEY(gym_id) REFERENCES gym(id)
);

CREATE TABLE gyms (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  gyms (id, name)
VALUES
  (1, "Rock"), (2, "Water"), (3, "Electric"), (4, "Grass");

INSERT INTO
  gym_leaders (id, name, gym_id)
VALUES
  (1, "Brock", 1),
  (2, "Misty", 2),
  (3, "Lt. Surge", 3),
  (4, "Erika", 4);

INSERT INTO
  pokemons (id, name, gym_leader_id)
VALUES
  (1, "Onyx", 1),
  (2, "Magikarp", 2),
  (3, "Electrode", 3),
  (4, "Weedle", 4);
