# org 部署统一入口
#   make setup   — 全量部署(install + crons + doctor 自检)
#   make install — 静态配置(org/skill symlink、hook、CLAUDE.md)
#   make crons   — 定时任务(日报/周报)
#   make doctor  — 健康检查(5 层配置)

.PHONY: setup install crons doctor

setup: install crons doctor

install:
	./install.sh

crons:
	./cron-jobs.sh

doctor:
	./doctor.sh
