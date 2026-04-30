# Encoding Guard

[English](./README.md) | 简体中文

Encoding Guard 是一个 Codex 插件，用来检测仓库中的编码风险，并在安全前提下将文本文件规范化为 UTF-8 无 BOM。

它适合处理这些场景：仓库里可能存在 BOM、乱码、替换字符、历史编码损坏，或者 Git / SVN 工作区里同时存在未提交修改。

## 功能特性

- 检测 UTF-8 BOM
- 检测替换字符，例如 `U+FFFD`
- 检查文件是否在 Git 或 SVN 中已被本地修改
- 默认拒绝改写已修改文件，除非显式传入覆盖参数
- 改写前默认创建备份
- 支持生成 Markdown 报告，便于审查和共享

## 仓库结构

```text
.codex-plugin/plugin.json         插件清单
skills/encoding-guard/SKILL.md    Codex 技能入口
scripts/encoding_scan.ps1         编码扫描脚本
scripts/encoding_report.ps1       Markdown 报告脚本
scripts/encoding_fix_safe.ps1     安全规范化脚本
scripts/package_plugin.ps1        发布打包脚本
```

## 安全策略

Encoding Guard 采用保守策略：

- 先扫描，再改写
- 对已修改文件，除非显式传入 `-ForceModified`，否则拒绝改写
- 除非显式传入 `-NoBackup`，否则默认生成备份
- 替换字符会被视为已损坏内容的信号，只报告，不宣称自动修复

## 使用方式

扫描仓库：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_scan.ps1 C:\repo
```

生成 Markdown 报告：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_report.ps1 C:\repo -OutFile .\encoding-report.md
```

安全规范化单个文件：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_fix_safe.ps1 C:\repo\src\File.java
```

强制处理本地已修改文件：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\encoding_fix_safe.ps1 C:\repo\src\File.java -ForceModified
```

## 作为本地插件安装

1. 将插件目录放到 `plugins/encoding-guard`
2. 确认 `.codex-plugin/plugin.json` 存在
3. 重新加载 Codex 或重启应用

如果你使用本地 marketplace 方式加载，请参考 [PUBLISHING.md](./PUBLISHING.md)。

## 构建发布包

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package_plugin.ps1
```

执行后会生成：

- `dist/encoding-guard/`
- `dist/encoding-guard-1.0.0.zip`

## 相关文档

- [PUBLISHING.md](./PUBLISHING.md)
- [PRIVACY.md](./PRIVACY.md)
- [TERMS.md](./TERMS.md)

## 许可证

本项目基于 [MIT License](./LICENSE) 发布。
