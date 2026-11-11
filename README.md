# void linux setup

personal setup script for void linux (glibc/musl).

meant to be used on a fresh installation, with my own preferences, packages, dotfiles and system configuration.

### what it does
- installs packages i use
- downloads my configs and dotfiles
- sets up my dwl environment
- configures grub and enables selected services
- offers optional installs depending on glibc or musl

### usage

run as a regular user with sudo access:

```sh
chmod +x install.sh
./install.sh
```

some files like `.bashrc` and `.bash_profile` are overwritten.

this is my personal setup, not meant for general usage.
