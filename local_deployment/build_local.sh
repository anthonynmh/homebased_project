#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Export variables from .env
set -a
source "$ENV_FILE"
set +a

# Build --dart-define arguments from .env
DART_DEFINES=()
while IFS='=' read -r key value; do
    # Skip empty lines or comments
    [[ -z "$key" || "$key" == \#* ]] && continue
    # Quote value to prevent shell splitting
    DART_DEFINES+=(--dart-define="$key=$value")
done < "$ENV_FILE"

# Run Flutter build
echo "Running Flutter build web --release ..."
flutter build web --release "${DART_DEFINES[@]}"
