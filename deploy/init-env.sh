#!/usr/bin/env sh
# 生成 deploy/.env，并填入随机密码和密钥。用法：./init-env.sh api.example.com admin@example.com
set -eu

cd "$(dirname "$0")"

if [ -f .env ]; then
  echo ".env 已存在，为避免覆盖密钥已退出。" >&2
  exit 1
fi

if [ $# -lt 2 ]; then
  echo "用法: $0 <域名> <证书邮箱>" >&2
  exit 1
fi

cat > .env <<EOF
DOMAIN=$1
ACME_EMAIL=$2
NEW_API_IMAGE=calciumion/new-api:latest
POSTGRES_PASSWORD=$(openssl rand -hex 24)
REDIS_PASSWORD=$(openssl rand -hex 24)
SESSION_SECRET=$(openssl rand -hex 32)
CRYPTO_SECRET=$(openssl rand -hex 32)
TZ=Asia/Shanghai
STREAMING_TIMEOUT=300
EOF
chmod 600 .env
echo "已生成 $(pwd)/.env，请妥善备份。"
