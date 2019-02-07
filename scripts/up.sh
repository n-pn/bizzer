sudo PORT=80 MIX_ENV=prod mix deps.get
sudo PORT=80 MIX_ENV=prod mix ecto.migrate
cd assets/
yarn
cd ..
sudo PORT=80 MIX_ENV=prod mix phx.digest
sudo fuser -k 80/tcp
sudo CRAWL=true PORT=80 MIX_ENV=prod elixir --detached -S mix phx.server
