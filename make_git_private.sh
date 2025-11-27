#!/bin/bash

USERNAME="ChristopherAlphonse"  # Replace with your GitHub username

# Make sure you're logged in with `gh auth login`

for repo in $(gh repo list "$USERNAME" --limit 100 --json name --jq '.[].name'); do
    echo "Changing $repo to private..."
    gh repo edit "$USERNAME/$repo" \
        --visibility private \
        --accept-visibility-change-consequences
done

echo "All repositories processed."

