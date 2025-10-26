# Stage 2: Configuration Files

**Child**: #3 - Corporate Site Incremental Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1)
**Estimated Duration**: 0.5 days

---

## 🎯 Stage Objective

Create and validate `configs/corporate-modules.json` configuration file for federated build system (Epic #15).

---

## 📋 Tasks

### Task 1: Create Configuration File
Create `configs/corporate-modules.json`:

```json
{
  "$schema": "../hugo-templates/schemas/modules.schema.json",
  "federation": {
    "name": "InfoTech.io Corporate Site",
    "baseURL": "https://info-tech-io.github.io",
    "strategy": "preserve-base-site",
    "build_settings": {
      "cache_enabled": true,
      "performance_tracking": false,
      "fail_fast": true
    }
  },
  "modules": [
    {
      "name": "corporate-site",
      "source": {
        "repository": "https://github.com/info-tech-io/info-tech",
        "path": "docs",
        "branch": "main"
      },
      "module_json": "module.json",
      "destination": "/",
      "css_path_prefix": "",
      "priority": 10,
      "overrides": {
        "theme": "compose",
        "template": "corporate"
      }
    }
  ]
}
```

**Key Configuration Details**:
- **strategy**: `preserve-base-site` - Preserves existing `/docs/` content
- **destination**: `/` - Deploy to root
- **css_path_prefix**: `""` (empty) - No prefix needed for root deployment
- **priority**: `10` - Standard priority

---

### Task 2: Validate Against JSON Schema
Run validation using hugo-templates schema:

```bash
# Clone hugo-templates if not present
git clone https://github.com/info-tech-io/hugo-templates.git /tmp/hugo-templates

# Validate configuration
cd /tmp/hugo-templates
./scripts/federated-build.sh \
  --config=../../configs/corporate-modules.json \
  --validate-only \
  --verbose
```

**Expected Output**:
```
✅ Configuration validation passed
✅ JSON Schema validation: OK
✅ All modules valid
✅ Federation strategy: preserve-base-site
```

---

### Task 3: Test with Dry Run
Test configuration without actual build:

```bash
cd hugo-templates
./scripts/federated-build.sh \
  --config=../configs/corporate-modules.json \
  --dry-run \
  --verbose
```

**Expected Output**:
```
🔍 DRY RUN MODE - No actual builds will be performed

📋 Configuration Summary:
  - Federation: InfoTech.io Corporate Site
  - Strategy: preserve-base-site
  - Modules: 1
    1. corporate-site (repository: info-tech-io/info-tech)

✅ Dry run completed successfully
```

---

### Task 4: Verify Module Configuration
Check that info-tech repository has proper `module.json`:

```bash
# Clone info-tech repo
git clone https://github.com/info-tech-io/info-tech.git /tmp/info-tech

# Check module.json exists
ls -la /tmp/info-tech/docs/module.json

# Validate module.json structure
cat /tmp/info-tech/docs/module.json
```

**Required Fields** in `module.json`:
```json
{
  "template": "corporate",
  "theme": "compose",
  "site": {
    "baseURL": "https://info-tech-io.github.io",
    "title": "InfoTech.io"
  }
}
```

**If module.json missing**: Create it in info-tech repository

---

### Task 5: Create configs Directory
Ensure directory structure exists:

```bash
# In info-tech-io.github.io repository
mkdir -p configs
touch configs/.gitkeep
```

---

## 🎯 Deliverable

**File**: `configs/corporate-modules.json`
**Size**: ~35 lines JSON
**Functionality**: Valid federated build configuration for corporate site

---

## ✅ Verification Criteria

- [ ] Configuration file created
- [ ] JSON Schema validation passes
- [ ] Dry-run test succeeds
- [ ] Module.json verified in info-tech repo
- [ ] All paths correct
- [ ] Strategy is `preserve-base-site`

---

## 🧪 Testing Plan

1. **Schema Validation**:
   - Use `federated-build.sh --validate-only`
   - Expect: No validation errors

2. **Dry Run**:
   - Use `federated-build.sh --dry-run`
   - Expect: Successful simulation

3. **Source Verification**:
   - Verify info-tech/docs/ exists
   - Verify module.json present
   - Verify content structure valid

---

## 📝 Notes

- Configuration follows Epic #15 schema
- Strategy `preserve-base-site` is key for incremental deployment
- Empty `css_path_prefix` correct for root deployment
- Priority 10 is standard (can adjust if needed)

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1
**Next**: Create configuration file
