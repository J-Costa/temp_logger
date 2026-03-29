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

## Ler dados do Arduino (NTC via serial USB)

O sketch do Arduino envia uma linha por segundo com a temperatura em Celsius.
Este projeto inclui uma task para ler a serial e salvar no banco.

1. Instale as gems (inclui serialport):

	bundle install

2. Configure a porta serial no `.env` (ou via export):

	SERIAL_PORT=/dev/ttyACM0
	SERIAL_BAUD=9600

3. Rode as migracoes para criar a tabela de leituras:

	bin/rails db:migrate

4. Leia uma amostra de teste:

	bin/rake arduino:read_once

5. Rode a leitura continua:

	bin/rake arduino:read_serial

Para ver os dados no webapp, acesse a raiz da aplicacao (`/`) ou:

	/temperature_readings

### Dica para Raspberry Pi

Em geral, o usuario precisa de permissao no grupo `dialout` para acessar `/dev/ttyACM0`:

	sudo usermod -aG dialout $USER

Depois, saia e entre novamente na sessao.

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

## Servicos systemd no Raspberry Pi

Este repositorio inclui dois unit files para iniciar automaticamente no boot:

- deploy/systemd/temp_logger_reader.service
- deploy/systemd/temp_logger_web.service

### Instalar os servicos

1. Copie os unit files para o systemd:

sudo install -m 644 deploy/systemd/temp_logger_reader.service /etc/systemd/system/temp_logger_reader.service
sudo install -m 644 deploy/systemd/temp_logger_web.service /etc/systemd/system/temp_logger_web.service

2. Recarregue o systemd e habilite os dois servicos:

sudo systemctl daemon-reload
sudo systemctl enable --now temp_logger_reader.service
sudo systemctl enable --now temp_logger_web.service

3. Verifique status e logs:

systemctl status temp_logger_reader.service
systemctl status temp_logger_web.service
journalctl -u temp_logger_reader.service -f
journalctl -u temp_logger_web.service -f

### Acesso via rede local

Descubra o IP do Raspberry e abra no navegador de outro dispositivo na mesma rede:

hostname -I

Use o endereco:

http://IP_DO_RASPBERRY:3000

Se houver firewall ativo:

sudo ufw allow 3000/tcp
