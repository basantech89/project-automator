install_google_chrome() {
  if ! is_pkg_installed google-chrome-stable; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs google-chrome
    elif [ "$package_manager" = 'apt-get' ]; then
      install_dpkg_pkg https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask google-chrome
    fi
  fi
}

install_brave_browser() {
  if ! is_pkg_installed brave; then
    if [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask brave-browser
    else
      mark_start "Installing Brave Browser" -t$TITLE
      curl -fsS https://dl.brave.com/install.sh | sh
      mark_end "Installing Brave Browser" -t$TITLE
    fi
  fi
}
