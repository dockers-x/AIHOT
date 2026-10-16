#!/bin/sh
set -eu

if [ -e .env ]; then
  echo '.env already exists; refusing to overwrite it.' >&2
  exit 1
fi

if [ ! -f .env.example ]; then
  echo 'Run this script from the repository root.' >&2
  exit 1
fi

random_hex() {
  bytes=$1
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex "$bytes"
  elif [ -r /dev/urandom ] && command -v od >/dev/null 2>&1; then
    od -An -N "$bytes" -tx1 /dev/urandom | tr -d ' \n'
  else
    echo 'openssl or /dev/urandom with od is required.' >&2
    exit 1
  fi
}

admin_password=$(random_hex 12)
session_secret=$(random_hex 32)
img_secret=$(random_hex 32)
postgres_password=$(random_hex 18)

awk \
  -v admin="$admin_password" \
  -v session="$session_secret" \
  -v image="$img_secret" \
  -v postgres="$postgres_password" '
  /^ADMIN_PASSWORD=$/ { print "ADMIN_PASSWORD=" admin; next }
  /^SESSION_SECRET=$/ { print "SESSION_SECRET=" session; next }
  /^IMG_PROXY_SIGN_SECRET=$/ { print "IMG_PROXY_SIGN_SECRET=" image; next }
  /^POSTGRES_PASSWORD=$/ { print "POSTGRES_PASSWORD=" postgres; next }
  { print }
' .env.example > .env
chmod 600 .env

cat <<EOF
Created .env.
Admin URL: ${SITE_URL:-http://localhost:3000}/admin
Admin password: $admin_password

The password is also stored in .env. Configure LLM_API_KEY, then set
COLLECT_ENABLED=true and MODEL_CALLS_ENABLED=true when you are ready.
EOF
