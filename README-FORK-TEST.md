# 🧪 MetaMask Extension Fork - Release Process Testing

This fork contains test implementations for the new release process that aligns MetaMask Extension with MetaMask Mobile.

## 🎯 What's Being Tested

**Key Change**: Tag release branches BEFORE merging to master/main (not after on the merge commit)

## 📁 Test Files Added to `.github/`

### Workflows (`/.github/workflows/`)
- **`tag-release-branch.yml`** - Tags the release branch HEAD
- **`check-release-tag.yml`** - Verifies releases are tagged before merge
- **`test-release-process.yml`** - Automated test scenarios
- **`publish-release-test.yml`** - Simulates post-merge release creation

### Scripts (`/.github/scripts/`)
- **`release-create-gh-release.sh`** - Handles GitHub release creation with pre-existing tags

### Documentation
- **`FORK_TEST_INSTRUCTIONS.md`** - Detailed testing instructions
- **`README-FORK-TEST.md`** - This file

## 🚀 Quick Start

### 1. Run Full Test
```bash
# Go to Actions tab → Test Release Process
# Select "full-process"
# Enter test version: 99.0.0
# Click "Run workflow"
```

### 2. Watch the Magic
The workflow will:
1. Create a release branch `Version-v99.0.0`
2. Create a PR to main/master
3. Show tag check warning ⚠️

### 3. Tag the Release
```bash
# Go to Actions → Tag Release Branch
# Enter version: 99.0.0
# Select target: main
# Run workflow
```

### 4. Verify PR Updates
- Check shows ✅ tagged
- `release-tagged` label added
- PR description updated

### 5. Merge and Verify
- Merge PR with **merge commit** (not squash!)
- Check Actions → Publish Release runs
- Verify tag is in main: `git branch --contains v99.0.0`

## ✅ Success Criteria

- [ ] Release branch can be tagged before merge
- [ ] Tag appears in main/master after merge
- [ ] PR checks show tag status
- [ ] GitHub release created from pre-existing tag
- [ ] Warnings appear if process not followed

## 🧹 Cleanup Test Data

```bash
# Delete test branches
git push origin --delete Version-v99.0.0

# Delete test tags
git push origin --delete v99.0.0

# Delete test releases
gh release delete v99.0.0 --yes
```

## 📊 Test Results

Document your test results here:

| Test Case | Result | Notes |
|-----------|--------|-------|
| Tag before merge | ⏳ | |
| Check enforcement | ⏳ | |
| Release creation | ⏳ | |
| Fallback handling | ⏳ | |

## 🔗 Links

- [Full Instructions](/.github/FORK_TEST_INSTRUCTIONS.md)
- [Main Repository](https://github.com/MetaMask/metamask-extension)

---

**Ready to test?** Start with the [Quick Start](#-quick-start) above! 🚀
