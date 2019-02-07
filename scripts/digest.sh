cd assets/
yarn deploy
cd ..
sudo PORT=80 MIX_ENV=prod mix phx.digest
