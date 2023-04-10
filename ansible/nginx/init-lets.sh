#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains=(gitlab.devsecops23.maxmur.info vault.devsecops23.maxmur.info defectdojo.devsecops23.maxmur.info registry.gitlab.devsecops23.maxmur.info)
rsa_key_size=4096
data_path="./data/certbot"
email="muravjev.mak@yandex.ru" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

echo "### Generate ssl params ..."
docker-compose run --rm --entrypoint "\
  mkdir -p /etc/letsencrypt/conf" certbot
#docker-compose run --rm --entrypoint "\
#  openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 4096" certbot
docker-compose up -d certbot
docker cp ./ssl-dhparams.pem certbot:/etc/letsencrypt/ssl-dhparams.pem
docker cp ./options-ssl-nginx.conf certbot:/etc/letsencrypt/options-ssl-nginx.conf
docker stop certbot && docker rm certbot

echo "### Creating dummy certificate for $domains ..."
for domain in "${domains[@]}"; do
  path="/etc/letsencrypt/live/$domain"
  docker-compose run --rm --entrypoint "\
    mkdir -p /etc/letsencrypt/live/$domain" certbot
  docker-compose run --rm --entrypoint "\
    openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
      -keyout '$path/privkey.pem' \
      -out '$path/fullchain.pem' \
      -subj '/CN=localhost'" certbot
  docker-compose run --rm --entrypoint "\
    chown -R 101:101 /etc/letsencrypt/" certbot
  echo
done

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx; sleep 5
echo

echo "### Deleting dummy certificate for $domains ..."
for domain in "${domains[@]}"; do
  docker-compose run --rm --entrypoint "\
    rm -Rf /etc/letsencrypt/live/$domain && \
    rm -Rf /etc/letsencrypt/archive/$domain && \
    rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
  echo
done

echo "### Requesting Let's Encrypt certificate for $domains ..."
# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="-d $domain"
  docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --non-interactive \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
  echo
done

docker-compose run --rm --entrypoint "\
  chown -R 101:101 /etc/letsencrypt" certbot

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

