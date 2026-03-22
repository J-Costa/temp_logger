# Temp Logger

Aplicacao Rails configurada para usar PostgreSQL com TimescaleDB em Docker.

## Requisitos

- Docker e Docker Compose
- Ruby 3.3.4
- Bundler

## Configuracao de ambiente

1. Copie o arquivo de exemplo:

	cp .env.example .env

2. Ajuste os valores do `.env` se necessario.

## Subir o TimescaleDB

Use o compose do projeto:

docker compose up -d

Banco padrao:

- Host: localhost
- Porta: 6543
- Usuario: postgres
- Senha: password
- Database: temp_logger_development

## Preparar o Rails

1. Instale as gems:

	bundle install

2. Crie os bancos:

	bin/rails db:create

3. Rode migracoes:

	bin/rails db:migrate

## Extensao TimescaleDB

O projeto inclui o script `docker/timescaledb/init/001_enable_timescaledb.sql`.
Esse script roda automaticamente na inicializacao do banco e cria a extensao `timescaledb`.

Importante: scripts em `docker-entrypoint-initdb.d` so rodam quando o volume e criado do zero.
Se o volume ja existia, recrie o banco local para aplicar o script:

docker compose down -v
docker compose up -d

Se preferir manter o volume atual, habilite manualmente via `bin/rails dbconsole`:

CREATE EXTENSION IF NOT EXISTS timescaledb;

## Comandos uteis

- Ver status dos containers:

  docker compose ps

- Ver logs do banco:

  docker compose logs -f timescaledb

- Derrubar servicos:

  docker compose down
