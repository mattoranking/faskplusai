setup:
	@echo "🔧 Adding api.starterapp.dev to /etc/hosts if missing..."
	@grep -q "api.starterapp.dev" /etc/hosts || echo "127.0.0.1 api.starterapp.dev" | sudo tee -a /etc/hosts
	@echo "🔧 Adding starterapp.dev to /etc/hosts if missing..."
	@grep -q " starterapp.dev" /etc/hosts || echo "127.0.0.1 starterapp.dev" | sudo tee -a /etc/hosts
	@echo "🔧 Generating mkcert certificate for api.starterapp.dev..."
	@mkcert -cert-file traefik/certs/api.starterapp.dev.pem -key-file traefik/certs/api.starterapp.dev-key.pem api.starterapp.dev
	@echo "🔧 Generating mkcert certificate for starterapp.dev..."
	@mkcert -cert-file traefik/certs/starterapp.dev.pem -key-file traefik/certs/starterapp.dev-key.pem starterapp.dev
	@echo "✅ Setup complete"

dev:
	docker compose up --build

down:
	docker compose down
