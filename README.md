# CC Sync - Claude Code 多电脑配置同步

通过 GitHub 在多台电脑之间同步 Claude Code 的配置和项目文件。

## 目录结构

```
CC/
├── CLAUDE.md                    # 项目说明（CC 读取）
├── .claude/                     # 项目级 CC 配置
│   └── settings.json
├── shared-claude-config/        # 跨机器全局配置
│   ├── settings.json            # 共享的全局设置
│   ├── keybindings.json         # 键盘快捷键
│   ├── memory/                  # 持久化记忆
│   ├── scheduled-tasks/         # 定时任务
│   ├── sync.ps1                 # Windows 同步脚本
│   └── sync.sh                  # macOS/Linux 同步脚本
└── .gitignore
```

## 新电脑设置

### 1. 克隆仓库

```bash
git clone <your-repo-url> CC
cd CC
```

### 2. 运行同步脚本

**Windows (PowerShell):**
```powershell
.\shared-claude-config\sync.ps1
```

**macOS / Linux:**
```bash
chmod +x shared-claude-config/sync.sh
./shared-claude-config/sync.sh
```

### 3. 日常使用

修改配置后，commit & push 即可同步到其他电脑：

```bash
git add -A
git commit -m "更新配置"
git push
```

其他电脑上 pull 后重新运行同步脚本即可生效。

## 不同步的内容

以下内容不会被同步（已在 .gitignore 中排除）：
- 会话记录 (`sessions/`)
- 遥测数据 (`telemetry/`)
- 备份 (`backups/`)
- 机器相关设置 (`settings.local.json`)
- 凭证 (`credentials.json`)
