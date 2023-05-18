#!/usr/bin/env bash

SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "${SCRIPT}")"

IMAGEJSON="${SCRIPTPATH}/../tests/images.json"

if ! command -v crane &> /dev/null; then
  echo Please install crane
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo Please install jq
  exit 1
fi

if ! command -v yq &> /dev/null; then
  echo Please install yq
  exit 1
fi

if ! command -v trivy &> /dev/null; then
  echo Please install trivy
  exit 1
fi

if ! command -v python3 -c 'import ruamel.yaml' &> /dev/null; then
  echo Please install python3 with the ruamel.yaml module
  exit 1
fi

if ! command -v python3 -c 'import dict_deep' &> /dev/null; then
  echo Please install python3 with the dict_deep module
  exit 1
fi

jq -r '. | keys[]' "$IMAGEJSON" | while read -r CHART; do
  jq -r ".\"${CHART}\" | keys[]" "$IMAGEJSON" | while read -r IDX; do
    QUERY=$(jq -r ".\"${CHART}\"[${IDX}].query" "$IMAGEJSON")
    FILTER=$(jq -r ".\"${CHART}\"[${IDX}].filter" "$IMAGEJSON")
    SORTFLAGS=$(jq -r ".\"${CHART}\"[${IDX}].\"sort-flags\"" "$IMAGEJSON")

    VALUES="${SCRIPTPATH}/../../charts/spire/charts/${CHART}/values.yaml"
    REGISTRY=$(yq e ".${QUERY}.registry" "$VALUES")
    REPOSITORY=$(yq e ".${QUERY}.repository" "$VALUES")
    VERSION=$(yq e ".${QUERY}.tag" "$VALUES")
    # shellcheck disable=SC2086
    LATEST_VERSION=$(crane ls "${REGISTRY}/${REPOSITORY}" | grep "${FILTER}" | sort ${SORTFLAGS}| tail -n 1)

    if trivy image "${REGISTRY}/${REPOSITORY}:${VERSION}" --exit-code 1; then
      echo No CVE found. Skipping.
      continue
    fi

    if [ "${VERSION}" != "${LATEST_VERSION}" ]; then
      echo "New image version found: ${REGISTRY}/${REPOSITORY}:${LATEST_VERSION}"
      python3 -c "import sys; from dict_deep import deep_set; import ruamel.yaml; y = ruamel.yaml.YAML(); y.indent(mapping=2, sequence=4, offset=2); y.preserve_quotes = True; d = y.load(open('${VALUES}')); deep_set(d, '${QUERY}.tag', '${LATEST_VERSION}'); y.dump(d, sys.stdout);" > /tmp/$$
      mv /tmp/$$ "${VALUES}"
    fi
  done
done
"${SCRIPTPATH}/../../helm-docs.sh"