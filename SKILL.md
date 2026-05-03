---
name: wechat-radar
description: 微信公众号智能雷达 — 自动抓取公众号文章，AI 多维度评分，过滤低质量内容，返回高质量文章列表。
version: 1.0.0
---

# 微信公众号文章雷达 (wechat-radar)

AI 驱动的微信公众号智能日报。自动抓取、多维度评分、个性化推荐。

> 每天从几十个公众号中，帮你筛出最值得读的几篇。

## 功能特性

- **公众号监控** — 自动抓取新文章（默认 24 小时内）
- **智能过滤** — 规则预过滤广告 + 跨源去重 + AI 多维度评分
- **个性化推荐** — 基于你的背景和兴趣定制评分排序
- **多渠道推送** — 飞书 / 钉钉 / 企业微信 / 邮件 / Telegram / Bark / Server酱 / PushPlus
- **多模型支持** — Anthropic / OpenAI / DeepSeek / 通义千问 / 硅基流动 / Ollama 等 12+
- **评分日志** — 完整保留所有文章评分，供持续调优

## 安装

### 方式一：Hermes Skill 一键安装（推荐）

如果你使用 [Hermes Agent](https://github.com/cathyzhang0905/hermes-agent)，可以直接安装为 skill：

```bash
# 1. 克隆仓库到本地
git clone https://github.com/Jun-Zhang-32108/wechat-radar-skill.git ~/projects/wechat-radar-skill

# 2. 一键安装到 Hermes skill 目录
cd ~/projects/wechat-radar-skill
./install-skill.sh
```

脚本会自动：
- 创建 `~/.hermes/skills/wechat-radar` 目录
- 复制所有必要的 Python 文件和配置文件
- 处理权限问题
- 提示下一步配置步骤

### 方式二：独立使用

不依赖 Hermes，直接作为独立工具使用：

```bash
git clone https://github.com/Jun-Zhang-32108/wechat-radar-skill.git
cd wechat-radar-skill
./setup.sh
```

脚本会自动：安装依赖 → 引导选择 AI 模型 → 配置推送渠道 → 扫码登录 → 测试运行。

## 前置要求

1. **Python 3.10+**（需要 f-string、match 语句等新特性）
2. **微信公众号账号**：需要一个微信公众号（免费的个人订阅号即可）。前往 [微信公众平台](https://mp.weixin.qq.com/) 注册，用个人微信即可完成，无需企业资质。
3. **AI 模型 API Key**：OpenAI / DeepSeek / 硅基流动等任一服务商的 API Key

## 快速开始

### 1. 扫码登录

首次使用需要扫码获取微信 token（有效期约 3 天）：

```bash
cd ~/projects/wechat-radar-skill
source .venv/bin/activate
python3 main.py --login
```

按照终端提示扫码即可。token 会自动保存到 `token.json`。

### 2. 检查 Token 状态

```bash
python3 skill_adapt.py check-token
```

### 3. 运行拉取 + 评分

**默认运行**（读取项目目录下的 `config.yaml`）：

```bash
python3 skill_adapt.py run
```

指定自定义配置：

```bash
python3 skill_adapt.py run --config /path/to/custom_config.yaml
```

试运行（不推送，仅输出 JSON）：

```bash
python3 main.py --dry-run
```

## 配置说明

所有配置集中在 `config.yaml`，主要配置项：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `accounts` | 监控的公众号列表 | 48 个精选账号 |
| `fetch.hours` | 抓取最近 N 小时内的文章 | 24 |
| `scoring.min_score` | 推送最低分（1-10） | 5 |
| `scoring.top_n` | 每次最多推送篇数 | 20 |
| `ai.provider` | AI 模型服务商 | openrouter |
| `ai.model` | 具体模型名 | qwen/qwq-32b |

完整的配置说明请参考仓库中的 `config.yaml` 和 `.env.example`。

## 在 Hermes 中使用

安装为 skill 后，可以直接在 Hermes 对话中使用：

```
用户：帮我看看机器之心最近有什么值得读的文章
Hermes: [自动调用 wechat-radar skill 拉取并评分]
```

## 故障排查

**1. 缺少依赖（`No module named 'bs4'`）**
```bash
pip install beautifulsoup4 lxml pyyaml
```

**2. Token 过期**
Token 有效期约 72 小时，过期后重新运行 `python3 main.py --login` 扫码即可。

**3. AI 评分返回 401**
检查 `.env` 中对应 provider 的 API key 是否设置正确。

**4. 文章缓存损坏**
删除缓存后重跑：`rm article_cache.json`

## 项目结构

```
wechat-radar/
├── main.py          主入口
├── skill_adapt.py   Skill 适配层（Hermes 调用入口）
├── config.yaml      所有可配置项
├── fetcher.py       微信 API 拉取 + 缓存
├── filter.py        AI 多维度评分 + 开场白生成
├── prefilter.py     规则预过滤
├── dedup.py         跨源去重
├── notifier.py      多渠道推送
├── auth.py          微信扫码登录 / token 管理
├── setup.sh         一键安装配置脚本
└── requirements.txt 依赖列表
```

## License

MIT

## About

Built by **Cathy** ([@cathyzhang0905](https://github.com/cathyzhang0905))
