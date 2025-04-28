#!/usr/bin/env bash

# Function to show usage/help
show_help() {
  cat <<-EOF
Usage: $0 [OPTIONS] PATTERN FILE

Search for PATTERN in FILE (case-insensitive).

Options:
  -n        Show line numbers
  -v        Invert match (show non-matching lines)
  --help    Display this help message
EOF
  exit 1
}

# Initialize option flags
declare -i num=0 invert=0

# Handle long option --help
if [[ "$1" == "--help" ]]; then
  show_help
fi

# Parse single-character options using getopts
while getopts ":nv" opt; do
  case $opt in
    n) num=1 ;;  # show line numbers
    v) invert=1 ;;  # invert match
    \?) echo "Invalid option: -$OPTARG" >&2; show_help ;;
  esac
done
# Remove processed options from positional parameters
shift $((OPTIND - 1))

# Validate remaining arguments
if (( $# < 2 )); then
  if (( $# == 1 )) && [[ -f "$1" ]]; then
    echo "Error: Missing search string" >&2
  else
    echo "Usage: $0 [OPTIONS] PATTERN FILE" >&2
  fi
  exit 1
fi
pattern=$1; file=$2

# Check file exists
if [[ ! -f "$file" ]]; then
  echo "Error: File '$file' not found" >&2
  exit 1
fi

# Enable case-insensitive matching & Start Searching procrss
shopt -s nocasematch
lineno=0
while IFS= read -r line; do
  (( lineno++ ))

  # Determine if the line matches PATTERN
  if [[ $line == *"$pattern"* ]]; then
    # grep uses 0 to refer to found
    match=0
  else
    match=1
  fi

  # Apply invert flag
  if (( invert == 1 )); then
    cond=$(( 1 - match )) # if match=0(found) then we invert it (1 - 0) = 0 (not found) ,,, and vice versa
  else
    cond=$match 
  fi

  # Print line if condition satisfied
  if (( cond == 0 )); then
    if (( num == 1 )); then
      printf "%d:%s\n" "$lineno" "$line"
    else
      printf "%s\n" "$line"
    fi
  fi
done < "$file"
shopt -u nocasematch
