# Install just: https://github.com/casey/just

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

CHART_DIR := "chart"
TEST_GLOB := "tests/**/*_test.yaml"

default:
  @just --list

install-unittest:
  @if helm plugin list | awk '{print $1}' | grep -qx 'unittest'; then \
    echo "helm-unittest already installed"; \
  else \
    helm plugin install https://github.com/helm-unittest/helm-unittest; \
  fi

test: install-unittest
  helm unittest {{CHART_DIR}} -f {{TEST_GLOB}}
