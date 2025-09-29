# GitHub Actions Workflow Analysis

**Document Version**: 1.0
**Date**: 2025-09-29
**Epic**: #2 - Rebuild GitHub Pages Federation with Incremental Architecture
**Phase**: 1 - Investigation & Design
**Depends On**: current-state-analysis.md

## 🎯 Executive Summary

Analysis of current GitHub Actions workflows reveals systematic issues in deployment logic that cause complete content overwrites instead of incremental updates. This document provides detailed workflow analysis and identifies specific points where architectural changes are needed.

## 🔍 Workflow Inventory Analysis

### Current Workflow Status (All Disabled)

| Workflow File | Status | Purpose | Issues Identified |
|---------------|--------|---------|-------------------|
| `deploy-complete-federation.yml` | 🔴 Disabled | Full federation deployment | Sequential overwrite problem |
| `deploy-corporate.yml` | 🔴 Disabled | Corporate site only | Works but lacks docs preservation |
| `deploy-docs.yml` | 🔴 Disabled | Documentation only | Works but lacks corporate preservation |
| `deploy-complete-sites-deprecated.yml` | 🔴 Disabled | Legacy federation | Deprecated, contains same issues |
| `cleanup-pages.yml` | 🔴 Disabled | GitHub Pages cleanup | Temporary utility, can be removed |
| `debug-corporate-build.yml` | 🔴 Disabled | Debug workflow | Development utility |

### Active System Workflows

| Workflow | Status | Purpose | Notes |
|----------|--------|---------|-------|
| `pages-build-deployment` | ✅ Active | GitHub Pages system | Automatic GitHub Pages deployment |

## 🚨 Critical Workflow Issues

### 1. Sequential Overwrite Problem (deploy-complete-federation.yml)

**Issue**: Each build step completely overwrites previous build results.

**Technical Flow Analysis**:
```yaml
# Current problematic sequence:
- name: Build Corporate Site (Root)
  run: scripts/build.sh --output ../build-output  # Creates: build-output/*

- name: Build Quiz Engine Documentation
  run: scripts/build.sh --output ../build-output  # OVERWRITES ALL build-output/*

- name: Build Hugo Templates Documentation
  run: scripts/build.sh --output ../build-output  # OVERWRITES ALL build-output/*

- name: Build Web Terminal Documentation
  run: scripts/build.sh --output ../build-output  # OVERWRITES ALL build-output/*

- name: Build Info-Tech CLI Documentation
  run: scripts/build.sh --output ../build-output  # OVERWRITES ALL build-output/*
```

**Result**: Only the last build (Info-Tech CLI) remains in the final deployment.

### 2. No State Preservation Logic

**Issue**: No mechanism to download and preserve existing GitHub Pages content.

**Missing Components**:
- No artifact download from previous GitHub Pages deployment
- No merge logic to combine new builds with existing content
- No conflict resolution for overlapping paths
- No rollback mechanism for failed builds

### 3. Independent Workflows Lack Cross-Awareness

**Issue**: `deploy-corporate.yml` and `deploy-docs.yml` work independently but don't coordinate.

**Problems**:
- Corporate workflow creates placeholder `/docs/` directory
- Documentation workflow would overwrite entire site including corporate content
- No coordination mechanism between workflows
- Race conditions possible if both trigger simultaneously

## 📊 Detailed Workflow Analysis

### Deploy Corporate Workflow (deploy-corporate.yml.disabled)

**Strengths**:
- ✅ Clean isolation - only handles corporate content
- ✅ Proper Hugo Templates Framework integration
- ✅ Fallback page creation for missing `/docs/`
- ✅ Debug mode support
- ✅ Reasonable error handling

**Weaknesses**:
- ❌ No preservation of existing `/docs/` content
- ❌ Creates placeholder `/docs/index.html` that would be lost
- ❌ No coordination with documentation updates
- ❌ Single deploy target - can't run in incremental mode

**Critical Code Analysis**:
```bash
# build-output directory completely recreated each time:
rm -rf build-output
mkdir -p build-output

# build.sh creates complete site:
scripts/build.sh --output ../build-output --force --no-cache

# Result: Full site overwrite, any existing /docs/ content lost
```

### Deploy Documentation Workflow (deploy-docs.yml.disabled)

**Strengths**:
- ✅ Multi-product build support
- ✅ Conditional building based on repository dispatch events
- ✅ Documentation Hub creation
- ✅ Parallel build potential (though not implemented)

**Weaknesses**:
- ❌ Same sequential overwrite problem as federation workflow
- ❌ Each product build overwrites previous products
- ❌ No corporate site preservation
- ❌ Missing implementation of destination paths

**Critical Code Analysis**:
```bash
# Each product build overwrites build-output:
scripts/build.sh --output ../build-output  # Quiz overwrites corporate
scripts/build.sh --output ../build-output  # Hugo Templates overwrites Quiz
scripts/build.sh --output ../build-output  # Web Terminal overwrites Hugo Templates
scripts/build.sh --output ../build-output  # CLI overwrites Web Terminal
```

### Deploy Complete Federation Workflow (deploy-complete-federation.yml.disabled)

**Design Intent**: Build both corporate site and all documentation in single workflow.

**Actual Behavior**: Sequential overwrites leave only last-built content.

**Evidence from Build Summary**:
```yaml
# From actual run logs:
📊 Total files: 401
📦 Total size: 11M
🏗️ Federation Structure:
├── / (Corporate site - 2 pages)  # Should be ~370 pages
├── /docs/ (Documentation hub)
# No product subdirectories created
```

**Analysis**: Only 2 corporate pages suggests massive content loss during sequential builds.

## 🔧 Root Cause Analysis

### Primary Technical Causes

1. **Hugo Templates Framework Output Model**:
   - Framework designed for single site output
   - `--output` parameter specifies complete site destination
   - No incremental build mode in framework

2. **GitHub Actions Workflow Design**:
   - No artifact persistence between build steps
   - No state download from existing GitHub Pages
   - Sequential execution with complete overwrite pattern

3. **Missing Merge Logic**:
   - No code to combine multiple build outputs
   - No directory-level merge strategies
   - No conflict detection or resolution

### Secondary Contributing Factors

1. **Configuration Gaps**:
   - Module.json `destination` parameter not implemented
   - No federated build configuration schema
   - Missing CSS path prefix settings

2. **Deployment Isolation**:
   - Each workflow operates in clean environment
   - No shared state between corporate and documentation builds
   - No coordination mechanisms

## 💡 Key Insights for Solution Design

### What Works (Preserve These)

1. **Individual Build Quality**: Each individual build produces correct content
2. **Hugo Templates Integration**: Framework integration works perfectly for single sites
3. **Repository Dispatch System**: Cross-repository communication works
4. **Error Handling**: Debug modes and error reporting function well
5. **Performance**: Build times acceptable for individual components

### What Must Change (Critical Fixes)

1. **Output Strategy**: Move from overwrite to incremental accumulation
2. **State Management**: Add GitHub Pages artifact download/merge logic
3. **Build Coordination**: Implement proper merge strategies
4. **CSS Path Resolution**: Add federated path prefix support

### Architectural Requirements

1. **Artifact Persistence**: Download existing GitHub Pages content before builds
2. **Merge Logic**: Combine multiple builds into single deployment
3. **Path Management**: Handle CSS and asset paths for subdirectory deployment
4. **State Consistency**: Ensure atomic deployments with rollback capability

## 🎯 Recommended Workflow Architecture

Based on this analysis, the recommended new architecture:

### Option A: Enhanced Separate Workflows (Recommended)
```
Corporate Workflow:
1. Download current GitHub Pages → current-site/
2. Build corporate site → temp-corporate/
3. Merge: temp-corporate/* → current-site/* (preserve /docs/)
4. Deploy: current-site/

Documentation Workflow:
1. Download current GitHub Pages → current-site/
2. Build all docs → temp-docs/{product1,product2,etc}/
3. Create docs hub → temp-docs/index.html
4. Merge: temp-docs/* → current-site/docs/* (preserve root)
5. Deploy: current-site/
```

### Option B: Fixed Federation Workflow
```
Complete Federation Workflow:
1. Download current GitHub Pages → current-site/
2. Build corporate → temp-corporate/
3. Build docs parallel → temp-docs/{product1,product2,etc}/
4. Merge corporate: temp-corporate/* → current-site/*
5. Merge docs: temp-docs/* → current-site/docs/*
6. Deploy: current-site/
```

**Recommendation**: Option A (Separate Workflows) for better isolation and debugging.

## 📋 Technical Requirements Summary

### Hugo Templates Framework Enhancements Needed

1. **New Build Parameters**:
   - `--incremental-output` - Build only content, not full site structure
   - `--css-path-prefix` - Adjust CSS paths for subdirectory deployment
   - `--preserve-structure` - Maintain relative paths for federated deployment

2. **Module.json Schema Extensions**:
   - Federation configuration block
   - CSS path prefix settings
   - Deployment destination paths

### GitHub Actions Workflow Requirements

1. **Artifact Management**:
   - Download previous GitHub Pages deployment
   - Merge multiple build outputs
   - Deploy combined result atomically

2. **State Preservation**:
   - Preserve corporate content during docs updates
   - Preserve documentation during corporate updates
   - Handle merge conflicts gracefully

3. **Error Handling**:
   - Rollback on build failures
   - Validate merged content before deployment
   - Comprehensive logging for debugging

---

**Next Steps**: Proceed to Architecture Design phase to define specific implementation approach based on these workflow analysis findings.

**Document Status**: ✅ Complete
**Review Status**: Pending technical review
**Dependencies**: Requires Hugo Templates Framework analysis completion