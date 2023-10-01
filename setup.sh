#!/bin/bash

function cleanup_branches() {
    # Check if the base branch already exists
    if git show-ref --quiet refs/heads/base; then
        echo "Branch 'base' already exists."
    else
        # Create the branch
        git checkout -b base
        echo "Branch base created."
    fi

    # Set the target branches in an array
    target_branches=("develop-rebase" "develop-merge" "feature/custom-tours-merge" "feature/custom-tours-rebase")

    # Get all branches
    all_branches=$(git branch -a | sed 's/^\*\? \?//')  # Remove '*' and spaces from branch names

    # Loop through all fixed branches and delete
    for branch in $all_branches; do
        # Check if the branch exactly matches any of the specified target branches
        for target_branch in "${target_branches[@]}"; do
            if [ "$branch" == "$target_branch" ]; then
                git branch -D $branch
                echo "Deleted branch '$branch'."
                break  # Break out of the inner loop once a match is found
            fi
        done

        # Delete pivotal branches (partial match)
        if [[ $branch == "pivotal"* ]]; then
            git branch -D $branch
            echo "Deleted branch '$branch'."
        fi
    done
}

cleanup_branches

# Create the branches
suffixes=("merge" "rebase")

# for each suffix checkout an orphan branch and commit 5 times
for suffix in "${suffixes[@]}"; do
    # N.B. Had a strange issue where checkout wasn't switching branches hence the double checkouts
    git checkout --orphan develop-$suffix
    git checkout develop-$suffix

    for i in {1..5}; do
        git commit --allow-empty -m "develop-$suffix commit $i"
    done

    git checkout -b feature/custom-tours-$suffix
    git checkout feature/custom-tours-$suffix

    # Debug: echo the current branch
    echo "Current branch: $(git branch | grep \* | cut -d ' ' -f2)"
    
    for i in {1..5}; do
        git commit --allow-empty -m "feature/custom-tours-$suffix commit $i"
    done

    # create 5 pivotal branches
    for i in {1..5}; do
        git checkout -b pivotal-$suffix-$i
        git checkout pivotal-$suffix-$i
        for j in {1..5}; do
            git commit --allow-empty -m "pivotal-$suffix-$i commit $j"
            # Possibly not neccessary but I had some strange ordering issues
            sleep 1            
        done
        git checkout feature/custom-tours-$suffix
    done
done

git checkout feature/custom-tours-merge

# Merge in each pivotal branch (using no-ff to ensure a merge commit is created)
for i in {1..5}; do
    git merge --no-ff -m "Merge branch 'pivotal-merge-$i' into feature/custom-tours-merge" pivotal-merge-$i
done

# Merge the feature/custom-tours-merge branch into develop
git checkout develop-merge
git merge --no-ff -m "Merge branch 'feature/custom-tours-merge' into develop-merge" feature/custom-tours-merge

# Similar to above but with rebase first for each pivotal branches
for i in {1..5}; do
    git checkout pivotal-rebase-$i
    git rebase feature/custom-tours-rebase
    git checkout feature/custom-tours-rebase
    git merge --no-ff -m "Merge branch 'pivotal-rebase-$i' into feature/custom-tours-rebase" pivotal-rebase-$i
done

# Merge the feature/custom-tours-rebase branch into develop
git checkout develop-rebase
git merge --no-ff -m "Merge branch 'feature/custom-tours-rebase' into develop-rebase" feature/custom-tours-rebase