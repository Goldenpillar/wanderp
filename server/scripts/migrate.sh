#!/bin/bash
# 数据库迁移脚本
# 使用方式: ./scripts/migrate.sh [up|down] [环境]
# 示例: ./scripts/migrate.sh up dev

set -e

# 默认参数
ACTION=${1:-up}
ENV=${2:-dev}

# 数据库连接配置
case $ENV in
  dev)
    DB_HOST="localhost"
    DB_PORT="5432"
    DB_USER="wanderp"
    DB_PASSWORD="wanderp_dev_password"
    DB_NAME="wanderp"
    ;;
  prod)
    DB_HOST=${DB_HOST:-"localhost"}
    DB_PORT=${DB_PORT:-"5432"}
    DB_USER=${DB_USER:-"wanderp"}
    DB_PASSWORD=${DB_PASSWORD:-""}
    DB_NAME=${DB_NAME:-"wanderp"}
    ;;
  *)
    echo "未知环境: $ENV (支持: dev, prod)"
    exit 1
    ;;
esac

export PGPASSWORD=$DB_PASSWORD

MIGRATIONS_DIR="./migrations"

echo "=========================================="
echo "  WanderP 数据库迁移"
echo "  环境: $ENV"
echo "  操作: $ACTION"
echo "  数据库: $DB_NAME@$DB_HOST:$DB_PORT"
echo "=========================================="

case $ACTION in
  up)
    echo "开始执行迁移..."
    for sql_file in $(ls $MIGRATIONS_DIR/*.sql | sort); do
      echo "执行: $sql_file"
      psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$sql_file"
      echo "完成: $sql_file"
    done
    echo "所有迁移执行完成!"
    ;;
  down)
    echo "开始回滚迁移..."
    for sql_file in $(ls $MIGRATIONS_DIR/*.sql | sort -r); do
      echo "回滚: $sql_file (需要手动编写回滚SQL)"
      # TODO: 实现回滚逻辑
    done
    echo "回滚完成!"
    ;;
  status)
    echo "检查迁移状态..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt"
    ;;
  *)
    echo "未知操作: $ACTION (支持: up, down, status)"
    exit 1
    ;;
esac

unset PGPASSWORD
