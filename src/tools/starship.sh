#!/usr/bin/env bash

install_starship() {
  if ! is_pkg_installed starship; then
    mark_start "Install Starship" -t$PACKAGE

    retry_if_failed curl -sS https://starship.rs/install.sh | sh -s -- -y
    [ $? -eq 0 ] && {

      if test $shell = fish; then
        sed -i '$ a\\nstarship init fish | source' ~/.config/fish/config.fish
      elif test $shell = bash; then
        sed -i '$ a\\neval "$(starship init bash)"' ~/.bashrc
      elif test $shell = zsh; then
        sed -i '$ a\\neval "$(starship init zsh)"' ~/.zshrc
      fi
    } || failed_pkgs+=('starship')

    if ! -f ~/.config/starship.toml; then
      cat >~/.config/starship.toml <<EOF
format = """
[](color_os)\\
\$os\\
[](bg:color_dir fg:color_os)\\
\$directory\\
[](fg:color_dir bg:color_git)\\
\$git_branch\\
\$git_status\\
[ ](fg:color_git)\\
"""

# Disable the blank line at the start of the prompt
# add_newline = false

right_format = """
EOF

      if test $aws_cli = true; then
        cat >>~/.config/starship.toml <<EOF
[](fg:color_aws)\\
\$aws\\
[](fg:color_node bg:color_aws)\\
\$c\\
\$elixir\\
\$elm\\
\$golang\\
\$gradle\\
\$haskell\\
\$java\\
\$julia\\
\$nodejs\\
\$nim\\
\$rust\\
\$scala\\
[](fg:color_docker bg:color_node)\\
EOF
      else
        cat >>~/.config/starship.toml <<EOF
[](fg:color_node)\\
\$c\\
\$elixir\\
\$elm\\
\$golang\\
\$gradle\\
\$haskell\\
\$java\\
\$julia\\
\$nodejs\\
\$nim\\
\$rust\\
\$scala\\
[](fg:color_docker bg:color_node)\\
EOF
      fi

      cat >>~/.config/starship.toml <<EOF
\$docker_context\\
[](fg:color_time bg:color_docker)\\
\$time\\
[](color_time)\\
"""

# continuation_prompt = '▶▶ '

palette = 'rox'

[palettes.rox]
color_os = '#9A348E'
color_dir = '#DA627D'
color_git = '#FCA17D'
color_time = '#33658A'
color_docker = '#06969A'
color_node = '#86BBD8'
color_aws = '#FF9900'

[aws]
format = '[ \$symbol(\$profile )(\(\$region\) )](\$style)'
style = 'italic bg:color_aws'
symbol = ' '
[aws.region_aliases]
# put your region aliases below
ap-south-1 = 'ap'
us-east-1 = 'ue'
[aws.profile_aliases]
# put your profile aliases below. For example: org-dev = 'dev' where org-dev is the aws profile name and dev is what you want to see on the prompt

# You can also replace your username with a neat symbol like   or disable this
# and use the os module below
[username]
show_always = true
style_user = "bg:color_os"
style_root = "bg:color_os"
format = '[\$user ](\$style)'
disabled = false

# An alternative to the username module which displays a symbol that
# represents the current operating system
[os]
style = "bg:color_os"
disabled = false # Disabled by default

[directory]
style = "bg:color_dir"
format = "[ \$path ](\$style)"
truncation_length = 3
truncation_symbol = "…/"

# Here is how you can shorten some long paths by text replacement
# similar to mapped_locations in Oh My Posh:
[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "
# Keep in mind that the order matters. For example:
# "Important Documents" = " 󰈙 "
# will not be replaced, because "Documents" was already substituted before.
# So either put "Important Documents" before "Documents" or use the substituted version:
# "Important 󰈙 " = " 󰈙 "

[c]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[docker_context]
symbol = " "
style = "bg:color_docker"
format = '[ \$symbol \$context ](\$style)'

[elixir]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[elm]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[git_branch]
symbol = ""
style = "bg:color_git"
format = '[ \$symbol \$branch ](\$style)'

[git_status]
style = "bg:color_git"
format = '[\$all_status\$ahead_behind ](\$style)'

[golang]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[gradle]
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[haskell]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[java]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[julia]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[nodejs]
symbol = ""
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[nim]
symbol = "󰆥 "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[rust]
symbol = ""
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[scala]
symbol = " "
style = "bg:color_node"
format = '[ \$symbol (\$version) ](\$style)'

[time]
disabled = false
time_format = "%R" # Hour:Minute Format
style = "bg:color_time"
format = '[ ♥ \$time ](\$style)'

[os.symbols]
AIX = "➿ "
Alpaquita = "🔔 "
AlmaLinux = "💠 "
Alpine = "🏔️ "
Amazon = "🙂 "
Android = "🤖 "
Arch = "🎗️ "
Artix = "🎗️ "
CentOS = "💠 "
Debian = "🌀 "
DragonFly = "🐉 "
Emscripten = "🔗 "
EndeavourOS = "🚀 "
Fedora = "🎩 "
FreeBSD = "😈 "
Garuda = "🦅 "
Gentoo = "🗜️ "
HardenedBSD = "🛡️ "
Illumos = "🐦 "
Kali = "🐉 "
Linux = "🐧 "
Mabox = "📦 "
Macos = "🍎 "
# Manjaro = "🥭 "
Manjaro = "🥸 "
Mariner = "🌊 "
MidnightBSD = "🌘 "
Mint = "🌿 "
NetBSD = "🚩 "
NixOS = "❄️ "
OpenBSD = "🐡 "
OpenCloudOS = "☁️ "
openEuler = "🦉 "
openSUSE = "🦎 "
OracleLinux = "🦴 "
Pop = "🍭 "
Raspbian = "🍓 "
Redhat = "🎩 "
RedHatEnterprise = "🎩 "
RockyLinux = "💠 "
Redox = "🧪 "
Solus = "⛵ "
SUSE = "🦎 "
# Ubuntu = "🎯 "
Ubuntu = "🥸 "
Ultramarine = "🔷 "
Unknown = "❓ "
Void = "  "
Windows = "🪟 "

EOF
    fi
    mark_end "Install Starship" -t$PACKAGE
  fi
}
