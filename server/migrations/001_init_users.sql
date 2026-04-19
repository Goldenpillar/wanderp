-- [DEPRECATED] 001_init_users.sql
-- 注意：此文件已被 scripts/init-db.sql 替代，仅保留作为历史参考。
-- 新的数据库初始化请使用 scripts/init-db.sql。
-- 请勿在新环境中使用此文件执行数据库迁移。

-- 用户表初始化

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(20)  UNIQUE,
    password    VARCHAR(255) NOT NULL,
    avatar      VARCHAR(500),
    nickname    VARCHAR(50),
    bio         VARCHAR(200),
    gender      VARCHAR(10)  DEFAULT 'unknown' CHECK (gender IN ('male', 'female', 'unknown')),
    birthday    DATE,
    location    VARCHAR(200),
    status      VARCHAR(20)  DEFAULT 'active' CHECK (status IN ('active', 'disabled', 'banned')),
    last_login  TIMESTAMP,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

-- 创建偏好表
CREATE TABLE IF NOT EXISTS preferences (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT       NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    travel_style    VARCHAR(50)  CHECK (travel_style IN ('relax', 'adventure', 'culture', 'food', 'nature')),
    taste_prefs      VARCHAR(100),
    budget_level    VARCHAR(20)  CHECK (budget_level IN ('low', 'medium', 'high')),
    pace_level      VARCHAR(20)  CHECK (pace_level IN ('slow', 'moderate', 'fast')),
    accommodation   VARCHAR(50)  CHECK (accommodation IN ('hotel', 'hostel', 'apartment', 'camping')),
    transport       VARCHAR(50)  CHECK (transport IN ('walking', 'driving', 'public', 'ride')),
    interests       TEXT,        -- JSON数组
    avoidances      TEXT,        -- JSON数组
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_preferences_user_id ON preferences(user_id);
