sudo fuser -k 80/tcp
sudo CRAWL=true PORT=80 MIX_ENV=prod elixir --detached -S mix phx.server
