# Pass-through alias to automate MFA. Useful if your account requires MFA for
# CLI use. Put your MFA serial into ~/.aws/mfa-serial and it should just work!
# This obviously won't work if you need access to multiple accounts. I also
# currently need to assume roles as well, so this tool is currently on ice.

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

# Uncomment to enable the alias
#alias aws=aws_mfa


# Given a profile, prompts for an MFA token, then fetches temporary credentials
# using the user's first MFA device and stores them in the appropriate
# environment variables.

aws-activate() {
  if [ -z "$1" ]; then
    echo "Usage: aws_activate PROFILE"
    return 1
  fi

  local current_user="$(aws --profile "$1" sts get-caller-identity \
    | jq -r '.Arn' \
    | sed -r 's%arn:aws:iam::[0-9]+:user/(.+)%\1%')"
  [ -z "$current_user" ] && return 1

  local mfa_serial="$(aws --profile "$1" iam list-mfa-devices --user-name "$current_user" \
    | jq -r '.MFADevices[0].SerialNumber')"
  [ -z "$mfa_serial" ] && return 1

  read -p "MFA token: " token
  local creds="$(aws --profile "$1" sts get-session-token --serial-number "$mfa_serial" --token-code $token)"
  export AWS_ACCESS_KEY_ID="$(    echo "$creds" | jq -r '.Credentials.AccessKeyId')"
  export AWS_SECRET_ACCESS_KEY="$(echo "$creds" | jq -r '.Credentials.SecretAccessKey')"
  export AWS_SESSION_TOKEN="$(    echo "$creds" | jq -r '.Credentials.SessionToken')"
}
