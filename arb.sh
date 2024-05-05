#!/bin/bash

# Usage message function
usage() {
  echo "Usage: ./arb.sh --ticker TICKER1 [TICKER2 ...] --start/--stop"
  exit 1
}

# Check the minimum number of arguments
if [ "$#" -lt 3 ]; then
  usage
fi

# Initialize variables
declare -a TICKERS
ACTION=""
PARSE_TICKERS=false

# Parse command line arguments
for arg in "$@"; do
  if $PARSE_TICKERS; then
    if [[ "$arg" == "--start" || "$arg" == "--stop" ]]; then
      PARSE_TICKERS=false
    else
      TICKERS+=("$arg")
      continue
    fi
  fi

  case "$arg" in
    --ticker)
      PARSE_TICKERS=true
      ;;
    --start)
      ACTION="up -d"
      ;;
    --stop)
      ACTION="down"
      ;;
    *)
      if ! $PARSE_TICKERS; then
        echo "Unknown option: $arg"
        usage
      fi
      ;;
  esac
done

# Ensure action is specified
if [ -z "$ACTION" ]; then
  echo "Error: You must specify --start or --stop"
  usage
fi

# Perform actions based on parsed arguments
if [ "${TICKERS[0]}" = "ALL" ]; then
  # Apply action to all services
  docker-compose $ACTION
else
  # Apply action to specific services using all tickers at once
  if [ "$ACTION" = "up -d" ]; then
    docker-compose up -d "${TICKERS[@]}"
  else
    docker-compose down "${TICKERS[@]}"
  fi
fi

echo "Operation completed: $ACTION for ${TICKERS[*]}"
