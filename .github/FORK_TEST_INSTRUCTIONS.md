# Fork Test Instructions - Release Process Alignment

## 🎯 Purpose

This fork contains test implementations for aligning the MetaMask Extension release process with MetaMask Mobile's approach. The key change is **tagging the release branch HEAD before merging** rather than tagging the merge commit afterwards.

## 📁 Test Files Added

### Workflows
1. **`.github/workflows/tag-release-branch.yml`** - Tags the release branch HEAD
2. **`.github/workflows/check-release-tag.yml`** - Verifies releases are tagged before merge
3. **`.github/workflows/test-release-process.yml`** - Automated test scenarios

### Scripts
1. **`.github/scripts/release-create-gh-release.sh`** - Handles GitHub release creation with pre-existing tags

## 🧪 Testing Scenarios

### Scenario 1: Full Release Process Test

This tests the complete workflow from branch creation to release.

#### Steps:
1. **Run the test workflow**:
   ```bash
   # Go to Actions → Test Release Process
   # Select "full-process" and enter a test version (e.g., 99.0.0)
   ```

2. **Observe the check-release-tag workflow**:
   - A PR will be created automatically
   - The check-release-tag workflow will run
   - It should show ⚠️ warning that the release needs tagging

3. **Tag the release**:
   ```bash
   # Go to Actions → Tag Release Branch
   # Enter the same version (99.0.0)
   # Select target branch (main or master)
   ```

4. **Verify PR updates**:
   - PR should now show ✅ release is tagged
   - PR description updates with tag information
   - `release-tagged` label is added

5. **Merge the PR**:
   - Use **merge commit** (not squash)
   - This simulates the production process

6. **Verify results**:
   ```bash
   # Check if tag is in main branch
   git fetch --tags
   git branch --contains v99.0.0

   # Should show main/master in the output
   ```

### Scenario 2: Test Without Tagging (Fallback)

This tests what happens if someone forgets to tag before merge.

#### Steps:
1. Create a release branch manually:
   ```bash
   git checkout -b Version-v98.0.0
   echo "test" > test.txt
   git add test.txt
   git commit -m "Test: Version v98.0.0"
   git push origin Version-v98.0.0
   ```

2. Create PR without tagging:
   ```bash
   gh pr create --title "Test Release v98.0.0" \
                --body "Test without tagging" \
                --base main
   ```

3. Merge the PR without running tag-release-branch

4. Observe warnings in the workflow logs

### Scenario 3: Verify Tag Check Enforcement

#### Steps:
1. Create any PR from a release branch pattern
2. Observe the status check appears
3. Try different branch patterns:
   - `Version-v1.2.3` ✅
   - `release/1.2.3` ✅
   - `feature/test` ❌ (workflow shouldn't run)

## 📊 Expected Outcomes

### ✅ Success Indicators

1. **Tag Creation**:
   - Tag exists on release branch HEAD
   - Tag is included in main/master after merge
   - Tag SHA matches the tested commit

2. **PR Checks**:
   - Status check shows tag state
   - Comments appear when tag missing
   - Labels update correctly

3. **Release Creation**:
   - GitHub release created at existing tag
   - Warning shown if tag created at merge

### ⚠️ Warning Cases

1. **No Tag Before Merge**:
   - Script creates tag at merge commit
   - Warning logged about incorrect process
   - Release still created (backwards compatible)

2. **Tag Not at HEAD**:
   - Check shows warning
   - Suggests re-running tag workflow

## 🔍 Verification Commands

After testing, use these commands to verify:

```bash
# List all test tags
git tag -l "v99*"

# Check if tag is in main
git branch --contains v99.0.0

# View tag details
git show v99.0.0

# Check GitHub releases
gh release list --limit 10

# View workflow runs
gh run list --workflow="Tag Release Branch"
```

## 🧹 Cleanup

After testing, clean up test artifacts:

```bash
# Delete test branches
git push origin --delete Version-v99.0.0

# Delete test tags
git push origin --delete v99.0.0

# Delete test releases
gh release delete v99.0.0 --yes

# Close test PRs
gh pr close [PR-NUMBER]
```

## 📝 Test Checklist

- [ ] Test workflow creates release branch
- [ ] Check-release-tag workflow runs on PR
- [ ] Tag-release-branch workflow creates tag
- [ ] PR updates with tag information
- [ ] Merge includes tagged commit
- [ ] Tag appears in target branch
- [ ] Release created successfully
- [ ] Fallback works if tag missing
- [ ] Warnings appear appropriately

## 🚀 Next Steps

Once testing is successful:

1. **Review results** with the team
2. **Document any issues** found
3. **Prepare for production** deployment
4. **Train release engineers** on new process

## 📚 Additional Resources

- [Original Implementation PR](#) (add link)
- [Mobile Release Process](#) (add link)
- [Release Engineer Guide](#) (add link)

## ⚠️ Important Notes

1. **Always use merge commits** when merging release PRs
2. **Tag before merge** for proper tracking
3. **Test in fork first** before production
4. **Keep test versions high** (90+) to avoid conflicts

## 🆘 Troubleshooting

### Tag not appearing in main after merge
- Ensure you used merge commit, not squash
- Check if tag was created before merge
- Verify tag SHA matches branch HEAD

### Workflow not running
- Check branch name pattern
- Verify permissions are set
- Check workflow conditions

### Release not created
- Verify GITHUB_TOKEN has correct permissions
- Check if tag exists
- Review script logs for errors

---

**Questions?** Contact the Release Engineering team.
