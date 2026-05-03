"""
skill_adapt.py - wechat-radar Skill 适配层 CLI

用法:
  python3 skill_adapt.py check-token           # 检查 token 是否有效
  python3 skill_adapt.py run                   # 拉取→评分→输出 JSON（默认读取项目目录 config.yaml）
  python3 skill_adapt.py run --config xxx.yaml # 指定配置文件运行
"""
import argparse
import json
import logging
import sys
from pathlib import Path

import yaml

from auth import load_token, is_token_valid
from main import run_skill_mode

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("skill_adapt")

SCRIPT_DIR = Path(__file__).parent


def cmd_check_token():
    """检查本地 token.json 是否有效，输出 JSON 状态。"""
    token_data = load_token()
    valid = is_token_valid(token_data)
    result = {
        "valid": valid,
        "has_token": token_data is not None,
        "expiry": token_data.get("expiry_timestamp") if token_data else None,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if valid else 1


def cmd_run(config_path: str = None, test_mode: bool = False):
    """读取配置和 token，执行 skill 模式，输出 JSON 结果到 stdout。

    如果未指定 config_path，则默认读取项目目录下的 config.yaml（或优先使用 config.yaml.local）。
    """
    if config_path:
        config_file = Path(config_path)
    else:
        # 默认读取项目目录下的 config.yaml.local（优先）或 config.yaml
        local_cfg = SCRIPT_DIR / "config.yaml.local"
        config_file = local_cfg if local_cfg.exists() else SCRIPT_DIR / "config.yaml"

    if not config_file.exists():
        logger.error(f"Config file not found: {config_file}")
        print(json.dumps({"error": f"Config file not found: {config_file}"}, ensure_ascii=False))
        return 1

    config = yaml.safe_load(config_file.read_text(encoding="utf-8"))

    token_data = load_token()
    if not is_token_valid(token_data):
        logger.error("Token missing or expired. Please login first.")
        print(json.dumps({"error": "Token missing or expired"}, ensure_ascii=False))
        return 1

    articles = run_skill_mode(config, token_data, test_mode=test_mode)

    # 输出 JSON（Hermes 通过 stdout 捕获）
    output = {
        "success": True,
        "article_count": len(articles),
        "articles": articles,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0


def main():
    parser = argparse.ArgumentParser(description="WeChat Radar - Skill Adapter")
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("check-token", help="Check if local token is valid")

    run_parser = sub.add_parser("run", help="Run fetch+score and output JSON")
    run_parser.add_argument(
        "--config",
        required=False,
        help="Path to config.yaml (default: project_dir/config.yaml.local or config.yaml)",
    )
    run_parser.add_argument("--test", action="store_true", help="Test mode (1 article per account)")

    args = parser.parse_args()

    if args.command == "check-token":
        sys.exit(cmd_check_token())
    elif args.command == "run":
        sys.exit(cmd_run(args.config, test_mode=args.test))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
