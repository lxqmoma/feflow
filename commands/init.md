---
description: 初始化 feflow 治理工作区。仅在需要持久化 Item、Memory、Evidence 时使用。
---

# /init

初始化当前项目的 feflow 治理工作区。

## 触发方式

```
/init
```

## 执行逻辑

1. 调用 `feflow:project-init` skill 执行初始化流程
2. project-init 会完成以下工作：
   - 创建 `.feflow/` 目录结构
   - 生成 `project/init-config.md` 初始化配置
   - 初始化 `.feflow/memory/` 目录
   - 初始化 `.feflow/items/` 目录
3. 初始化完成后输出项目状态概览

## 前置条件

- 当前目录为有效的项目目录（包含 `package.json` 或其他项目配置文件）

## 何时使用

适用于需要完整治理能力时：

- 持久化 Item
- 管理项目记忆
- 沉淀证据链
- 查看依赖关系或仪表盘

以下场景通常不需要先执行 `/init`：

- 只读理解仓库
- 架构或插件分析
- 普通总结和解释
- 很多 L1 小范围任务

## 幂等性

重复执行时：
- 若已初始化，提示当前状态并跳过
- 若部分初始化（目录存在但配置缺失），补全缺失部分
