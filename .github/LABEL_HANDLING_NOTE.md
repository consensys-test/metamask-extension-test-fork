# Label Handling in Fork Tests

## Issue Encountered
When running the test workflows in a fork, you may encounter errors like:
```
could not add label: 'test-release' not found
Error: Process completed with exit code 1.
```

## Solution Implemented
All workflows have been updated to handle missing labels gracefully:

1. **Automatic Label Creation**: Workflows now attempt to create labels before using them
2. **Error Handling**: Label operations won't fail the workflow if they can't be completed
3. **Graceful Degradation**: The core functionality works even without labels

## How It Works

### In `test-release-process.yml`:
```bash
# Try to create the label first (ignore if it fails)
gh label create "test-release" --description "Test release PR" --color "0e8a16" 2>/dev/null || true

# Create PR without label, then try to add it
PR_URL=$(gh pr create ...)
gh pr edit "${PR_NUMBER}" --add-label "test-release" 2>/dev/null || echo "Note: Could not add label"
```

### In `tag-release-branch.yml`:
```bash
# Create labels before using them
gh label create "release-tagged" --description "Release has been tagged" --color "0e8a16" 2>/dev/null || true
```

### In `check-release-tag.yml`:
```javascript
try {
  // Try to create the label first
  await github.rest.issues.createLabel({
    owner: context.repo.owner,
    repo: context.repo.repo,
    name: 'release-tagged',
    description: 'Release has been tagged',
    color: '0e8a16'
  });
} catch (e) {
  // Label might already exist, continue
}
```

## Labels Used by the Workflows

| Label | Purpose | Color |
|-------|---------|-------|
| `test-release` | Marks test release PRs | Green |
| `release-tagged` | Indicates release has been tagged | Green |
| `needs-tag` | Indicates release needs tagging | Yellow |
| `release-X.Y.Z` | Version-specific label | Red |

## No Action Required
The workflows will now:
- ✅ Continue working even if labels can't be created
- ✅ Show informative messages instead of errors
- ✅ Focus on the core testing functionality

Labels are nice-to-have visual indicators but not critical for the test process to work.
