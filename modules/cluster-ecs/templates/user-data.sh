#!/bin/bash
set -ex

# ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo "ECS_ENABLE_CONTAINER_METADATA=true"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
