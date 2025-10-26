# Child #4: Documentation Federation Workflow

**Child Issue**: https://github.com/info-tech-io/info-tech-io.github.io/issues/6
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (blocked by Child #3)
**Estimated Duration**: ~4 days

---

## 🎯 Child Objective

Create GitHub Actions workflow for parallel build and deployment of all product documentation to `/docs/{product}/` paths while preserving corporate site in root.

---

## 🔍 Scope

### In Scope
1. **Multi-Product Workflow**: Deploy documentation from 4+ product repositories
2. **Parallel Builds**: Build all product docs simultaneously
3. **Documentation Hub**: Create unified navigation at `/docs/index.html`
4. **Preservation Logic**: Preserve corporate site during docs updates
5. **Repository Dispatch**: Trigger from any product repo change

### Out of Scope
- Corporate site deployment (handled by Child #3)
- E2E testing (handled by Child #5)
- Production monitoring (handled by Child #6)

---

## 🏗️ Architecture Overview

### Product Documentation Structure
```
/docs/
├── index.html                 # Documentation Hub (NEW)
├── quiz/                      # Quiz Engine docs
│   ├── index.html
│   ├── getting-started/
│   └── api/
├── hugo-templates/            # Hugo Templates docs
│   ├── index.html
│   ├── user-guides/
│   └── developer-docs/
├── web-terminal/              # Web Terminal docs
│   ├── index.html
│   └── usage/
└── info-tech-cli/             # CLI docs
    ├── index.html
    └── commands/
```

### Workflow Pattern
1. Download current GitHub Pages state
2. Build ALL product documentation in parallel
3. Create unified Documentation Hub
4. Merge docs → `/docs/`, preserve corporate root
5. Deploy atomically

---

## 📋 Key Components

### 1. Products to Include
- **quiz** (Quiz Engine)
- **hugo-templates** (Hugo Templates Framework)
- **web-terminal** (Web Terminal)
- **info-tech-cli** (InfoTech CLI)

### 2. Configuration File
`configs/documentation-modules.json`:
```json
{
  "federation": {
    "name": "InfoTech.io Documentation Federation",
    "baseURL": "https://info-tech-io.github.io",
    "strategy": "preserve-base-site",
    "build_settings": {
      "parallel": true,
      "max_parallel_builds": 4
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
      "destination": "/docs/quiz/",
      "css_path_prefix": "/docs/quiz"
    },
    // ... additional modules
  ]
}
```

### 3. Repository Dispatch Triggers
```yaml
types: [
  quiz-docs-updated,
  hugo-docs-updated,
  web-terminal-docs-updated,
  cli-docs-updated
]
```

---

## 🎯 Success Criteria

- [ ] Multi-product workflow created
- [ ] All 4+ products build in parallel
- [ ] Documentation Hub created with navigation
- [ ] Each product deploys to `/docs/{product}/`
- [ ] Corporate site preserved during docs updates
- [ ] CSS styling correct in all docs subdirectories
- [ ] Build time < 3 minutes total
- [ ] Repository dispatch working from all product repos

---

## 🔗 Dependencies

**Prerequisites**:
- ✅ Child #1 (Investigation) - Complete
- ✅ Child #2 (Epic #15) - Complete (parallel builds supported)
- ⏳ Child #3 (Corporate Workflow) - Needs to be complete (provides template)

**Blocks**:
- Child #5 (Testing) - Needs workflow to test
- Child #6 (Production) - Needs workflow for production

---

## 📝 Notes

- Use Child #3 workflow as template
- Parallel builds reduce total build time
- Documentation Hub improves discoverability
- Each product maintains independence

---

**Created**: 2025-10-26
**Status**: Design defined, awaiting Child #3 completion
**Document Version**: 1.0
