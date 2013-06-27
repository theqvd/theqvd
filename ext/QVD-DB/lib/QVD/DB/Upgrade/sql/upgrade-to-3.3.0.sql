
CREATE TABLE versions (
       component VARCHAR(100) NOT NULL,
       version   VARCHAR(100) NOT NULL,
       PRIMARY KEY (component)
);

INSERT INTO versions VALUES ('schema', '3.3.0');

ALTER TABLE vm_runtimes ADD COLUMN vm_expiration_soft TIMESTAMP;
ALTER TABLE vm_runtimes ADD COLUMN vm_expiration_hard TIMESTAMP;
