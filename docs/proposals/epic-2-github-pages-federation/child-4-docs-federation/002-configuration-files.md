# Stage 2: Configuration Files

**Child**: #4 - Documentation Federation Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1)
**Estimated Duration**: 1 day

---

## 🎯 Stage Objective

Create and validate `configs/documentation-modules.json` configuration file for multi-product documentation federation and verify all product repositories have proper `module.json` files.

---

## 📋 Tasks

### Task 1: Create Documentation Modules Configuration

Create `configs/documentation-modules.json`:

```json
{
  "$schema": "../hugo-templates/schemas/modules.schema.json",
  "federation": {
    "name": "InfoTech.io Documentation Federation",
    "baseURL": "https://info-tech-io.github.io",
    "strategy": "preserve-base-site",
    "build_settings": {
      "cache_enabled": true,
      "performance_tracking": true,
      "fail_fast": false,
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
      "module_json": "module.json",
      "destination": "/docs/quiz/",
      "css_path_prefix": "/docs/quiz",
      "priority": 10,
      "overrides": {
        "theme": "compose",
        "template": "documentation"
      }
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
      "css_path_prefix": "/docs/hugo-templates",
      "priority": 10,
      "overrides": {
        "theme": "compose",
        "template": "documentation"
      }
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
      "css_path_prefix": "/docs/web-terminal",
      "priority": 10,
      "overrides": {
        "theme": "compose",
        "template": "documentation"
      }
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
      "css_path_prefix": "/docs/info-tech-cli",
      "priority": 10,
      "overrides": {
        "theme": "compose",
        "template": "documentation"
      }
    }
  ]
}
```

**Key Configuration Details**:
- **strategy**: `preserve-base-site` - Preserves corporate site at root
- **parallel**: `true` - Enable parallel builds for all products
- **max_parallel_builds**: `4` - Build all 4 products simultaneously
- **css_path_prefix**: Set for each product for subdirectory deployment
- **fail_fast**: `false` - Continue building other products if one fails

---

### Task 2: Verify Product Module.json Files

Check each product repository for proper `module.json`:

#### Quiz Repository

```bash
# Clone and check quiz
git clone https://github.com/info-tech-io/quiz.git /tmp/quiz
ls -la /tmp/quiz/docs/module.json
cat /tmp/quiz/docs/module.json
```

**Expected module.json**:
```json
{
  "name": "quiz-documentation",
  "version": "1.0.0",
  "type": "documentation",
  "hugo_config": {
    "template": "documentation",
    "theme": "compose",
    "hugo_version": "0.148.0"
  },
  "site": {
    "title": "Quiz Engine Documentation",
    "description": "Interactive quiz platform documentation",
    "baseURL": "https://info-tech-io.github.io/docs/quiz",
    "language": "en"
  },
  "content": {
    "source": "./content",
    "destination": ""
  }
}
```

#### Hugo Templates Repository

```bash
git clone https://github.com/info-tech-io/hugo-templates.git /tmp/hugo-templates-check
ls -la /tmp/hugo-templates-check/docs/module.json
cat /tmp/hugo-templates-check/docs/module.json
```

**Expected module.json**:
```json
{
  "name": "hugo-templates-documentation",
  "version": "2.0.0",
  "type": "documentation",
  "hugo_config": {
    "template": "documentation",
    "theme": "compose",
    "hugo_version": "0.148.0"
  },
  "site": {
    "title": "Hugo Templates Framework Documentation",
    "description": "Complete Hugo Templates documentation",
    "baseURL": "https://info-tech-io.github.io/docs/hugo-templates",
    "language": "en"
  }
}
```

#### Web Terminal Repository

```bash
git clone https://github.com/info-tech-io/web-terminal.git /tmp/web-terminal
ls -la /tmp/web-terminal/docs/module.json
cat /tmp/web-terminal/docs/module.json
```

**Expected module.json**:
```json
{
  "name": "web-terminal-documentation",
  "version": "1.0.0",
  "type": "documentation",
  "hugo_config": {
    "template": "documentation",
    "theme": "compose",
    "hugo_version": "0.148.0"
  },
  "site": {
    "title": "Web Terminal Documentation",
    "description": "Browser-based terminal emulator documentation",
    "baseURL": "https://info-tech-io.github.io/docs/web-terminal",
    "language": "en"
  }
}
```

#### InfoTech CLI Repository

```bash
git clone https://github.com/info-tech-io/info-tech-cli.git /tmp/info-tech-cli
ls -la /tmp/info-tech-cli/docs/module.json
cat /tmp/info-tech-cli/docs/module.json
```

**Expected module.json**:
```json
{
  "name": "info-tech-cli-documentation",
  "version": "1.0.0",
  "type": "documentation",
  "hugo_config": {
    "template": "documentation",
    "theme": "compose",
    "hugo_version": "0.148.0"
  },
  "site": {
    "title": "InfoTech CLI Documentation",
    "description": "Command-line interface documentation",
    "baseURL": "https://info-tech-io.github.io/docs/info-tech-cli",
    "language": "en"
  }
}
```

---

### Task 3: Create Module.json Files (If Missing)

For any product missing `module.json`, create it:

**Template**:
```json
{
  "name": "{product}-documentation",
  "version": "1.0.0",
  "type": "documentation",
  "hugo_config": {
    "template": "documentation",
    "theme": "compose",
    "components": [],
    "hugo_version": "0.148.0"
  },
  "site": {
    "title": "{Product Name} Documentation",
    "description": "{Product description}",
    "baseURL": "https://info-tech-io.github.io/docs/{product}",
    "language": "en",
    "author": "InfoTech.io Team"
  },
  "content": {
    "source": "./content",
    "destination": ""
  },
  "features": {
    "enableSearch": true,
    "enableAnalytics": false,
    "enableComments": false,
    "enableSocialSharing": true
  },
  "build_settings": {
    "hugo_version": "0.148.0",
    "enable_minification": true,
    "enable_fingerprinting": true
  }
}
```

**Action Steps**:
1. Create `docs/module.json` in product repository
2. Commit with message: `docs: add module.json for federation`
3. Push to main branch
4. Verify in GitHub

---

### Task 4: Validate Configuration

Test configuration with dry-run:

```bash
cd hugo-templates

# Validate documentation-modules.json
./scripts/federated-build.sh \
  --config=../hub-repo/configs/documentation-modules.json \
  --validate-only \
  --verbose
```

**Expected Output**:
```
✅ Configuration validation passed
✅ JSON Schema validation: OK
✅ All 4 modules valid:
   - quiz-docs
   - hugo-templates-docs
   - web-terminal-docs
   - info-tech-cli-docs
✅ Federation strategy: preserve-base-site
✅ Parallel builds: enabled (max 4)
```

---

### Task 5: Test Dry Run

Run complete dry-run without actual build:

```bash
cd hugo-templates

./scripts/federated-build.sh \
  --config=../hub-repo/configs/documentation-modules.json \
  --dry-run \
  --verbose
```

**Expected Output**:
```
🔍 DRY RUN MODE - No actual builds will be performed

📋 Configuration Summary:
  - Federation: InfoTech.io Documentation Federation
  - Strategy: preserve-base-site
  - Parallel: enabled (4 concurrent builds)
  - Modules: 4
    1. quiz-docs (destination: /docs/quiz/)
    2. hugo-templates-docs (destination: /docs/hugo-templates/)
    3. web-terminal-docs (destination: /docs/web-terminal/)
    4. info-tech-cli-docs (destination: /docs/info-tech-cli/)

✅ Dry run completed successfully
```

---

## 🎯 Deliverable

**File**: `configs/documentation-modules.json`
**Size**: ~120 lines JSON
**Functionality**: Valid federated build configuration for all product documentation

---

## ✅ Verification Criteria

- [ ] Configuration file created
- [ ] All 4 product modules defined
- [ ] JSON Schema validation passes
- [ ] Dry-run test succeeds
- [ ] All product repos have valid module.json
- [ ] Parallel build settings correct
- [ ] CSS path prefixes set for all modules

---

## 🧪 Testing Plan

1. **Schema Validation**:
   - Use `federated-build.sh --validate-only`
   - Expect: No validation errors

2. **Dry Run**:
   - Use `federated-build.sh --dry-run`
   - Expect: Successful simulation of 4 parallel builds

3. **Source Verification**:
   - Verify all 4 product repos accessible
   - Verify all module.json files present
   - Verify content structure valid in each repo

---

## 📝 Notes

- Configuration follows Epic #15 federated build schema
- Parallel builds significantly reduce total build time
- Each product maintains independence
- Corporate site preservation critical for incremental updates

---

## 🔧 Troubleshooting

**If module.json missing in product repo**:
1. Create using template above
2. Adjust title, description for specific product
3. Set correct baseURL with `/docs/{product}` path
4. Commit and push to product repo
5. Re-run validation

**If validation fails**:
1. Check JSON syntax (no trailing commas)
2. Verify all required fields present
3. Ensure repository URLs correct
4. Check branch names (main vs master)

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1
**Next**: Create configuration file and verify all product repos
