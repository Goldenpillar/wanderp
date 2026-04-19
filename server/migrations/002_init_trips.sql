-- 002_init_trips.sql
-- 行程表初始化

-- 创建行程表
CREATE TABLE IF NOT EXISTS trips (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    destination VARCHAR(200),
    start_date  TIMESTAMP,
    end_date    TIMESTAMP,
    cover_image VARCHAR(500),
    status      VARCHAR(20)  DEFAULT 'draft' CHECK (status IN ('draft', 'planning', 'confirmed', 'completed', 'cancelled')),
    creator_id  BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    budget      DECIMAL(10,2) DEFAULT 0,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_trips_creator_id ON trips(creator_id);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_destination ON trips(destination);
CREATE INDEX idx_trips_deleted_at ON trips(deleted_at);
CREATE INDEX idx_trips_dates ON trips(start_date, end_date);

-- 创建行程成员表
CREATE TABLE IF NOT EXISTS trip_members (
    id         BIGSERIAL PRIMARY KEY,
    trip_id    BIGINT   NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    user_id    BIGINT   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role       VARCHAR(20) DEFAULT 'viewer' CHECK (role IN ('owner', 'editor', 'viewer')),
    joined_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(trip_id, user_id)
);

-- 创建索引
CREATE INDEX idx_trip_members_trip_id ON trip_members(trip_id);
CREATE INDEX idx_trip_members_user_id ON trip_members(user_id);

-- 创建活动表
CREATE TABLE IF NOT EXISTS activities (
    id          BIGSERIAL PRIMARY KEY,
    trip_id     BIGINT       NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    category    VARCHAR(50)  CHECK (category IN ('sightseeing', 'food', 'transport', 'accommodation', 'shopping', 'entertainment')),
    start_time  TIMESTAMP,
    end_time    TIMESTAMP,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    address     VARCHAR(500),
    cost        DECIMAL(10,2) DEFAULT 0,
    sort_order  INT          DEFAULT 0,
    day_index   INT          DEFAULT 1,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_activities_trip_id ON activities(trip_id);
CREATE INDEX idx_activities_category ON activities(category);
CREATE INDEX idx_activities_day ON activities(trip_id, day_index);
CREATE INDEX idx_activities_deleted_at ON activities(deleted_at);

-- 创建投票表
CREATE TABLE IF NOT EXISTS votes (
    id          BIGSERIAL PRIMARY KEY,
    activity_id BIGINT   NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    user_id     BIGINT   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(10) DEFAULT 'up' CHECK (type IN ('up', 'down')),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(activity_id, user_id)
);

-- 创建索引
CREATE INDEX idx_votes_activity_id ON votes(activity_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);
