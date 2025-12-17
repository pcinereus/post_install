Murray's post-install setup
===============================

## Post-install bootstrap

1. Ensure `curl` is installed, if not install (prob only relevant for arch).  This step is only required if `curl` is not installed.

```
pacman -Syu --noconfirm
pacman -S curl
```

2. Use `curl` to run an install script (from github)

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/pcinereus/post_install/main/bootstrap.sh)"
```

If you are on a fresh arch install, you may be prompted to provide a
name for a user and a password for this user and then you will be asked
to switch to this user and run the script again (as this user).

This script will:

- clone this `post_install.git repo` at `~/post_install`
- start the software install script that will install the
  software listed in `post_install/install/packages.conf`

Some of the software have different names on different distributions
and therefore, some of the software are suffixed with distribution
names.

## WSL

### Installing WSL

```
wsl --install --no-distribution
```

It'll require you to enter your login details twice then it'll need a
Restart of the computer

### Listing WSL instances (distributions)

```
wsl --list --verbose
wsl -l -v
```

### Start an existing WSL instance (e.g. Debian)

```
wsl -d Debian
```

### Stop all WSL instances

```
wsl --shutdown
```

### Delete a WSL instance (e.g. Arch)

```
wsl --unregister Arch
```

### Creating a new WSL instance (e.g. Debian)

1. To see a list of available linux distributions through the online
   store

```
wsl --list --online
```

2. Install Debian

```
wsl --install -d Debian
```

3. To give it a new name, and thus permit multiple Debian instances

  - a. export instance

```
wsl --export <DistroName> "$env:USERPROFILE\Downloads\<DistroName>-backup.tar"
```

  - b. import image

```
mkdir C:\WSL
$InstallDir = "C:\WSL\<Name>"
wsl --import <NewName> $InstallDir "$env:USERPROFILE\Downloads\<DistroName>-backup.tar"  --version 2
```

4. If you have installed archlinux, you will also want to set the root password

```
passwd
```
