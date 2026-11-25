# 生产部署

本目录用 Docker Compose 部署一套完整的站点：Caddy 负责 HTTPS 和反向代理，new-api 跑网关和控制台，PostgreSQL 存数据，Redis 做缓存。

## 准备

- 一台 Linux 服务器（amd64 或 arm64），2 核 4G 起步，已安装 Docker 和 Docker Compose 插件
- 一个域名，A 记录已指向服务器公网 IP
- 服务器防火墙或安全组放行 80 和 443 端口

## 首次部署

```bash
git clone https://github.com/DonkeyBoy001/new-api.git
cd new-api/deploy
./init-env.sh api.你的域名.com 你的邮箱@example.com   # 生成 .env 和随机密钥
docker compose up -d
docker compose logs -f new-api
```

打开 `https://api.你的域名.com`，按初始化向导创建管理员账号。Caddy 会自动申请和续期证书。

## 上线后在后台配置

1. **系统设置 → 个性化**：站点名称、Logo、首页内容、页脚。页脚必须保留原项目署名，见下文「许可证」。
2. **渠道**：添加上游 Key，选择模型和分组，点「测试」确认可用。
3. **定价**：设置模型倍率或价格，确认分组倍率。
4. **支付**：在支付设置里配置易支付、Stripe 或 Creem，并在服务商后台填写回调地址。
5. **注册与安全**：按需开启邮箱验证、OAuth 登录、两步验证。

## 升级

```bash
cd new-api/deploy
docker compose pull new-api
docker compose up -d new-api
```

升级前请先备份数据库，并阅读 [上游发布说明](https://github.com/QuantumNous/new-api/releases)。建议在 `.env` 里把 `NEW_API_IMAGE` 固定到具体版本，确认没问题后再改版本号升级。

## 备份

```bash
# 导出数据库（可放进 crontab 每天执行）
docker exec postgres pg_dump -U newapi new-api | gzip > backup-$(date +%F).sql.gz
```

`.env` 里的 `SESSION_SECRET` 和 `CRYPTO_SECRET` 也要一起备份，丢失后已加密的数据无法解密。

## 使用自己 fork 构建的镜像

改了代码以后，在仓库根目录构建镜像，再把 `.env` 里的 `NEW_API_IMAGE` 改成新镜像名：

```bash
docker build -t ghcr.io/donkeyboy001/new-api:custom .
```

## 许可证

new-api 使用 AGPL-3.0，并在 `NOTICE` 中附加了条款：

- 界面的页脚或「关于」页必须保留 “Frontend design and development by New API contributors.” 以及指向 https://github.com/QuantumNous/new-api 的链接。
- 修改代码后对外提供服务，必须向用户提供修改后的完整源码，例如保持本仓库公开，并在站内放源码链接。
