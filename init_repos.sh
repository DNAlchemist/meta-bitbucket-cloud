#!/usr/bin/env sh
set -e

VERSION="1.0.0"

if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
  echo
  echo "  Usage: sh init_repos.sh [options] [project_name]"
  echo
  echo "  Options:"
  echo "    -v, --version        output the version number"
  echo "    -h, --help           output usage information"
  echo
  echo "  Environment:"
  echo "    BITBUCKET_WORKSPACE  bitbucket workspace"
  echo "    BITBUCKET_USERNAME   bitbucket username (exactly username, not a email)"
  echo "    BITBUCKET_TOKEN      bitbucket app password"
  exit 0
fi

if [[ $1 == "--version" ]] || [[ $1 == "-v" ]]; then
  echo $VERSION
  exit 0
fi

if [ -z $BITBUCKET_TOKEN ]; then
  echo "BITBUCKET_TOKEN should be set"
  exit 1
fi

if [ -z $BITBUCKET_USERNAME ]; then
  echo "BITBUCKET_USERNAME should be set"
  exit 1
fi

if [ -z $BITBUCKET_WORKSPACE ]; then
  echo "BITBUCKET_WORKSPACE should be set"
  exit 1
fi

BITBUCKET_API_URL=https://api.bitbucket.org/2.0
BITBUCKET_SSH_URL=git@bitbucket.org:$BITBUCKET_WORKSPACE

function fetch_projects() {
  local projects=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_TOKEN" \
    -H "Content-Type: application/json" \
    -X GET "$BITBUCKET_API_URL/workspaces/$BITBUCKET_WORKSPACE/projects" | jq -r .values[].key)
  echo $projects
}

function fetch_repositories() {
  local project=$1
  fetch_repositories_by_link "$BITBUCKET_API_URL/repositories/$BITBUCKET_WORKSPACE?q=project.key=\"`echo "$project" | tr '[:lower:]' '[:upper:]'`\""
}

function fetch_repositories_by_link() {
  local link=$1
  echo >&2 "$link"

  local repositories=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_TOKEN" \
    -H "Content-Type: application/json" \
    -X GET $link | jq -r '.values[].name')
  echo $repositories

  local nextLink=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_TOKEN" \
    -H "Content-Type: application/json" \
    -X GET $link | jq -r .next)

  if [ "$nextLink" == "" ]; then
    echo >&2 "Unexpected response: $json"
    exit 1
  fi

  if [ "$nextLink" != "null" ]; then
    fetch_repositories_by_link $nextLink
  fi
}

rm -rf .gitignore .meta
meta init

if [ -z $1 ]; then
  projects=$(fetch_projects)
else
  projects=$1
fi

for project in $projects; do
  echo ">>> Fetching repositories for project $project"
  repositories=$(fetch_repositories $project)
  project_lowercase=$(echo "$project" | tr '[:upper:]' '[:lower:]')
  for repository in $repositories; do
    project_repository=$(echo "$repository" | tr '[:upper:]' '[:lower:]')
    echo $repository
    meta project import $project_lowercase/$repository $BITBUCKET_SSH_URL/$project_repository.git
  done
done

echo "Done!"
