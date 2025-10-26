# Stage 3: Repository Dispatch Integration

**Child**: #3 - Corporate Site Incremental Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1, 2)
**Estimated Duration**: 0.5 days

---

## 🎯 Stage Objective

Setup automated trigger from `info-tech` repository to hub repository (`info-tech-io.github.io`) using GitHub repository_dispatch events.

---

## 📋 Tasks

### Task 1: Create Notify Workflow in info-tech Repo
Create `.github/workflows/notify-hub.yml` in `info-tech` repository:

```yaml
name: Notify Hub on Corporate Content Update

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
      - name: Trigger Hub Deployment
        run: |
          echo "📢 Notifying hub about corporate content update..."

          curl -X POST \
            -H "Authorization: token ${{ secrets.HUB_DISPATCH_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/info-tech-io/info-tech-io.github.io/dispatches \
            -d '{"event_type":"corporate-site-updated","client_payload":{"repository":"${{ github.repository }}","ref":"${{ github.ref }}","sha":"${{ github.sha }}"}}'

          if [ $? -eq 0 ]; then
            echo "✅ Hub notified successfully"
          else
            echo "❌ Failed to notify hub"
            exit 1
          fi
```

---

### Task 2: Create GitHub Token
Create Personal Access Token (PAT) for repository dispatch:

**Steps**:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create new token (classic) with scope: `repo` (full control)
3. Name: `HUB_DISPATCH_TOKEN`
4. Copy token value

**Add Token to info-tech Repository**:
1. Go to `info-tech` repository
2. Settings → Secrets and variables → Actions
3. New repository secret:
   - Name: `HUB_DISPATCH_TOKEN`
   - Value: [paste token]

---

### Task 3: Test Repository Dispatch
Test the dispatch mechanism:

**Manual Test**:
```bash
# From local machine with GitHub token
export GITHUB_TOKEN="your_token_here"

curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/info-tech-io/info-tech-io.github.io/dispatches \
  -d '{"event_type":"corporate-site-updated","client_payload":{"test":true}}'
```

**Verify**:
1. Go to `info-tech-io.github.io` repository
2. Actions tab
3. Check if "Deploy InfoTech.io Corporate Site" workflow triggered

---

### Task 4: End-to-End Test
Test complete flow from info-tech to hub:

**Test Procedure**:
1. Make minor change to `info-tech/docs/` content
2. Commit and push to main:
   ```bash
   cd info-tech
   echo "Test update" >> docs/content/test.md
   git add docs/content/test.md
   git commit -m "test: trigger hub deployment"
   git push origin main
   ```
3. Verify `notify-hub.yml` workflow runs in info-tech
4. Verify dispatch sent successfully
5. Verify `deploy-corporate-incremental.yml` triggered in hub
6. Verify corporate site deployed

---

### Task 5: Add Logging and Monitoring
Enhance notify workflow with better logging:

```yaml
      - name: Log Dispatch Details
        run: |
          echo "📋 Dispatch Details:"
          echo "  Event Type: corporate-site-updated"
          echo "  Source Repo: ${{ github.repository }}"
          echo "  Branch: ${{ github.ref }}"
          echo "  Commit: ${{ github.sha }}"
          echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

      - name: Dispatch Status
        if: success()
        run: |
          echo "✅ Hub deployment triggered successfully"
          echo "Monitor at: https://github.com/info-tech-io/info-tech-io.github.io/actions"
```

---

## 🎯 Deliverable

**File**: `.github/workflows/notify-hub.yml` in `info-tech` repository
**Functionality**: Automatic hub notification on corporate content changes

---

## ✅ Verification Criteria

- [ ] Notify workflow created in info-tech repo
- [ ] GitHub token created and added
- [ ] Manual dispatch test successful
- [ ] End-to-end test successful
- [ ] Logging comprehensive
- [ ] Workflow triggers on docs changes only

---

## 🧪 Testing Checklist

1. **Token Validation**:
   - [ ] Token has `repo` scope
   - [ ] Token added to info-tech secrets
   - [ ] Token name is `HUB_DISPATCH_TOKEN`

2. **Workflow Validation**:
   - [ ] Workflow syntax valid
   - [ ] Triggers on docs/** changes only
   - [ ] Does NOT trigger on other file changes

3. **Dispatch Test**:
   - [ ] Manual curl dispatch works
   - [ ] Hub workflow triggers
   - [ ] Event payload received correctly

4. **E2E Test**:
   - [ ] Push to info-tech/docs triggers notify
   - [ ] Notify sends dispatch
   - [ ] Hub deploys corporate site
   - [ ] Site updated correctly

---

## 📝 Notes

- Use dedicated token for security
- Token should have minimal permissions (only `repo`)
- Test with manual dispatch first
- Monitor first few automatic triggers
- Consider rate limiting (max 1 deploy per 5 min)

---

## 🔒 Security Considerations

1. **Token Security**:
   - Never commit token to code
   - Use GitHub Secrets
   - Rotate token periodically

2. **Dispatch Validation**:
   - Verify event_type matches
   - Check payload structure
   - Log all dispatch attempts

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1 & 2
**Next**: Create notify workflow in info-tech
