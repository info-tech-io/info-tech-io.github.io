# Stage 2: Replace Custom Logic with Hugo Templates Framework

**Objective**: Заменить кастомную логику workflow на использование Hugo Templates Framework
**Duration**: 0.5 days (4 hours)
**Dependencies**: Stage 1 (reproduction completed)

---

## Overview

**ОБНОВЛЕНО**: После анализа failed runs, корневая проблема в интеграции с Hugo Templates Framework.

**Проблема**: Hugo Templates Framework с флагом `--preserve-base-site` пытается скачать базовый сайт
через `wget https://info-tech-io.github.io`, но получает ошибки (rate limiting, временные сбои).

**Но у нас уже есть скачанное состояние** в `current-site` (Phase 1 workflow)!

**Правильное решение**: Настроить Hugo Templates Framework для использования уже скачанного `current-site`
как local source для базового сайта вместо попыток wget URL.

**Ключевые изменения**:
1. Использовать local source type для базового сайта в preserve-base-site стратегии
2. Передать path к current-site директории вместо URL
3. Убедиться что federated-build.sh корректно обрабатывает local base sites
4. Сохранить существующую логику определения стратегий

---

## Detailed Steps

### Step 2.1: Create Federation Configuration

**Action**: Создать modules.json для federated build system

**File**: `/root/info-tech-io/info-tech-io.github.io/configs/federation-modules.json`

**New Configuration**:
```json
{
  "$schema": "../hugo-templates/schemas/modules.schema.json",
  "federation": {
    "name": "InfoTech.io GitHub Pages Federation",
    "baseURL": "https://info-tech-io.github.io",
    "strategy": "preserve-base-site",
    "build_settings": {
      "cache_enabled": true,
      "performance_tracking": false,
      "fail_fast": false,
      "parallel": false,
      "max_parallel_builds": 1
    }
  },
  "modules": [
    {
      "name": "quiz-docs",
      "source": {
        "repository": "https://github.com/info-tech-io/quiz",
        "path": "docs",
        "branch": "main"
      },
      "module_json": "module.json",
      "destination": "/docs/quiz/",
      "css_path_prefix": "/docs/quiz"
    },
    {
      "name": "hugo-templates-docs",
      "source": {
        "repository": "https://github.com/info-tech-io/hugo-templates",
        "path": "docs",
        "branch": "main"
      },
      "module_json": "module.json",
      "destination": "/docs/hugo-templates/",
      "css_path_prefix": "/docs/hugo-templates"
    },
    {
      "name": "web-terminal-docs",
      "source": {
        "repository": "https://github.com/info-tech-io/web-terminal",
        "path": "docs",
        "branch": "main"
      },
      "module_json": "module.json",
      "destination": "/docs/web-terminal/",
      "css_path_prefix": "/docs/web-terminal"
    },
    {
      "name": "info-tech-cli-docs",
      "source": {
        "repository": "https://github.com/info-tech-io/info-tech-cli",
        "path": "docs",
        "branch": "main"
      },
      "module_json": "module.json",
      "destination": "/docs/info-tech-cli/",
      "css_path_prefix": "/docs/info-tech-cli"
    }
  ]
}
```

**Verification**:
- [ ] Configuration follows Hugo Templates schema
- [ ] All 4 documentation modules included
- [ ] preserve-base-site strategy specified
- [ ] Valid JSON syntax

**Success Criteria**:
- ✅ Configuration file created
- ✅ Schema validation passes
- ✅ All documentation sources defined

---

### Step 2.2: Fix Hugo Templates Framework Integration

**Action**: Исправить передачу базового сайта в preserve-base-site стратегии

**File**: `.github/workflows/deploy-github-pages.yml`

**Проблема**: Hugo Templates Framework пытается `wget https://info-tech-io.github.io`
но у нас уже есть скачанное состояние в `current-site` из Phase 1.

**Решение**: Передать `current-site` как local source в preserve-base-site стратегии.

**New Workflow Structure**:
```yaml
      # ==========================================
      # PHASE 3: Federated Build
      # ==========================================
      - name: Determine Build Strategy
        id: build-strategy
        run: |
          echo "🎯 Determining federation build strategy..."

          TRIGGER="${{ github.event_name }}"
          EVENT_TYPE="${{ github.event.action }}"

          if [ "$TRIGGER" = "workflow_dispatch" ]; then
            # Manual trigger - full rebuild
            echo "📢 Manual trigger - full rebuild"
            STRATEGY="merge-and-build"
            BUILD_CORPORATE=true
            BUILD_DOCS=true

          elif [ "$TRIGGER" = "repository_dispatch" ]; then
            if [ "$EVENT_TYPE" = "corporate-site-updated" ]; then
              # Corporate update - full rebuild
              echo "📢 Corporate site update - full rebuild"
              STRATEGY="merge-and-build"
              BUILD_CORPORATE=true
              BUILD_DOCS=true
            else
              # Documentation update - incremental
              echo "📢 Documentation update ($EVENT_TYPE) - incremental"
              STRATEGY="preserve-base-site"
              BUILD_CORPORATE=false
              BUILD_DOCS=true
            fi
          else
            echo "❌ Unknown trigger: $TRIGGER"
            exit 1
          fi

          echo "strategy=$STRATEGY" >> $GITHUB_OUTPUT
          echo "build_corporate=$BUILD_CORPORATE" >> $GITHUB_OUTPUT
          echo "build_docs=$BUILD_DOCS" >> $GITHUB_OUTPUT

          echo ""
          echo "📋 Federation Plan:"
          echo "  - Strategy: $STRATEGY"
          echo "  - Corporate: $BUILD_CORPORATE"
          echo "  - Documentation: $BUILD_DOCS"

      - name: Build Corporate Site (if needed)
        if: steps.build-strategy.outputs.build_corporate == 'true'
        run: |
          echo "🏗️ Building corporate site..."

          cd hugo-templates

          # Copy corporate content
          rm -rf module-content
          cp -r ../info-tech/docs ./module-content

          # Build corporate site
          ./scripts/build.sh \
            --config ./module-content/module.json \
            --content ./module-content/content \
            --output ../corporate-build \
            --force

          cd ..
          echo "✅ Corporate site built"

      - name: Run Federated Build
        env:
          GITHUB_TOKEN: ${{ secrets.PAT_TOKEN }}
        run: |
          echo "🚀 Running Hugo Templates federated build..."

          cd hugo-templates

          STRATEGY="${{ steps.build-strategy.outputs.strategy }}"

          if [ "$STRATEGY" = "preserve-base-site" ]; then
            echo "🔄 Incremental build - using existing current-site as base"

            # КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: Передать current-site как base-site-path
            ./scripts/federated-build.sh \
              --config=../hub-repo/configs/documentation-modules.json \
              --output=../docs-build \
              --preserve-base-site \
              --base-site-path=../current-site \
              --verbose
          else
            echo "🔄 Full rebuild - building everything"
            ./scripts/federated-build.sh \
              --config=../hub-repo/configs/documentation-modules.json \
              --output=../docs-build \
              --verbose
          fi

          cd ..
          echo "✅ Federation build complete"

      - name: Prepare Final Site
        run: |
          echo "📦 Preparing final site structure..."

          # Use federation output as final site
          if [ -d "federation-output" ]; then
            mv federation-output final-site
          else
            echo "❌ Federation output not found!"
            exit 1
          fi

          echo "✅ Final site prepared"
```

**Ключевые изменения**:
1. **Добавлен параметр `--base-site-path=../current-site`** - это заставляет Hugo Templates Framework использовать уже скачанное состояние вместо попыток wget
2. **Исправлен путь к config** - используется правильный путь `../hub-repo/configs/documentation-modules.json`
3. **Исправлен output path** - используется `../docs-build` для совместимости с остальным workflow

**Verification**:
- [ ] Добавлен параметр --base-site-path=../current-site для preserve-base-site стратегии
- [ ] Hugo Templates Framework больше не пытается wget URL
- [ ] Используется уже скачанное состояние из Phase 1
- [ ] Syntax is valid YAML

**Success Criteria**:
- ✅ Hugo Templates Framework использует local base site вместо wget
- ✅ Исправлена интеграция preserve-base-site стратегии
- ✅ Устранена проблема "wget failed with exit code: 8"

---

### Step 2.3: Update Configuration File Reference

**Action**: Обновить путь к конфигурации в существующем файле

**File**: `/root/info-tech-io/info-tech-io.github.io/configs/documentation-modules.json`

**Current**: Используется в workflow
**New**: Заменить на federation-modules.json или обновить содержимое

**Implementation**:
```bash
# Option 1: Update existing file
cp configs/federation-modules.json configs/documentation-modules.json

# Option 2: Update workflow to use new file name
# (Update workflow references from documentation-modules.json to federation-modules.json)
```

**Success Criteria**:
- ✅ Configuration path consistency
- ✅ All references updated

---

### Step 2.4: Test Configuration Locally

**Action**: Проверить что federated-build.sh работает с новой конфигурацией

**Implementation**:
```bash
cd /root/info-tech-io/hugo-templates

# Test configuration validation
./scripts/federated-build.sh \
  --config=../info-tech-io.github.io/configs/federation-modules.json \
  --validate-only

# Test dry run
./scripts/federated-build.sh \
  --config=../info-tech-io.github.io/configs/federation-modules.json \
  --output=../test-output \
  --dry-run \
  --preserve-base-site \
  --verbose

echo "✅ Local testing complete"
```

**Verification**:
- [ ] Configuration validation passes
- [ ] Dry run completes without errors
- [ ] All modules detected correctly
- [ ] preserve-base-site logic works

**Success Criteria**:
- ✅ Configuration validates successfully
- ✅ federated-build.sh accepts configuration
- ✅ No syntax or path errors

---

### Step 2.5: Commit All Changes

**Action**: Зафиксировать все изменения согласно project standards

**Implementation**:
```bash
cd /root/info-tech-io/info-tech-io.github.io

# Add all changes
git add configs/federation-modules.json
git add .github/workflows/deploy-github-pages.yml

git commit -m "feat(workflow): replace custom logic with Hugo Templates Framework

The previous workflow used custom build target determination and merge logic
which failed to handle incremental updates correctly. This change replaces
the custom implementation with Hugo Templates Framework's federated build
system that has built-in support for incremental deployments.

Key Changes:
- Replace 'Determine Build Targets' with federation strategy selection
- Use federated-build.sh instead of custom merge logic
- Add --preserve-base-site flag for incremental documentation updates
- Remove custom 'Atomic Merge' sections (lines 344-425)
- Create federation-modules.json configuration for all 4 doc products

Benefits:
- Incremental updates preserve existing content automatically
- Intelligent merge system with conflict resolution
- CSS path rewriting for federation
- Comprehensive testing (140 tests, 100% pass rate)
- Production-ready system (Epic #15)

Technical Implementation:
- preserve-base-site strategy downloads existing GitHub Pages content
- Merges new documentation on top using intelligent_merge()
- Only rebuilds changed components, preserves everything else

This fixes the root cause: corporate site disappearing during docs updates.

Related: #10, Epic: #2
Implements: Stage 2 of Issue #10
Replaces: Custom workflow logic with Hugo Templates Framework"

git push origin main
```

**Verification**:
- [ ] All files committed
- [ ] Commit message descriptive and traceable
- [ ] References Issue #10 and related Epic

**Success Criteria**:
- ✅ Changes committed and pushed
- ✅ Commit follows project standards
- ✅ Ready for testing

---

## Testing Plan

After implementation, workflow will be tested with:
1. **Manual trigger**: Full rebuild (both components)
2. **Documentation trigger**: Incremental update (preserve corporate)
3. **Corporate trigger**: Full rebuild
4. **Error conditions**: Invalid configurations

Hugo Templates Framework provides extensive testing coverage:
- 140 tests total (100% passing)
- federated-build.sh: 82 tests
- preserve-base-site functionality: tested in production

---

## Rollback Plan

If new workflow fails:
```bash
cd /root/info-tech-io/info-tech-io.github.io

# Revert to previous workflow
git revert HEAD

# Or restore specific file
git checkout HEAD~1 -- .github/workflows/deploy-github-pages.yml
git add .github/workflows/deploy-github-pages.yml
git commit -m "revert: restore previous workflow logic"
git push origin main
```

---

## Definition of Done

- [ ] federation-modules.json configuration created and validated
- [ ] Workflow updated to use federated-build.sh
- [ ] preserve-base-site strategy implemented for incremental updates
- [ ] Custom merge logic removed
- [ ] Local testing completed successfully
- [ ] All changes committed with descriptive message
- [ ] Ready for Stage 3 (testing and validation)

---

**Stage Status**: 🔄 Ready to Execute
**Dependencies**: Stage 1 complete (can skip per instructions)
**Blocks**: Stage 3 and 4
**Estimated Completion**: 4 hours