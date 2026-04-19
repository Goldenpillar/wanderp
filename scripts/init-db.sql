-- =============================================================================
-- WanderP - 数据库初始化脚本
-- =============================================================================
-- 说明: 此脚本在PostgreSQL容器首次启动时自动执行
-- 包含所有业务表的创建、索引和约束定义
-- =============================================================================

-- 设置客户端编码
SET client_encoding = 'UTF8';

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 用户模块
-- =============================================================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL       PRIMARY KEY,                                          -- 用户ID
    phone       VARCHAR(20)     NOT NULL,                                             -- 手机号
    nickname    VARCHAR(50)     NOT NULL DEFAULT '',                                   -- 昵称
    avatar      VARCHAR(500)    NOT NULL DEFAULT '',                                   -- 头像URL
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),                                -- 创建时间
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 更新时间
);

-- 用户表注释
COMMENT ON TABLE  users                    IS '用户表';
COMMENT ON COLUMN users.id                 IS '用户ID，自增主键';
COMMENT ON COLUMN users.phone              IS '手机号，登录凭证';
COMMENT ON COLUMN users.nickname           IS '用户昵称';
COMMENT ON COLUMN users.avatar             IS '头像URL地址';
COMMENT ON COLUMN users.created_at         IS '账户创建时间';
COMMENT ON COLUMN users.updated_at         IS '信息最后更新时间';

-- 用户表索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_phone ON users (phone);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at DESC);

-- 用户表约束
ALTER TABLE users ADD CONSTRAINT chk_users_phone_format
    CHECK (phone ~ '^\+?[0-9]{10,15}$');

-- 用户偏好设置表
CREATE TABLE IF NOT EXISTS user_preferences (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 偏好ID
    user_id         BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 关联用户ID
    taste_prefs     JSONB           NOT NULL DEFAULT '[]'::JSONB,                          -- 口味偏好（美食相关）
    budget_range    VARCHAR(50)     NOT NULL DEFAULT 'medium',                             -- 预算范围: low/medium/high/luxury
    travel_style    VARCHAR(50)     NOT NULL DEFAULT 'balanced',                           -- 旅行风格: relaxed/adventure/balanced/cultural/foodie
    interests       JSONB           NOT NULL DEFAULT '[]'::JSONB,                          -- 兴趣标签列表
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),                                -- 创建时间
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 更新时间
);

-- 用户偏好表注释
COMMENT ON TABLE  user_preferences             IS '用户偏好设置表';
COMMENT ON COLUMN user_preferences.id          IS '偏好记录ID';
COMMENT ON COLUMN user_preferences.user_id     IS '关联用户ID';
COMMENT ON COLUMN user_preferences.taste_prefs IS '口味偏好JSON数组，如["辣","甜","清淡"]';
COMMENT ON COLUMN user_preferences.budget_range IS '预算范围: low/medium/high/luxury';
COMMENT ON COLUMN user_preferences.travel_style IS '旅行风格: relaxed/adventure/balanced/cultural/foodie';
COMMENT ON COLUMN user_preferences.interests   IS '兴趣标签JSON数组，如["历史","自然","美食","摄影"]';

-- 用户偏好表索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences (user_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_travel_style ON user_preferences (travel_style);

-- =============================================================================
-- 旅行模块
-- =============================================================================

-- 旅行行程表
CREATE TABLE IF NOT EXISTS trips (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 行程ID
    creator_id      BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 创建者ID
    title           VARCHAR(200)    NOT NULL,                                             -- 行程标题
    destination     VARCHAR(200)    NOT NULL,                                             -- 目的地
    start_date      DATE            NOT NULL,                                             -- 出发日期
    end_date        DATE            NOT NULL,                                             -- 返回日期
    budget          DECIMAL(12,2)   NOT NULL DEFAULT 0.00,                                -- 预算总额
    status          VARCHAR(20)     NOT NULL DEFAULT 'draft',                             -- 状态: draft/planning/confirmed/in_progress/completed/cancelled
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),                                -- 创建时间
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 更新时间
);

-- 旅行行程表注释
COMMENT ON TABLE  trips                     IS '旅行行程表';
COMMENT ON COLUMN trips.id                  IS '行程ID，自增主键';
COMMENT ON COLUMN trips.creator_id          IS '行程创建者用户ID';
COMMENT ON COLUMN trips.title               IS '行程标题';
COMMENT ON COLUMN trips.destination         IS '旅行目的地';
COMMENT ON COLUMN trips.start_date          IS '出发日期';
COMMENT ON COLUMN trips.end_date            IS '返回日期';
COMMENT ON COLUMN trips.budget              IS '预算总额（元）';
COMMENT ON COLUMN trips.status              IS '行程状态: draft/planning/confirmed/in_progress/completed/cancelled';
COMMENT ON COLUMN trips.created_at          IS '行程创建时间';
COMMENT ON COLUMN trips.updated_at          IS '行程最后更新时间';

-- 行程表索引
CREATE INDEX IF NOT EXISTS idx_trips_creator_id ON trips (creator_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips (status);
CREATE INDEX IF NOT EXISTS idx_trips_dates ON trips (start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_trips_destination ON trips (destination);
CREATE INDEX IF NOT EXISTS idx_trips_created_at ON trips (created_at DESC);

-- 行程表约束
ALTER TABLE trips ADD CONSTRAINT chk_trips_dates
    CHECK (end_date >= start_date);
ALTER TABLE trips ADD CONSTRAINT chk_trips_budget
    CHECK (budget >= 0);
ALTER TABLE trips ADD CONSTRAINT chk_trips_status
    CHECK (status IN ('draft', 'planning', 'confirmed', 'in_progress', 'completed', 'cancelled'));

-- 行程成员表
CREATE TABLE IF NOT EXISTS trip_members (
    id          BIGSERIAL       PRIMARY KEY,                                          -- 成员记录ID
    trip_id     BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    user_id     BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 关联用户ID
    role        VARCHAR(20)     NOT NULL DEFAULT 'member',                             -- 角色: owner/admin/member/viewer
    joined_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 加入时间
);

-- 行程成员表注释
COMMENT ON TABLE  trip_members              IS '行程成员表';
COMMENT ON COLUMN trip_members.id           IS '成员记录ID';
COMMENT ON COLUMN trip_members.trip_id      IS '关联行程ID';
COMMENT ON COLUMN trip_members.user_id      IS '关联用户ID';
COMMENT ON COLUMN trip_members.role         IS '成员角色: owner/admin/member/viewer';
COMMENT ON COLUMN trip_members.joined_at    IS '加入行程时间';

-- 行程成员表索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_trip_members_trip_user ON trip_members (trip_id, user_id);
CREATE INDEX IF NOT EXISTS idx_trip_members_user_id ON trip_members (user_id);

-- 行程成员表约束
ALTER TABLE trip_members ADD CONSTRAINT chk_trip_members_role
    CHECK (role IN ('owner', 'admin', 'member', 'viewer'));

-- =============================================================================
-- 活动与餐厅模块
-- =============================================================================

-- 活动表
CREATE TABLE IF NOT EXISTS activities (
    id          BIGSERIAL       PRIMARY KEY,                                          -- 活动ID
    trip_id     BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    day_index   INTEGER         NOT NULL DEFAULT 1,                                    -- 第几天（从1开始）
    sort_order  INTEGER         NOT NULL DEFAULT 0,                                    -- 当天排序序号
    name        VARCHAR(200)    NOT NULL,                                             -- 活动名称
    type        VARCHAR(50)     NOT NULL DEFAULT 'sightseeing',                       -- 类型: sightseeing/food/transport/hotel/entertainment/shopping/other
    location    VARCHAR(500)    NOT NULL DEFAULT '',                                   -- 地点名称
    lat         DECIMAL(10,7)   NULL,                                                 -- 纬度
    lng         DECIMAL(10,7)   NULL,                                                 -- 经度
    start_time  TIME            NULL,                                                 -- 开始时间
    end_time    TIME            NULL,                                                 -- 结束时间
    cost        DECIMAL(10,2)   NOT NULL DEFAULT 0.00,                                -- 费用
    options     JSONB           NOT NULL DEFAULT '[]'::JSONB,                          -- 备选方案JSON数组
    notes       TEXT            NOT NULL DEFAULT '',                                   -- 备注
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),                                -- 创建时间
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 更新时间
    CONSTRAINT chk_activities_day CHECK (day_index > 0),
    CONSTRAINT chk_activities_coords CHECK (
        (lat IS NULL AND lng IS NULL) OR
        (lat IS NOT NULL AND lng IS NOT NULL AND lat BETWEEN -90 AND 90 AND lng BETWEEN -180 AND 180)
    )
);

-- 活动表注释
COMMENT ON TABLE  activities                IS '行程活动表';
COMMENT ON COLUMN activities.id             IS '活动ID';
COMMENT ON COLUMN activities.trip_id        IS '关联行程ID';
COMMENT ON COLUMN activities.day_index      IS '行程第几天（从1开始）';
COMMENT ON COLUMN activities.sort_order     IS '当天活动排序序号';
COMMENT ON COLUMN activities.name           IS '活动名称';
COMMENT ON COLUMN activities.type           IS '活动类型: sightseeing/food/transport/hotel/entertainment/shopping/other';
COMMENT ON COLUMN activities.location       IS '活动地点名称';
COMMENT ON COLUMN activities.lat            IS '纬度坐标';
COMMENT ON COLUMN activities.lng            IS '经度坐标';
COMMENT ON COLUMN activities.start_time     IS '活动开始时间';
COMMENT ON COLUMN activities.end_time       IS '活动结束时间';
COMMENT ON COLUMN activities.cost           IS '活动费用（元）';
COMMENT ON COLUMN activities.options        IS '备选方案JSON数组';
COMMENT ON COLUMN activities.notes          IS '备注信息';

-- 活动表索引
CREATE INDEX IF NOT EXISTS idx_activities_trip_id ON activities (trip_id);
CREATE INDEX IF NOT EXISTS idx_activities_trip_day ON activities (trip_id, day_index, sort_order);
CREATE INDEX IF NOT EXISTS idx_activities_type ON activities (type);
CREATE INDEX IF NOT EXISTS idx_activities_location ON activities USING GIST (
    CASE WHEN lat IS NOT NULL THEN
        ST_MakePoint(lng, lat)
    END
);

-- 活动表约束
ALTER TABLE activities ADD CONSTRAINT chk_activities_type
    CHECK (type IN ('sightseeing', 'food', 'transport', 'hotel', 'entertainment', 'shopping', 'other'));
ALTER TABLE activities ADD CONSTRAINT chk_activities_cost
    CHECK (cost >= 0);

-- 餐厅表
CREATE TABLE IF NOT EXISTS restaurants (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 餐厅ID
    name            VARCHAR(200)    NOT NULL,                                             -- 餐厅名称
    address         VARCHAR(500)    NOT NULL DEFAULT '',                                   -- 地址
    lat             DECIMAL(10,7)   NULL,                                                 -- 纬度
    lng             DECIMAL(10,7)   NULL,                                                 -- 经度
    cuisine_type    VARCHAR(100)    NOT NULL DEFAULT '',                                   -- 菜系类型
    avg_price       DECIMAL(10,2)   NOT NULL DEFAULT 0.00,                                -- 人均消费
    rating          DECIMAL(3,2)    NOT NULL DEFAULT 0.00,                                -- 评分 (0.00-5.00)
    tags            JSONB           NOT NULL DEFAULT '[]'::JSONB,                          -- 标签JSON数组
    source          VARCHAR(50)     NOT NULL DEFAULT 'amap',                               -- 数据来源: amap/dianping/manual/other
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 创建时间
);

-- 餐厅表注释
COMMENT ON TABLE  restaurants                   IS '餐厅信息表';
COMMENT ON COLUMN restaurants.id                IS '餐厅ID';
COMMENT ON COLUMN restaurants.name              IS '餐厅名称';
COMMENT ON COLUMN restaurants.address           IS '餐厅地址';
COMMENT ON COLUMN restaurants.lat               IS '纬度坐标';
COMMENT ON COLUMN restaurants.lng               IS '经度坐标';
COMMENT ON COLUMN restaurants.cuisine_type      IS '菜系类型，如"川菜"、"粤菜"、"日料"';
COMMENT ON COLUMN restaurants.avg_price         IS '人均消费（元）';
COMMENT ON COLUMN restaurants.rating            IS '评分（0.00-5.00）';
COMMENT ON COLUMN restaurants.tags              IS '标签JSON数组，如["网红","必吃","老字号"]';
COMMENT ON COLUMN restaurants.source            IS '数据来源: amap/dianping/manual/other';

-- 餐厅表索引
CREATE INDEX IF NOT EXISTS idx_restaurants_cuisine ON restaurants (cuisine_type);
CREATE INDEX IF NOT EXISTS idx_restaurants_rating ON restaurants (rating DESC);
CREATE INDEX IF NOT EXISTS idx_restaurants_avg_price ON restaurants (avg_price);
CREATE INDEX IF NOT EXISTS idx_restaurants_location ON restaurants USING GIST (
    CASE WHEN lat IS NOT NULL THEN
        ST_MakePoint(lng, lat)
    END
);

-- 餐厅表约束
ALTER TABLE restaurants ADD CONSTRAINT chk_restaurants_rating
    CHECK (rating >= 0 AND rating <= 5);
ALTER TABLE restaurants ADD CONSTRAINT chk_restaurants_avg_price
    CHECK (avg_price >= 0);
ALTER TABLE restaurants ADD CONSTRAINT chk_restaurants_source
    CHECK (source IN ('amap', 'dianping', 'manual', 'other'));

-- =============================================================================
-- 费用与投票模块
-- =============================================================================

-- 费用记录表
CREATE TABLE IF NOT EXISTS expenses (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 费用ID
    trip_id         BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    payer_id        BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 付款人ID
    amount          DECIMAL(12,2)   NOT NULL,                                             -- 金额
    category        VARCHAR(50)     NOT NULL DEFAULT 'other',                             -- 分类: food/transport/hotel/entertainment/shopping/ticket/other
    description     VARCHAR(500)    NOT NULL DEFAULT '',                                   -- 描述
    split_rule      JSONB           NOT NULL DEFAULT '{"type":"equal"}'::JSONB,            -- 分摊规则JSON
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 创建时间
);

-- 费用记录表注释
COMMENT ON TABLE  expenses                  IS '费用记录表';
COMMENT ON COLUMN expenses.id               IS '费用记录ID';
COMMENT ON COLUMN expenses.trip_id          IS '关联行程ID';
COMMENT ON COLUMN expenses.payer_id         IS '付款人用户ID';
COMMENT ON COLUMN expenses.amount           IS '费用金额（元）';
COMMENT ON COLUMN expenses.category         IS '费用分类: food/transport/hotel/entertainment/shopping/ticket/other';
COMMENT ON COLUMN expenses.description      IS '费用描述';
COMMENT ON COLUMN expenses.split_rule       IS '分摊规则JSON，如{"type":"equal"}或{"type":"custom","shares":[{"user_id":1,"amount":50}]}';
COMMENT ON COLUMN expenses.created_at       IS '记录创建时间';

-- 费用记录表索引
CREATE INDEX IF NOT EXISTS idx_expenses_trip_id ON expenses (trip_id);
CREATE INDEX IF NOT EXISTS idx_expenses_payer_id ON expenses (payer_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses (category);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses (created_at DESC);

-- 费用记录表约束
ALTER TABLE expenses ADD CONSTRAINT chk_expenses_amount
    CHECK (amount > 0);
ALTER TABLE expenses ADD CONSTRAINT chk_expenses_category
    CHECK (category IN ('food', 'transport', 'hotel', 'entertainment', 'shopping', 'ticket', 'other'));

-- 投票表
CREATE TABLE IF NOT EXISTS votes (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 投票ID
    trip_id         BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    activity_id     BIGINT          NULL REFERENCES activities(id) ON DELETE SET NULL,     -- 关联活动ID（可选）
    user_id         BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 投票用户ID
    choice          VARCHAR(200)    NOT NULL,                                             -- 投票选择
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 投票时间
);

-- 投票表注释
COMMENT ON TABLE  votes                     IS '投票表';
COMMENT ON COLUMN votes.id                  IS '投票记录ID';
COMMENT ON COLUMN votes.trip_id             IS '关联行程ID';
COMMENT ON COLUMN votes.activity_id         IS '关联活动ID（可选，针对特定活动投票）';
COMMENT ON COLUMN votes.user_id             IS '投票用户ID';
COMMENT ON COLUMN votes.choice              IS '投票选择内容';
COMMENT ON COLUMN votes.created_at          IS '投票时间';

-- 投票表索引
CREATE INDEX IF NOT EXISTS idx_votes_trip_id ON votes (trip_id);
CREATE INDEX IF NOT EXISTS idx_votes_activity_id ON votes (activity_id);
CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_votes_trip_activity_user ON votes (trip_id, activity_id, user_id);

-- =============================================================================
-- 轨迹与协作模块
-- =============================================================================

-- 轨迹记录表
CREATE TABLE IF NOT EXISTS trajectories (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 轨迹ID
    trip_id         BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    user_id         BIGINT          NOT NULL REFERENCES users(id) ON DELETE CASCADE,       -- 记录用户ID
    recorded_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),                                -- 记录时间
    location        JSONB           NOT NULL,                                             -- 位置信息JSON {"lat": 30.5, "lng": 104.0, "accuracy": 10}
    speed           DECIMAL(8,2)    NOT NULL DEFAULT 0.00,                                -- 速度 (m/s)
    altitude        DECIMAL(8,2)    NULL                                                  -- 海拔高度 (m)
);

-- 轨迹记录表注释
COMMENT ON TABLE  trajectories              IS '用户轨迹记录表';
COMMENT ON COLUMN trajectories.id           IS '轨迹记录ID';
COMMENT ON COLUMN trajectories.trip_id      IS '关联行程ID';
COMMENT ON COLUMN trajectories.user_id      IS '记录用户ID';
COMMENT ON COLUMN trajectories.recorded_at  IS '记录时间戳';
COMMENT ON COLUMN trajectories.location     IS '位置信息JSON，格式: {"lat": 30.5, "lng": 104.0, "accuracy": 10}';
COMMENT ON COLUMN trajectories.speed        IS '移动速度（米/秒）';
COMMENT ON COLUMN trajectories.altitude     IS '海拔高度（米）';

-- 轨迹记录表索引
CREATE INDEX IF NOT EXISTS idx_trajectories_trip_id ON trajectories (trip_id);
CREATE INDEX IF NOT EXISTS idx_trajectories_user_id ON trajectories (user_id);
CREATE INDEX IF NOT EXISTS idx_trajectories_recorded_at ON trajectories (recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_trajectories_trip_user_time ON trajectories (trip_id, user_id, recorded_at DESC);

-- 轨迹记录表约束
ALTER TABLE trajectories ADD CONSTRAINT chk_trajectories_speed
    CHECK (speed >= 0);
ALTER TABLE trajectories ADD CONSTRAINT chk_trajectories_location
    CHECK (location ? 'lat' AND location ? 'lng');

-- 协作文档表
CREATE TABLE IF NOT EXISTS trip_collab_docs (
    id              BIGSERIAL       PRIMARY KEY,                                          -- 文档ID
    trip_id         BIGINT          NOT NULL REFERENCES trips(id) ON DELETE CASCADE,       -- 关联行程ID
    ydoc_bytes      BYTEA           NOT NULL DEFAULT '',                                   -- Yjs文档二进制数据
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()                                 -- 最后更新时间
);

-- 协作文档表注释
COMMENT ON TABLE  trip_collab_docs          IS '行程协作文档表（基于Yjs CRDT）';
COMMENT ON COLUMN trip_collab_docs.id       IS '文档ID';
COMMENT ON COLUMN trip_collab_docs.trip_id  IS '关联行程ID';
COMMENT ON COLUMN trip_collab_docs.ydoc_bytes IS 'Yjs文档状态二进制数据';
COMMENT ON COLUMN trip_collab_docs.updated_at IS '文档最后更新时间';

-- 协作文档表索引
CREATE UNIQUE INDEX IF NOT EXISTS idx_trip_collab_docs_trip_id ON trip_collab_docs (trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_collab_docs_updated_at ON trip_collab_docs (updated_at DESC);

-- =============================================================================
-- 触发器：自动更新 updated_at 字段
-- =============================================================================

-- 创建通用更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为各表添加更新时间触发器
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN SELECT unnest(ARRAY[
        'users',
        'user_preferences',
        'trips',
        'activities',
        'trip_collab_docs'
    ]) LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_%s_updated_at ON %I;
             CREATE TRIGGER trg_%s_updated_at
                 BEFORE UPDATE ON %I
                 FOR EACH ROW
                 EXECUTE FUNCTION update_updated_at_column();',
            tbl, tbl, tbl, tbl
        );
    END LOOP;
END;
$$;

-- =============================================================================
-- 初始数据（可选）
-- =============================================================================

-- 插入默认旅行风格枚举说明（供参考，非约束表）
-- budget_range: low(经济), medium(适中), high(高档), luxury(奢华)
-- travel_style: relaxed(休闲), adventure(冒险), balanced(均衡), cultural(人文), foodie(美食)
-- activity type: sightseeing(观光), food(美食), transport(交通), hotel(住宿), entertainment(娱乐), shopping(购物), other(其他)
-- expense category: food(餐饮), transport(交通), hotel(住宿), entertainment(娱乐), shopping(购物), ticket(门票), other(其他)

-- =============================================================================
-- 完成
-- =============================================================================
-- 所有表、索引、约束和触发器已创建完毕。
-- =============================================================================
