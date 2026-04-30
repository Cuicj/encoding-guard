# Encoding Guard v1.0.0

## English

Initial public release of Encoding Guard.

### Highlights

- Detects UTF-8 BOM markers
- Detects replacement characters such as `U+FFFD`
- Checks whether files are locally modified in Git or SVN
- Refuses to rewrite modified files unless explicitly overridden
- Creates backups before rewriting by default
- Generates Markdown reports for review and sharing

### Included

- Codex plugin manifest
- Codex skill entry
- PowerShell scan, report, and safe normalization scripts
- Local marketplace example
- English and Simplified Chinese documentation

### Release Asset

- `encoding-guard-1.0.0.zip`

### Installation

Unpack the release into:

```text
plugins/encoding-guard/
```

Make sure this file exists after extraction:

```text
plugins/encoding-guard/.codex-plugin/plugin.json
```

---

## 简体中文

Encoding Guard 首个公开发布版本。

### 主要能力

- 检测 UTF-8 BOM
- 检测替换字符，例如 `U+FFFD`
- 检查文件是否在 Git 或 SVN 中已被本地修改
- 默认拒绝改写已修改文件，除非显式覆盖
- 改写前默认创建备份
- 支持生成 Markdown 报告，便于审查和共享

### 包含内容

- Codex 插件清单
- Codex 技能入口
- PowerShell 扫描、报告与安全规范化脚本
- 本地 marketplace 示例
- 英文与简体中文文档

### 发布附件

- `encoding-guard-1.0.0.zip`

### 安装方式

将压缩包解压到：

```text
plugins/encoding-guard/
```

并确认解压后存在：

```text
plugins/encoding-guard/.codex-plugin/plugin.json
```
