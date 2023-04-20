#!/bin/bash

aws ec2 describe-network-insights-paths --query 'NetworkInsightsPaths[*].[NetworkInsightsPathId]' --output text \
| while read insights_path; do
  aws ec2 start-network-insights-analysis --network-insights-path-id $insights_path
done