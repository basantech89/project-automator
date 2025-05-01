#!/usr/bin/env bash

install_aws_cli() {
  if ! is_pkg_installed aws; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs aws-cli-v2
    elif [ "$package_manager" = 'apt-get' ]; then
      install_pkgs --snap --classic aws-cli
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs awscli
    fi
  fi

  if [ $? -eq 0 ]; then
    if test $shell = 'fish'; then
      fish -C "complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)';exit"

      if [ ! -f ~/.config/fish/functions/aws.fish ]; then
        cat >~/.config/fish/functions/aws.fish <<EOF
function aws_checks
    if test -z \$AWS_PROFILE
        echo "AWS_PROFILE is not set."
        return 1
    end

    if test "\$AWS_PROFILE" != bp-dev -a "\$AWS_PROFILE" != bp-qa
        echo "AWS_PROFILE is neither bp-dev or bp-qa."
        return 1
    end

    if test (count \$argv) -ne 1
        echo "Expected 1 arguments, got \$(count \$argv)"
        return 1
    end
end

function aws_env_check
    set -g env \$argv[1]

    if test "\$env" != dev -a "\$env" != qa
        echo "Not allowed to get password for \$env environment."
        return 1
    end

    if test "\$env" = dev
        set -g PROFILE bp-dev
    else if test "\$env" = qa
        set -g PROFILE bp-qa
    end
end

function dbpass
    aws_checks "\$argv"
    aws_env_check "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f secret_name \$(aws secretsmanager list-secrets --profile $PROFILE --output json | jq --arg env "\$env" '.SecretList[].Name | select(contains(\$env)) | select(contains("portal"))')
    set -f secret_string \$(aws secretsmanager get-secret-value --secret-id \$(string sub -s 2 -e -1 \$secret_name) --profile \$PROFILE | jq -r '.SecretString' | jq '.')
    echo \$secret_string | jq '.'
    echo \$secret_string | jq '.password' | string sub -s 2 -e -1 | xclip -sel c
end

function ec2ip
    aws_checks "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f ip \$(aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(.Tags[].Value | contains("rds-berrybox-portal-ec2")) | .NetworkInterfaces[].Association.PublicIp' | string sub -s 2 -e -1)
    echo \$ip
    echo \$ip | xclip -sel c
end

function ssm
    aws_checks "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f name \$(aws ssm describe-parameters --parameter-filters "Key=Name,Option=Contains,Values=\$argv[1]" --query 'Parameters | [0].Name' | string sub -s 2 -e -1)
    set -f value \$(aws ssm get-parameter --name "\$name" --with-decryption --query 'Parameter.Value' | string sub -s 2 -e -1)
    echo \$value
    echo \$value | xclip -sel c
end
EOF
      fi
    fi
  fi
}
