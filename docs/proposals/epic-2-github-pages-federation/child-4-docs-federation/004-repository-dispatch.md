# Stage 4: Repository Dispatch Integration

**Child**: #4 - Documentation Federation Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1, 2, 3)
**Estimated Duration**: 1 day

---

## 🎯 Stage Objective

Setup automated triggers from all 4 product repositories to hub repository using GitHub repository_dispatch events with proper event types.

---

## 📋 Tasks

### Task 1: Create Notify Workflows for Each Product

Create `.github/workflows/notify-hub-docs.yml` in each product repository:

#### Quiz Repository

**File**: `quiz/.github/workflows/notify-hub-docs.yml`

```yaml
name: Notify Hub of Quiz Documentation Update

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'

jobs:
  notify-hub:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Hub Documentation Deployment
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.HUB_DISPATCH_TOKEN }}
          repository: info-tech-io/info-tech-io.github.io
          event-type: quiz-docs-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}",
              "product": "quiz"
            }

      - name: Log Dispatch
        run: |
          echo "📢 Hub notified about Quiz documentation update"
          echo "  Repository: ${{ github.repository }}"
          echo "  Commit: ${{ github.sha }}"
          echo "  Event: quiz-docs-updated"
```

#### Hugo Templates Repository

**File**: `hugo-templates/.github/workflows/notify-hub-docs.yml`

```yaml
name: Notify Hub of Hugo Templates Documentation Update

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'

jobs:
  notify-hub:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Hub Documentation Deployment
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.HUB_DISPATCH_TOKEN }}
          repository: info-tech-io/info-tech-io.github.io
          event-type: hugo-templates-docs-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}",
              "product": "hugo-templates"
            }

      - name: Log Dispatch
        run: |
          echo "📢 Hub notified about Hugo Templates documentation update"
          echo "  Repository: ${{ github.repository }}"
          echo "  Commit: ${{ github.sha }}"
          echo "  Event: hugo-templates-docs-updated"
```

#### Web Terminal Repository

**File**: `web-terminal/.github/workflows/notify-hub-docs.yml`

```yaml
name: Notify Hub of Web Terminal Documentation Update

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'

jobs:
  notify-hub:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Hub Documentation Deployment
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.HUB_DISPATCH_TOKEN }}
          repository: info-tech-io/info-tech-io.github.io
          event-type: web-terminal-docs-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}",
              "product": "web-terminal"
            }

      - name: Log Dispatch
        run: |
          echo "📢 Hub notified about Web Terminal documentation update"
          echo "  Repository: ${{ github.repository }}"
          echo "  Commit: ${{ github.sha }}"
          echo "  Event: web-terminal-docs-updated"
```

#### InfoTech CLI Repository

**File**: `info-tech-cli/.github/workflows/notify-hub-docs.yml`

```yaml
name: Notify Hub of CLI Documentation Update

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'

jobs:
  notify-hub:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Hub Documentation Deployment
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.HUB_DISPATCH_TOKEN }}
          repository: info-tech-io/info-tech-io.github.io
          event-type: cli-docs-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "ref": "${{ github.ref }}",
              "sha": "${{ github.sha }}",
              "product": "info-tech-cli"
            }

      - name: Log Dispatch
        run: |
          echo "📢 Hub notified about CLI documentation update"
          echo "  Repository: ${{ github.repository }}"
          echo "  Commit: ${{ github.sha }}"
          echo "  Event: cli-docs-updated"
```

---

### Task 2: Setup GitHub Token

**Token Requirements**:
- Scope: `repo` (full control)
- Name: `HUB_DISPATCH_TOKEN`
- Access: Write to info-tech-io.github.io

**Steps**:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create new token (classic) with `repo` scope
3. Name: `HUB_DISPATCH_TOKEN`
4. Copy token value

**Add Token to Each Product Repository**:

For each repository (quiz, hugo-templates, web-terminal, info-tech-cli):
1. Go to repository Settings
2. Secrets and variables → Actions
3. New repository secret:
   - Name: `HUB_DISPATCH_TOKEN`
   - Value: [paste token]
4. Save

---

### Task 3: Test Repository Dispatch from Each Product

Test dispatch mechanism for each product:

#### Quiz Test

```bash
# Manual test from local machine
export GITHUB_TOKEN="your_token_here"

curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/info-tech-io/info-tech-io.github.io/dispatches \
  -d '{
    "event_type": "quiz-docs-updated",
    "client_payload": {
      "repository": "info-tech-io/quiz",
      "product": "quiz",
      "test": true
    }
  }'
```

**Verify**:
1. Go to info-tech-io.github.io repository
2. Actions tab
3. Check "Deploy InfoTech.io Documentation Federation" workflow triggered

#### Repeat for All Products

Test each event type:
- `quiz-docs-updated`
- `hugo-templates-docs-updated`
- `web-terminal-docs-updated`
- `cli-docs-updated`

---

### Task 4: End-to-End Test for Each Product

Test complete flow from product → hub:

**Test Procedure** (repeat for each product):

1. Make minor change to product `docs/` content:
   ```bash
   cd quiz  # or hugo-templates, web-terminal, info-tech-cli
   echo "Test update $(date)" >> docs/content/test.md
   git add docs/content/test.md
   git commit -m "docs: test hub dispatch trigger"
   git push origin main
   ```

2. Verify notify workflow runs in product repo

3. Verify dispatch sent successfully (check workflow logs)

4. Verify hub `deploy-docs-federation` workflow triggered

5. Verify documentation deployed correctly

---

### Task 5: Add Smart Deployment Logic (Optional Enhancement)

Add selective rebuild based on event type:

Update hub workflow to rebuild only changed product:

```yaml
      - name: Determine Products to Build
        id: products
        run: |
          event_type="${{ github.event.action }}"

          case "$event_type" in
            "quiz-docs-updated")
              echo "products=quiz" >> $GITHUB_OUTPUT
              ;;
            "hugo-templates-docs-updated")
              echo "products=hugo-templates" >> $GITHUB_OUTPUT
              ;;
            "web-terminal-docs-updated")
              echo "products=web-terminal" >> $GITHUB_OUTPUT
              ;;
            "cli-docs-updated")
              echo "products=info-tech-cli" >> $GITHUB_OUTPUT
              ;;
            *)
              echo "products=all" >> $GITHUB_OUTPUT
              ;;
          esac

      - name: Build Documentation
        run: |
          products="${{ steps.products.outputs.products }}"

          if [ "$products" = "all" ]; then
            echo "Building all product documentation"
            # Use federated-build.sh with all modules
          else
            echo "Building documentation for: $products"
            # Use federated-build.sh with --module filter
          fi
```

---

## 🎯 Deliverable

**Files**: 4 notify workflows (one per product repository)
**Token**: HUB_DISPATCH_TOKEN configured in all repos
**Functionality**: Automatic hub deployment on any product docs change

---

## ✅ Verification Criteria

- [ ] Notify workflow created in quiz repository
- [ ] Notify workflow created in hugo-templates repository
- [ ] Notify workflow created in web-terminal repository
- [ ] Notify workflow created in info-tech-cli repository
- [ ] GitHub token created and configured in all 4 repos
- [ ] Manual dispatch tests successful for all products
- [ ] End-to-end tests successful for all products
- [ ] Hub workflow receives all 4 event types

---

## 🧪 Testing Checklist

### Token Validation
- [ ] Token has `repo` scope
- [ ] Token added to quiz secrets
- [ ] Token added to hugo-templates secrets
- [ ] Token added to web-terminal secrets
- [ ] Token added to info-tech-cli secrets

### Workflow Validation
- [ ] Quiz notify workflow syntax valid
- [ ] Hugo Templates notify workflow syntax valid
- [ ] Web Terminal notify workflow syntax valid
- [ ] CLI notify workflow syntax valid

### Dispatch Tests
- [ ] Manual quiz-docs-updated dispatch works
- [ ] Manual hugo-templates-docs-updated dispatch works
- [ ] Manual web-terminal-docs-updated dispatch works
- [ ] Manual cli-docs-updated dispatch works

### E2E Tests
- [ ] Quiz docs push triggers hub deployment
- [ ] Hugo Templates docs push triggers hub deployment
- [ ] Web Terminal docs push triggers hub deployment
- [ ] CLI docs push triggers hub deployment

---

## 📝 Notes

- Use single token for all repositories (simpler management)
- Each product has unique event type for traceability
- Client payload includes product name for selective builds
- Monitor first few automatic triggers closely

---

## 🔒 Security Considerations

1. **Token Security**:
   - Never commit token to code
   - Use GitHub Secrets exclusively
   - Rotate token periodically (every 90 days)

2. **Dispatch Validation**:
   - Verify event_type matches expected values
   - Check client_payload structure
   - Log all dispatch attempts

3. **Rate Limiting**:
   - GitHub API: 5000 requests/hour
   - Repository dispatch: No specific limit
   - Monitor usage in case of abuse

---

## 🔧 Troubleshooting

**Dispatch not triggering workflow**:
- Verify token has `repo` scope
- Check event type matches workflow `on.repository_dispatch.types`
- Ensure workflow enabled in hub repository

**Workflow triggers but fails**:
- Check token permissions
- Verify repository URLs correct
- Review workflow logs for errors

**Multiple products trigger simultaneously**:
- This is expected behavior (parallel updates)
- Hub workflow handles concurrent builds
- Check concurrency settings if issues arise

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1, 2, 3
**Next**: Create notify workflows in all product repositories
