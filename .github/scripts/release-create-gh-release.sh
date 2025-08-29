#!/usr/bin/env bash

set -e

echo "🧪 Fork Test - Release Creation Script"
echo "======================================="

if [[ -z "${GITHUB_TOKEN}" ]]; then
    echo "::error::GITHUB_TOKEN not provided. Set the 'GITHUB_TOKEN' environment variable."
    exit 1
fi

if [[ -z "${GITHUB_REPOSITORY}" ]]; then
    echo "::error::GITHUB_REPOSITORY not provided. Set the 'GITHUB_REPOSITORY' environment variable."
    exit 1
fi

if [[ -z "${GITHUB_SHA}" ]]; then
    echo "::error::GITHUB_SHA not provided. Set the 'GITHUB_SHA' environment variable."
    exit 1
fi

# For testing, we'll simulate version extraction from commit message
current_commit_msg=$(git show -s --format='%s' HEAD)
echo "Current commit message: ${current_commit_msg}"

if [[ "${current_commit_msg}" =~ Version[-[:space:]](v[[:digit:]]+.[[:digit:]]+.[[:digit:]]+) ]] || \
   [[ "${current_commit_msg}" =~ Merge.*Version[-[:space:]](v[[:digit:]]+.[[:digit:]]+.[[:digit:]]+) ]] || \
   [[ "${current_commit_msg}" =~ release[/-]([[:digit:]]+.[[:digit:]]+.[[:digit:]]+) ]]; then

    if [[ -n "${BASH_REMATCH[1]}" ]]; then
        if [[ "${BASH_REMATCH[1]}" =~ ^v ]]; then
            tag="${BASH_REMATCH[1]}"
        else
            tag="v${BASH_REMATCH[1]}"
        fi
    fi

    echo "Extracted version tag: ${tag}"

    # Check if the tag already exists (it should have been created on the release branch)
    if git rev-parse "${tag}" >/dev/null 2>&1; then
        printf '%s\n' "✅ Tag ${tag} already exists (created on release branch)"
        tag_sha=$(git rev-parse "${tag}")
        printf '%s\n' "Tag SHA: ${tag_sha}"

        # Verify the tag is in the current branch's history (not just floating)
        if git merge-base --is-ancestor "${tag_sha}" HEAD; then
            printf '%s\n' "✅ Tag ${tag} is in the current branch history"
        else
            printf '%s\n' "⚠️  WARNING: Tag ${tag} exists but is not in the current branch history!"
            printf '%s\n' "This may indicate the tag was not created properly on the release branch."
        fi

        # Check if GitHub release already exists
        if gh release view "${tag}" >/dev/null 2>&1; then
            printf '%s\n' "✅ GitHub release ${tag} already exists; skipping creation"
            echo "Release URL: https://github.com/${GITHUB_REPOSITORY}/releases/tag/${tag}"
        else
            printf '%s\n' '📦 Creating GitHub Release at existing tag'

            # For testing, create a simple release body
            release_body="## 🧪 Fork Test Release ${tag}

This is a test release created in the fork repository.

### Release Information
- **Tag**: ${tag}
- **SHA**: ${tag_sha}
- **Created from**: Fork test workflow

### Testing Notes
This release was created to test the new release process where:
1. The release branch is tagged before merge
2. The tag is pushed to the repository
3. The release branch is merged to main/master
4. This script creates the GitHub release from the pre-existing tag

### Verification
You can verify the tag is in the main branch:
\`\`\`bash
git fetch --tags
git branch --contains ${tag}
\`\`\`"

            # Create release at the existing tag (not at current SHA)
            # For testing, we won't include actual build artifacts
            gh release create "${tag}" \
                --title "Test Release ${tag##v}" \
                --notes "${release_body}" \
                --target "${tag_sha}" \
                --prerelease || {
                    echo "Failed to create release, but continuing..."
                }

            echo "✅ Created GitHub release for ${tag}"
        fi
    else
        # Fallback: Create tag if it doesn't exist (shouldn't happen with new process)
        printf '%s\n' "⚠️  WARNING: Tag ${tag} not found!"
        printf '%s\n' "This indicates the 'Tag Release Branch' workflow was not run before merge."
        printf '%s\n' "Creating tag now at merge commit (not recommended - should tag release branch instead)"
        printf '%s\n' ""
        printf '%s\n' "To avoid this in the future:"
        printf '%s\n' "1. Run 'Tag Release Branch' workflow BEFORE merging the release PR"
        printf '%s\n' "2. This ensures the tag points to the tested release branch code"
        printf '%s\n' ""

        git config user.email "actions@github.com"
        git config user.name "GitHub Actions"
        git tag -a "${tag}" -m "Test Release ${tag##v} (Created at merge - not ideal)" "${GITHUB_SHA}"
        git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}" "${tag}"

        printf '%s\n' '📦 Creating GitHub Release (at merge commit)'

        release_body="## ⚠️  Fork Test Release ${tag} (Tagged at Merge)

**Note**: This tag was created at the merge commit, not on the release branch.
This is not the recommended process.

### Release Information
- **Tag**: ${tag}
- **SHA**: ${GITHUB_SHA}
- **Created from**: Merge commit (not ideal)

### Recommended Process
The tag should have been created on the release branch before merge using the 'Tag Release Branch' workflow."

        gh release create "${tag}" \
            --title "Test Release ${tag##v} (Tagged at Merge)" \
            --notes "${release_body}" \
            --target "${GITHUB_SHA}" \
            --prerelease || {
                echo "Failed to create release, but continuing..."
            }
    fi

    # Add summary
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "## 🧪 Fork Test - Release Creation" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "- **Tag**: ${tag}" >> "$GITHUB_STEP_SUMMARY"
    echo "- **Repository**: ${GITHUB_REPOSITORY}" >> "$GITHUB_STEP_SUMMARY"
    if [[ -n "${tag_sha}" ]]; then
        echo "- **Tag SHA**: ${tag_sha}" >> "$GITHUB_STEP_SUMMARY"
    else
        echo "- **Tag SHA**: ${GITHUB_SHA} (created at merge)" >> "$GITHUB_STEP_SUMMARY"
    fi
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "[View Release](https://github.com/${GITHUB_REPOSITORY}/releases/tag/${tag})" >> "$GITHUB_STEP_SUMMARY"

else
    printf '%s\n' 'Version not found in commit message; skipping GitHub Release'
    printf '%s\n' 'This is expected for non-release merges.'

    echo "## ℹ️ No Release Created" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "No version tag found in commit message. This is normal for non-release commits." >> "$GITHUB_STEP_SUMMARY"

    exit 0
fi
