# Child #1: Dependencies Analysis Design

**Issue**: https://github.com/info-tech-io/info-tech-io.github.io/issues/13
**Epic**: #12 Organization Migration info-tech-io → info-tech
**Type**: Child Issue
**Estimated Duration**: 2-3 дня
**Priority**: КРИТИЧЕСКИЙ

---

## 🎯 Objective

Провести comprehensive анализ всех критических инфраструктурных зависимостей от имени организации `info-tech-io` для обеспечения zero-downtime migration. Фокус на workflows, CI/CD и automation dependencies, исключая content analysis.

---

## 🔍 Scope Definition

### ✅ IN SCOPE - Critical Infrastructure
1. **GitHub Pages Workflows** (info-tech-io.github.io)
2. **Repository Dispatch Notifications** (cross-repo automation)
3. **ИНФОТЕКА Product Workflows** (infotecha repo)
4. **CI/CD Dependencies** (automation infrastructure)

### ❌ EXPLICITLY OUT OF SCOPE
- ❌ **Documentation Links**: Markdown content ссылки (separate process)
- ❌ **README References**: Badges, shields, documentation
- ❌ **Content Analysis**: Internal documentation content

---

## 🛠️ Analysis Methodology

### Phase 1: Repository Inventory
**Goal**: Identify all repositories with potential dependencies

**Approach**:
```bash
# List all local repositories
ls -la /root/info-tech-io/

# For each repo, check for workflow files
find /root/info-tech-io/ -name ".github" -type d
find /root/info-tech-io/ -path "*/.github/workflows/*.yml" -o -path "*/.github/workflows/*.yaml"
```

### Phase 2: Workflow Analysis
**Goal**: Analyze GitHub Actions workflows for organization dependencies

**Key Search Patterns**:
```bash
# Search for hardcoded organization references
grep -r "info-tech-io" /root/info-tech-io/*/.github/workflows/
grep -r "github.com/info-tech-io" /root/info-tech-io/*/
grep -r "repository_dispatch" /root/info-tech-io/*/.github/workflows/
```

### Phase 3: Cross-Repository Dependencies
**Goal**: Map repository dispatch chains and notifications

**Analysis Focus**:
- `notify-hub.yml` patterns across repositories
- Repository dispatch event flows
- Automation trigger chains

### Phase 4: ИНФОТЕКА Product Impact
**Goal**: Assess impact on main product functionality

**Critical Questions**:
- Does infotecha repo reference organization name?
- Will build process break with organization rename?
- Are there deployment dependencies?

---

## 📋 Detailed Analysis Plan

### Stage 1: GitHub Pages Repository Analysis
**Duration**: 0.5 day
**Focus**: `info-tech-io.github.io` workflows

**Specific Targets**:
- `.github/workflows/deploy-corporate-incremental.yml`
- `.github/workflows/deploy-docs-federation.yml`
- `configs/documentation-modules.json`
- Any hardcoded references to `info-tech-io.github.io`

**Deliverable**: Complete inventory с update requirements

### Stage 2: Repository Dispatch Mapping
**Duration**: 1 day
**Focus**: Cross-repository automation

**Analysis Method**:
```bash
# Find all notify workflows
find /root/info-tech-io/ -name "*notify*" -path "*/.github/workflows/*"

# Analyze repository dispatch events
grep -r "repository_dispatch" /root/info-tech-io/
grep -r "event_type" /root/info-tech-io/

# Map dispatch chains
grep -r "info-tech-io.github.io" /root/info-tech-io/*/.github/workflows/
```

**Deliverable**: Repository dispatch chain diagram

### Stage 3: ИНФОТЕКА Product Analysis
**Duration**: 0.5 day
**Focus**: Main product impact assessment

**Analysis Targets**:
- `infotecha` repository workflows
- Build process dependencies
- Deployment configurations
- Module integration points

**Critical Validation**: Confirm organization rename won't break product

### Stage 4: Infrastructure Dependencies Audit
**Duration**: 0.5 day
**Focus**: Remaining critical dependencies

**Scope**:
- GitHub Actions marketplace references
- External service integrations
- Webhook configurations
- API endpoint references

---

## 🔧 Tools and Commands

### Primary Analysis Commands
```bash
# Organization reference search (excluding documentation)
grep -r "info-tech-io" /root/info-tech-io/ \
  --include="*.yml" --include="*.yaml" --include="*.json" \
  --exclude-dir="docs" --exclude="*.md"

# Workflow-specific analysis
find /root/info-tech-io/ -path "*/.github/workflows/*" -name "*.yml" -exec grep -l "info-tech-io" {} \;

# Repository dispatch analysis
grep -r "repository_dispatch" /root/info-tech-io/*/.github/workflows/
grep -r "notify-hub" /root/info-tech-io/*/
```

### Categorization Script
```bash
# Create analysis results structure
mkdir -p analysis-results/{high-priority,medium-priority,low-priority}

# Automated categorization based on file paths
# HIGH: .github/workflows/, configs/
# MEDIUM: package.json, setup files
# LOW: other configuration files
```

---

## 📊 Expected Findings

### High-Priority Updates Required
1. **GitHub Pages Workflows**
   - `deploy-docs-federation.yml`: repository dispatch targets
   - `documentation-modules.json`: organization references

2. **Repository Notifications**
   - Multiple `notify-hub.yml` files across product repos
   - Repository dispatch event chains

3. **Configuration Files**
   - Any JSON configs with hardcoded organization names
   - Workflow environment variables

### Medium-Priority Updates
1. **CI/CD Configurations**
   - Environment-specific settings
   - External service configurations

### Low-Priority (Post-Migration)
1. **Development Tooling**
   - Local development scripts
   - Helper utilities

---

## 🚨 Risk Assessment Framework

### Risk Classification
- **🔴 HIGH**: Breaks critical functionality (deployment, automation)
- **🟡 MEDIUM**: Affects development workflow, но не блокирует
- **🟢 LOW**: Cosmetic или non-critical references

### Impact Categories
1. **Deployment Impact**: Will it break GitHub Pages or product deployment?
2. **Automation Impact**: Will it break CI/CD workflows?
3. **Integration Impact**: Will it affect cross-repo communications?
4. **Development Impact**: Will it affect developer workflow?

---

## 📋 Deliverables Format

### 1. Dependencies Inventory
```
File: analysis-results/dependencies-inventory.md

Format:
| File Path | Dependency Type | Risk Level | Update Required | Notes |
|-----------|----------------|------------|-----------------|-------|
| .github/workflows/deploy-docs.yml | Repository Dispatch | HIGH | Yes | Target organization change |
```

### 2. Update Action Plan
```
File: analysis-results/update-action-plan.md

Priority-ordered list:
1. HIGH PRIORITY (Day 1 of migration)
2. MEDIUM PRIORITY (Day 2-3 of migration)
3. LOW PRIORITY (Post-migration cleanup)
```

### 3. ИНФОТЕКА Impact Report
```
File: analysis-results/infotecha-impact-assessment.md

Assessment:
- Build Process Impact: [NONE/LOW/MEDIUM/HIGH]
- Deployment Impact: [NONE/LOW/MEDIUM/HIGH]
- Functionality Impact: [NONE/LOW/MEDIUM/HIGH]
- Recommended Actions: [List of specific actions]
```

---

## ✅ Success Criteria

### Must-Have Outcomes
- [ ] **Complete Inventory**: All infrastructure dependencies identified
- [ ] **Risk Assessment**: Each dependency classified по impact level
- [ ] **ИНФОТЕКА Validation**: Product impact confirmed minimal
- [ ] **Action Plan**: Priority-ordered update procedures

### Quality Gates
- [ ] **Zero Surprises**: No critical dependencies discovered during migration
- [ ] **Minimal Downtime**: Clear understanding of what breaks и when
- [ ] **Recovery Plan**: Know how to rollback if issues occur
- [ ] **Automation Ready**: Update procedures can be scripted

### Validation Methods
- [ ] **Peer Review**: Another team member reviews findings
- [ ] **Dry Run**: Test search commands на sample repositories
- [ ] **Documentation**: All findings clearly documented
- [ ] **Priority Validation**: High-priority items confirmed critical

---

## 🔄 Stage Breakdown

### Stage 1: GitHub Pages Analysis (0.5d)
**File**: `001-github-pages-analysis.md`
**Focus**: info-tech-io.github.io workflows

### Stage 2: Repository Dispatch Mapping (1d)
**File**: `002-repository-dispatch-mapping.md`
**Focus**: Cross-repo automation chains

### Stage 3: ИНФОТЕКА Impact Assessment (0.5d)
**File**: `003-infotecha-impact-assessment.md`
**Focus**: Product functionality impact

### Stage 4: Final Report & Action Plan (0.5d)
**File**: `004-final-report-action-plan.md`
**Focus**: Consolidated findings и recommendations

---

## 📚 References

- **Epic #12 Design**: `../design.md`
- **GitHub Docs**: [Repository Dispatch Events](https://docs.github.com/en/rest/repos/repos#create-a-repository-dispatch-event)
- **InfoTech Workflow**: https://github.com/info-tech-io/info-tech/blob/main/docs/content/open-source/issue-commit-workflow.md

---

**Created**: 2025-11-07 12:00 UTC
**Next Review**: After Stage 1 completion
**Parent Epic**: #12