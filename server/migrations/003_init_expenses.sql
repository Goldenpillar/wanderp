-- 003_init_expenses.sql
-- 消费记录表初始化

-- 创建消费记录表
CREATE TABLE IF NOT EXISTS expenses (
    id           BIGSERIAL PRIMARY KEY,
    trip_id      BIGINT        NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    user_id      BIGINT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category     VARCHAR(50)   NOT NULL CHECK (category IN ('food', 'transport', 'accommodation', 'ticket', 'shopping', 'other')),
    amount       DECIMAL(10,2) NOT NULL,
    currency     VARCHAR(10)   DEFAULT 'CNY',
    description  VARCHAR(500),
    pay_method   VARCHAR(50)   CHECK (pay_method IN ('cash', 'card', 'wechat', 'alipay')),
    payer_id     BIGINT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    latitude     DOUBLE PRECISION,
    longitude    DOUBLE PRECISION,
    photo_url    VARCHAR(500),
    expense_time TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    deleted_at   TIMESTAMP
);

-- 创建索引
CREATE INDEX idx_expenses_trip_id ON expenses(trip_id);
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_payer_id ON expenses(payer_id);
CREATE INDEX idx_expenses_expense_time ON expenses(expense_time);
CREATE INDEX idx_expenses_deleted_at ON expenses(deleted_at);
