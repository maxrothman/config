# Pass-through alias to automate MFA. Useful if your account requires MFA for
# CLI use. Put your MFA serial into ~/.aws/mfa-serial and it should just work!


aws_mfa () {
  local temp_creds_path="$HOME/.aws/temp-creds"
  local mfa_serial_path="$HOME/.aws/mfa-serial"

  # ISO dates compare lexographically!
  if [[ ! -f "$temp_creds_path" || "$(date --utc -Iseconds)" > "$(< "$temp_creds_path" jq -r .Credentials.Expiration)" ]]; then
    local mfa_token
    read -p 'MFA token: ' mfa_token
    # Escape alias, otherwise we call this function recursively!
    \aws sts get-session-token --serial-number "$(cat "$mfa_serial_path")" --token-code "$mfa_token" > "$temp_creds_path"
  fi
  local env_vars="$(< "$temp_creds_path" jq -r '.Credentials | "AWS_ACCESS_KEY_ID='"'\(.AccessKeyId)' AWS_SECRET_ACCESS_KEY='\(.SecretAccessKey)' AWS_SESSION_TOKEN='\(.SessionToken)'"'"')"
  # As above
  eval "$env_vars \aws $@"
}

alias aws=aws_mfa

