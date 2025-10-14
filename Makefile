COMPOSE = docker-compose -f srcs/docker-compose.yml
DATA_PATH = $(HOME)/data

all: up

up:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

build:
	@$(COMPOSE) build

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

clean: down
	@$(COMPOSE) down -v

fclean: clean
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)/wordpress/
	@sudo rm -rf $(DATA_PATH)/mariadb/
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb

re: fclean all

.PHONY: all up down build logs ps clean fclean re
