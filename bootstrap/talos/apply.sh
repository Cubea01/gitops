#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [--insecure]"
  exit 1
}

# Function to apply config for a node
apply_config() {
  node="$1"
  config="$2"
  insecure="$3"
  
  echo "Applying config for node $node from $config"
  talosctl apply-config -n "$node" -f "$config" $insecure
  return $?
}

# Check for the --insecure flag
if [ "$1" == "--insecure" ]; then
  insecure="--insecure"
elif [ ! -z "$1" ]; then
  usage
fi

# Define the list of nodes and their respective config files
nodes=("10.0.6.3" "10.0.6.4" "10.0.6.5")
configs=("k8s-k8s-node1.akchristiansen.com.yaml" "k8s-k8s-node2.akchristiansen.com.yaml" "k8s-k8s-node3.akchristiansen.com.yaml")

# Loop through nodes and apply config, handling errors
for i in "${!nodes[@]}"; do
  node="${nodes[$i]}"
  config="./clusterconfig/${configs[$i]}"
  
  if apply_config "$node" "$config" "$insecure"; then
    echo "Config applied successfully for node $node"
  else
    echo "Failed to apply config for node $node"
  fi
done
