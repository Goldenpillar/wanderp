# WanderP 项目开发日志 — 回归验证记录

> 本文档记录每个开发阶段的回归验证结果，确保实现与设计文档保持一致。

---

## 回归 #1 — 项目骨架创建（2026-04-19）

### 验证范围
对照设计文档（v1.0）第6章技术架构，验证项目骨架的完整性。

### 验证结果总览

| 检查维度 | 结果 | 说明 |
|---------|------|------|
| 1. 项目结构完整性 | ✅ 通过 | 三端（Flutter/Go/Python）结构完整，7个基础设施全部配置 |
| 2. 技术选型一致性 | ✅ 通过 | Flutter 8项、Go 7项、Python 7项关键依赖全部匹配 |
| 3. 数据模型一致性 | ✅ 已修复 | 初始发现3个不一致问题，已全部修复 |
| 4. API端点完整性 | ✅ 通过 | OpenAPI定义覆盖全部6大功能模块，30+端点 |
| 5. 外部服务集成 | ✅ 通过 | 5个外部服务均有完整封装 |
| 6. 关键算法实现 | ✅ 已修复 | OR-Tools每日预算约束已补充实现 |
| 7. 部署配置 | ✅ 通过 | docker-compose包含全部13个服务 |

### 创建的文件统计

| 子项目 | 文件数 | 说明 |
|--------|--------|------|
| client/ (Flutter) | 66 | 完整的客户端骨架，含16个页面、5组BLoC、7个Service |
| server/ (Go) | 58 | 5个微服务入口、公共包、OpenAPI定义、数据库迁移 |
| ai-engine/ (Python) | 40 | FastAPI服务、4个AI引擎模块、6个外部服务封装 |
| 根目录 | 8 | docker-compose、Makefile、README、init-db.sql |
| **合计** | **172** | |

### 发现并修复的问题

#### 问题1: Activity.options 字段三端不一致 ✅ 已修复
- **现象**: 数据库有 `options JSONB` 列，Flutter和Go模型缺失
- **修复**: Flutter添加 `ActivityOption` 类和 `options` 字段；Go添加 `Options datatypes.JSON` 字段

#### 问题2: Preference 字段命名不一致 ✅ 已修复
- **现象**: taste_prefs / foodPreferences / FoodType / food_type 四种命名
- **修复**: 统一为 `taste_prefs`（数据库列名）/ `tastePrefs`（代码驼峰命名）

#### 问题3: 两套数据库Schema重叠 ✅ 已修复
- **现象**: init-db.sql 和 migrations/ 表结构有差异
- **修复**: 标记 migrations/ 为 deprecated，统一使用 scripts/init-db.sql

#### 问题4: OR-Tools每日预算约束未实现 ✅ 已修复
- **现象**: constraint_solver.py 中约束2代码为 `pass`
- **修复**: 实现完整的每日预算约束建模（按天分组、费用累加、约束添加）

### 观察与备注

1. **架构一致性高**: 项目骨架与设计文档的技术架构图高度吻合，三端分层清晰
2. **API覆盖全面**: OpenAPI定义了30+端点，覆盖设计文档中所有P0功能
3. **AI引擎深度**: LLM Prompt模板、OR-Tools约束建模、RAG混合检索、偏好聚合算法均有实质性代码骨架
4. **部署配置专业**: docker-compose包含完整的13服务编排，含健康检查和依赖关系
5. **后续关注点**:
   - Flutter项目需要实际运行环境（Flutter SDK）才能编译验证
   - Go项目需要Go编译器才能构建
   - 外部API Key需要实际申请才能联调
   - Milvus向量数据库的知识库需要实际数据导入

---

## 回归 #2 — [待填写]

### 验证范围

（下一个开发阶段完成后填写）

### 验证结果

（待填写）
