# info-tech-io.github.io

Корпоративный портал организации InfoTech.io.

**Живой адрес:** https://info-tech-io.github.io

---

## Структура сайта

```
https://info-tech-io.github.io/
├── /                        ← корпоративный сайт (из info-tech/docs/)
└── /docs/
    ├── /docs/quiz/          ← документация Quiz Engine
    ├── /docs/hugo-templates/ ← документация Hugo Templates Framework
    ├── /docs/web-terminal/  ← документация Web Terminal
    └── /docs/info-tech-cli/ ← документация InfoTech CLI
```

---

## Как собирается сайт

Сборка выполняется в GitHub Actions через единый workflow:
`.github/workflows/deploy-github-pages.yml`

### Инструменты

| Инструмент | Версия | Роль |
|------------|--------|------|
| [Hugo](https://gohugo.io) | 0.148.0 extended | Генератор статических сайтов |
| [hugo-templates](https://github.com/info-tech-io/hugo-templates) | v0.3.0 | Build system: `build.sh` + `federated-build.sh` |
| [Compose theme](https://github.com/onweru/compose) | submodule в hugo-templates | Тема оформления |

### Источники контента

| Репозиторий | Что берётся | Куда попадает |
|-------------|-------------|---------------|
| [info-tech](https://github.com/info-tech-io/info-tech) | `docs/` | `/` (корпоративный сайт) |
| [quiz](https://github.com/info-tech-io/quiz) | `docs/` | `/docs/quiz/` |
| [hugo-templates](https://github.com/info-tech-io/hugo-templates) | `docs/` | `/docs/hugo-templates/` |
| [web-terminal](https://github.com/info-tech-io/web-terminal) | `docs/` | `/docs/web-terminal/` |
| [info-tech-cli](https://github.com/info-tech-io/info-tech-cli) | `docs/` | `/docs/info-tech-cli/` |

### Конфигурация федерации

- `configs/corporate-modules.json` — описывает сборку корпоративного сайта
- `configs/documentation-modules.json` — описывает сборку документации всех 4 продуктов

### Процесс сборки (каждый run)

```
1. Checkout hub-repo (этот репозиторий, для configs/)
2. Setup Hugo 0.148.0 extended
3. Clone hugo-templates (build system + Compose theme submodule)
4. Clone info-tech (корпоративный контент)
5. build.sh → corporate-build/         # корпоративный сайт
6. federated-build.sh → docs-build/    # документация 4 продуктов
7. merge: corporate-build/ + docs-build/ → final-site/
8. upload-pages-artifact + deploy-pages # атомарный деплой на GitHub Pages
```

---

## Как запускается деплой

### Автоматически — при обновлении контента в продуктовых репозиториях

Каждый продуктовый репозиторий содержит workflow `notify-hub.yml`, который при push в `main` с изменениями в `docs/**` отправляет `repository_dispatch` в этот репозиторий:

| Событие | Откуда |
|---------|--------|
| `quiz-docs-updated` | quiz при изменении `docs/**` |
| `hugo-templates-docs-updated` | hugo-templates при изменении `docs/**` |
| `web-terminal-docs-updated` | web-terminal при изменении `docs/**` |
| `cli-docs-updated` | info-tech-cli при изменении `docs/**` |
| `corporate-site-updated` | info-tech при изменении корпоративного контента |

### Вручную

GitHub Actions → Deploy GitHub Pages Federation → Run workflow

---

## Concurrency

Все запуски используют единую concurrency group `github-pages-federation`.
Параллельные деплои невозможны — исключает race condition при одновременных обновлениях нескольких продуктов.

---

## Секреты

| Secret | Назначение |
|--------|------------|
| `PAT_TOKEN` | Клонирование репозиториев организации при сборке |

`PAT_TOKEN` также должен быть установлен во всех продуктовых репозиториях — он используется в `notify-hub.yml` для отправки `repository_dispatch`.

---

## Производительность

- Время сборки: ~44–60 секунд
- Загрузка страниц: ~240 мс
