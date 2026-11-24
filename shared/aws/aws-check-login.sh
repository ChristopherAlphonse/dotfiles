#!/usr/bin/env bash
# Check whether the AWS CLI has valid credentials.
# Usage: aws-check-login.sh [profile]   (no profile = $AWS_PROFILE or default)
# Exit 0 when logged in, 1 when not.

profile_args=()
[ -n "$1" ] && profile_args=(--profile "$1")

if identity=$(aws sts get-caller-identity "${profile_args[@]}" --output text \
    --query '[Account,Arn]' 2>&1); then
  read -r account arn <<<"$identity"
  echo "Logged in to AWS"
  echo "  profile: ${1:-${AWS_PROFILE:-default}}"
  echo "  account: $account"
  echo "  arn:     $arn"
else
  echo "Not logged in to AWS, or the session expired. Log in again (SAML, SSO or 'aws login')." >&2
  echo "  $identity" >&2
  exit 1
fi
