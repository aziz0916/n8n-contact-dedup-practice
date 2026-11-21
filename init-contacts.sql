CREATE TABLE contacts (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL
);

INSERT INTO contacts (name, email)
VALUES
  ('王小明', 'ming@example.com'),
  ('林小美', 'mei@example.com');