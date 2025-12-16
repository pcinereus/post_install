Murray's post-install setup
===============================

## Post-install bootrap

1. Ensure `curl` is installed, if not install (prob only relevant for arch)

```
pacman -Syu --noconfirm
pacman -S curl
```

2. Use `curl` to run an install script (from github)

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/pcinereus/post_install/main/bootstrap.sh)"
```

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
