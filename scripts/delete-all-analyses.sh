#!/bin/bash

aws ec2 describe-network-insights-paths --query 'NetworkInsightsPaths[*].[NetworkInsightsPathId]' --output text \
| while read insights_path; do
  aws ec2 describe-network-insights-analyses --network-insights-path-id $insights_path --query 'NetworkInsightsAnalyses[*].[NetworkInsightsAnalysisId]' --output text \
  | while read insights_analysis; do
    aws ec2 delete-network-insights-analysis --network-insights-analysis-id $insights_analysis
  done
done