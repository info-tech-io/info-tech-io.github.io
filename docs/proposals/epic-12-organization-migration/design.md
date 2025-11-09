# Epic #12: Миграция организации info-tech-io → info-tech

**Issue**: https://github.com/info-tech-io/info-tech-io.github.io/issues/12
**Статус**: 🔄 IN PROGRESS
**Создан**: 2025-11-07
**Тип**: Epic Issue

---

## 🎯 Цель и Обоснование

### Проблема
Текущее название организации `info-tech-io` создает избыточность в URL и брендинге:
- Длинные URL: `https://github.com/info-tech-io/repo`
- Несоответствие домену: `infotecha.ru` vs `info-tech-io`
- Потенциальная путаница для пользователей

### Цель
Переименование GitHub организации в `info-tech` для:
- 🎯 Упрощения брендинга и URL
- 🎯 Соответствия основному домену проекта
- 🎯 Единообразия с корпоративным стилем

---

## 🚨 Критический Анализ Рисков

### 🔴 Высокий риск

#### 1. GitHub Pages Domain (info-tech-io.github.io)
- **Риск**: Домен `info-tech-io.github.io` автоматически станет `info-tech.github.io`
- **Последствие**: Все внешние ссылки на документацию дадут 404
- **Критичность**: МАКСИМАЛЬНАЯ - потеря доступа к документации

#### 2. Federated Documentation URLs
- **Риск**: Внутренние ссылки между продуктами сломаются
- **Файлы**: Все `/docs/` директории в продуктовых репозиториях
- **Последствие**: Нарушение навигации в документации

#### 3. CI/CD Repository Dispatch Events
- **Риск**: Workflows с хардкоженными ссылками на `info-tech-io`
- **Файлы**: `.github/workflows/*notify*` во всех репозиториях
- **Последствие**: Остановка автоматического деплоя

### 🟡 Средний риск

#### 4. External References
- **Риск**: Внешние сайты со ссылками на GitHub репозитории
- **Последствие**: 404 ошибки для внешних пользователей
- **Зона влияния**: README badges, документация в других проектах

#### 5. Local Git Remotes
- **Риск**: Все локальные клоны будут иметь неправильный remote URL
- **Последствие**: Push/pull операции завершатся с ошибкой
- **Решение**: Автоматическая настройка через git remote

### 🟢 Низкий риск

#### 6. GitHub Actions Marketplace
- **Риск**: Опубликованные действия потеряют связь
- **Статус**: В организации нет опубликованных actions
- **Решение**: Не требуется

---

## 🏗️ Архитектурная Стратегия

### Подход: Staged Migration

1. **Pre-migration**: Подготовка redirects и fallbacks
2. **Migration**: Быстрое переименование организации
3. **Post-migration**: Обновление всех ссылок и конфигураций
4. **Validation**: Проверка работоспособности всех компонентов

### Key Principles

- **Zero-downtime**: Минимизация простоя сервисов
- **Rollback-ready**: Возможность отката при критических проблемах
- **Evidence-based**: Документирование каждого шага
- **Communication**: Уведомление пользователей о изменениях

---

## 📋 High-Level Implementation Plan

### Epic Structure

```
Epic #12: Organization Migration
├── Child #1: Dependencies Analysis & Risk Assessment (2-3 дня)
├── Child #2: Pre-migration Preparation (2-3 дня)
├── Child #3: GitHub Organization Migration (1 день)
├── Child #4: Post-migration Updates (3-4 дня)
├── Child #5: Testing & Validation (2-3 дня)
└── Child #6: Production Deployment & Monitoring (1-2 дня)
```

### Estimated Timeline
**Общая продолжительность**: 11-16 рабочих дней
**Критический период**: Child #3 (день миграции)

---

## 🔄 Child Issues Breakdown

### Child #1: Dependencies Analysis & Risk Assessment
**Цель**: Полная инвентаризация всех зависимостей от имени организации

**Dependency Counting Methodology**:
- **Total Dependencies**: 21 organization references identified
  - **GitHub Pages Federation**: 9 dependencies (info-tech-io.github.io domain)
  - **Repository Dispatch Network**: 10 dependencies (CI/CD workflows)
  - **ИНФОТЕКА Production**: 2 dependencies (независимые ссылки)
- **Implementation Files**: 16 files contain these dependencies
- **Note**: Some files contain multiple dependency types, explaining the difference between total dependencies (21) and affected files (16)

**Deliverables**:
- Полный список файлов с упоминаниями `info-tech-io`
- Категоризация по критичности и типу обновления
- Risk assessment matrix с планом mitigation
- Communication план для пользователей

### Child #2: Pre-migration Preparation
**Цель**: Подготовка инфраструктуры для smooth migration

**Deliverables**:
- Backup критических конфигураций
- Подготовка redirect rules (если возможно)
- Обновление документации с migration notes
- Coordination план с GitHub Support

### Child #3: GitHub Organization Migration
**Цель**: Выполнение переименования организации

**Deliverables**:
- Координация с GitHub для переименования
- Immediate validation базовой функциональности
- Emergency rollback план в случае критических проблем

### Child #4: Post-migration Updates
**Цель**: Обновление всех ссылок и конфигураций

**Deliverables**:
- Обновление всех internal links
- Fix CI/CD workflows
- Обновление git remotes в рабочих копиях
- Documentation updates

### Child #5: Testing & Validation
**Цель**: Комплексная проверка работоспособности

**Deliverables**:
- E2E тестирование всех workflows
- Validation федеративной документации
- Performance проверки
- User acceptance testing

### Child #6: Production Deployment & Monitoring
**Цель**: Финальный запуск и мониторинг стабильности

**Deliverables**:
- Production deployment обновлений
- Monitoring setup для отслеживания 404s
- User communication о completed migration
- Post-migration health report

---

## 📊 Risk Mitigation Strategies

### Strategy 1: GitHub Redirects
**Идея**: GitHub автоматически создает redirects при переименовании
**Применимость**: Репозитории - ДА, GitHub Pages - НЕТ
**Покрытие**: ~70% ссылок

### Strategy 2: Custom Domain Preservation
**Идея**: Использование custom domain для GitHub Pages
**Применимость**: Требует настройки DNS
**Покрытие**: 100% для GitHub Pages

### Strategy 3: Fallback Documentation
**Идея**: Временное дублирование критической документации
**Применимость**: Manual process
**Покрытие**: Critical paths only

### Strategy 4: Communication Campaign
**Идея**: Упреждающее уведомление пользователей
**Применимость**: README, announcements
**Покрытие**: Active users

---

## 🎛️ Emergency Procedures

### Rollback Criteria
Немедленный rollback если:
- GitHub Pages полностью недоступен > 30 минут
- CI/CD workflows failing > 50%
- Critical data loss обнаружена

### Rollback Process
1. Контакт с GitHub Support для обратного переименования
2. Восстановление backup конфигураций
3. Emergency communication пользователям
4. Post-incident анализ

### Escalation Path
1. **L1**: Internal team coordination
2. **L2**: GitHub Support engagement
3. **L3**: Public communication & temporary workarounds

---

## 📝 Success Criteria

### ✅ Must Have
- [ ] Все GitHub Pages доступны по новому домену
- [ ] CI/CD workflows работают без ошибок
- [ ] Federated documentation навигация работает
- [ ] Нет data loss или corruption

### ✅ Should Have
- [ ] Внешние ссылки redirected корректно
- [ ] User documentation обновлена
- [ ] Performance не снизилось
- [ ] SEO ranking не пострадал значительно

### ✅ Could Have
- [ ] Custom domain настроен для GitHub Pages
- [ ] Legacy redirect handling
- [ ] Analytics для tracking adoption новых URLs

---

## 📚 References

- **GitHub Docs**: [Renaming an organization](https://docs.github.com/en/organizations/managing-organization-settings/renaming-an-organization)
- **GitHub Pages**: [Managing custom domains](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- **InfoTech Workflow**: https://github.com/info-tech-io/info-tech/blob/main/docs/content/open-source/issue-commit-workflow.md

---

**Последнее обновление**: 2025-11-07 10:30 UTC
**Следующий review**: После создания Child #1 Issue