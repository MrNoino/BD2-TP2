INSERT INTO public."Rule" (rule, description)
VALUES
('>', 'Maior que'), 
('<', 'Menor que'),
('>=', 'Maior ou igual que'),
('<=', 'Menor ou igual que'),
('=', 'Igual a'),
('!=', 'Diferente de');

INSERT INTO public."SensorType" (type)
VALUES
('Temperatura'), 
('Luminosidade'),
('Movimento'),
('Gás');

CREATE EXTENSION pgcrypto;

INSERT INTO public."User" (name, email, password)
VALUES
('Nuno Lopes', 'nuno@gmail.com', crypt('pwd', gen_salt('bf')));