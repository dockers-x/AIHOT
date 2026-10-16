# AIHOT Docker Compose

这是 [KKKKhazix/AIHOT](https://github.com/KKKKhazix/AIHOT) 的轻量 Docker Compose 部署仓库。
本仓库**不保存上游源码**：GitHub Actions 检测到上游 `main` 更新后，会拉取并锁定该提交构建镜像。

## 部署

```sh
git clone https://github.com/dockers-x/AIHOT.git
cd AIHOT
./init-env.sh
# 按需编辑 .env，至少补上 LLM_API_KEY；未配置模型时也可以先查看界面。
docker compose up -d
```

打开 <http://localhost:3000>，后台地址是 <http://localhost:3000/admin>。
`./init-env.sh` 会输出管理员密码，并将它保存在仅当前用户可读的 `.env` 中。

> 不要直接运行镜像的默认命令代替 Compose。AIHOT 需要 PostgreSQL，以及
> `setup`、`api`、`worker`、`web` 四个角色；`setup` 会在 API 启动前执行数据库迁移和初始数据导入。

## 常用命令

```sh
# 查看状态和初始化是否成功
docker compose ps -a
docker compose logs setup api web

# 更新到最新自动构建镜像
docker compose pull
docker compose up -d

# 查看当前管理员密码（请勿把输出粘贴到公开日志）
grep '^ADMIN_PASSWORD=' .env
```

若 `/admin` 显示没有设置管理员密码，说明部署没有读取 `.env`。请确认 `.env` 位于
`docker-compose.yml` 同一目录，再执行 `docker compose config` 检查配置并重新启动。

## 自动构建

[`.github/workflows/image.yml`](.github/workflows/image.yml) 每 6 小时检查一次上游：

1. 获取上游 `main` 的 commit SHA；
2. 与 `upstream.json` 中最后成功构建的 SHA 比较；
3. checkout 该上游提交并构建 `linux/amd64` 镜像；
4. 推送版本标签和 `latest`；
5. 仅在镜像推送成功后更新 `upstream.json`。

可在 Actions 页面手动运行并勾选 `force` 强制重建。
