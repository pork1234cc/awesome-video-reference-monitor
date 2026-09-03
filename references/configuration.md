# 配置说明

项目只读取根目录 `.env`，或 CLI `--env-file` 指向的项目内文件。进程环境中的同名变量优先；禁止从其他项目读取配置。

## 基础配置

```env
TIKHUB_API_KEY=your_tikhub_api_key
ARTICLEMONITOR_STORAGE_BACKEND=local
```

`ARTICLEMONITOR_STORAGE_BACKEND` 只能是 `local` 或 `feishu`，未配置时默认 `local`。

- `local`：账号清单固定保存在项目 `1-对标账号/accounts.md`。
- `feishu`：账号只保存在飞书账号表；项目不读取或写入 `accounts.md`。

## 飞书模式配置

```env
ARTICLEMONITOR_STORAGE_BACKEND=feishu
FEISHU_APP_ID=cli_your_app_id
FEISHU_APP_SECRET=your_app_secret
FEISHU_APP_TOKEN=your_bitable_app_token
DUIBIAO_TABLE_ID=tbl_your_account_table
FEISHU_REFERENCE_TABLE_ID=tbl_your_case_table
```

飞书应用需要多维表格读写权限。两个表 ID 必须属于用户自己的多维表格应用：

- 账号表：主字段 `序号`（文本）；另需 `作者`（文本）、`平台`（单选，包含“抖音”“视频号”）、`账号标识`（文本）、`API查询ID`（文本）、`登记作品链接`（超链接）、`记录时间`（日期）。首次登记会自动创建缺失的非主字段。
- 案例表：主字段 `案例`（文本）；另需 `案例 ID`（文本）、`采集时间`（日期）、`原始链接`（超链接）、`平台`（单选，包含 `douyin`、`wechat_channels`）、`作者`（文本）、`书名`（文本）、`标题/描述`（文本）、`话题`（多选）、`点赞`、`收藏`、`评论`、`转发`（数字）、`时长`（文本）、`清洗逐字稿`（文本）。案例表字段不会自动创建，缺失或类型错误时停止同步。

## 监控新增素材额外配置

```env
DASHSCOPE_API_KEY=sk-your_dashscope_api_key
DASHSCOPE_ASR_WORKSPACE_ID=your_workspace_id
DASHSCOPE_ASR_BASE_URL=https://{WorkspaceId}.cn-beijing.maas.aliyuncs.com/compatible-mode/v1
DASHSCOPE_ASR_REGION=cn-beijing
DASHSCOPE_ASR_MODEL=qwen3-asr-flash
DASHSCOPE_ASR_LANGUAGE=zh
DASHSCOPE_ASR_ENABLE_ITN=false
```

监控还要求 FFmpeg 和 FFprobe 位于 `PATH`，或分别配置 `FFMPEG_PATH`、`FFPROBE_PATH`。

视频号新素材还要求：

- Node.js 20+
- `scripts/wechat-decrypt/node_modules/` 已安装
- Playwright Chromium 已安装
- Node 不在 `PATH` 时配置 `WECHAT_DECRYPT_NODE_PATH`

`.env` 包含密钥，不得提交、打印、写入 Markdown 或复制到其他目录。Skill 不得替用户创建飞书应用、修改权限或猜测表 ID。
