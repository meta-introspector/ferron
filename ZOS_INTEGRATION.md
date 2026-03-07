# Ferron + ZOS Integration Report

## Overview

This fork contains our work integrating Ferron with the ZOS (Zero Ontology System) project. We successfully deployed Ferron 1.x as a reverse proxy running from Nix store, and discovered issues with Ferron 2.x that we'd like to report upstream.

## What We Built

✅ **Production Deployment**
- Ferron 1.3.9 running from Nix store
- Systemd service on port 8446
- Reverse proxy to ZOS on port 8081
- Configuration managed in `/etc/ferron/`

## Working Configuration

### Ferron 1.x (WORKS)

```yaml
global:
  loadModules:
    - rproxy
  port: 8446
  proxyTo: http://127.0.0.1:8081
```

**Result**: ✅ Successfully proxies all requests to ZOS

### Test
```bash
curl http://solana.solfunmeme.com:8446/
# Returns content from ZOS on port 8081
```

## Issues Discovered

### Issue 1: Ferron 2.x + Monoio - Permission Denied

**Severity**: Critical  
**Version**: 2.5.5 (develop-2.x)  
**Runtime**: monoio

**Problem**: Ferron 2.x fails to bind to ANY port with "Permission denied (os error 13)", even high ports (>1024) and even as root.

**Error**:
```
Error while running a server: Cannot listen to HTTP port: Permission denied (os error 13)
```

**Environment**:
- Kernel: 6.8.0-94-generic
- io_uring: enabled (`/proc/sys/kernel/io_uring_disabled = 0`)
- SELinux: disabled
- Tested as: root and regular user
- Tested ports: 8446, 9000, 18446

**Monoio Fork**:
We forked monoio to fix a Nix build issue:
- Fork: https://github.com/meta-introspector/monoio/tree/fix-nix-build
- Change: Removed `#![doc = include_str!("../../README.md")]` from `monoio/src/lib.rs`
- This was the ONLY change - purely documentation

**Hypothesis**: Either monoio requires specific Linux capabilities we're missing, or the doc change somehow affected initialization.

### Issue 2: Ferron 1.x - Host-Based Routing Returns 404

**Severity**: Medium  
**Version**: 1.3.9 (main)

**Problem**: When using `hosts:` section with domain matching, all requests return 404. Global `proxyTo` works perfectly.

**Non-Working Config**:
```yaml
global:
  loadModules:
    - rproxy
  port: 8446

hosts:
  - domain: solana.solfunmeme.com
    locations:
      - path: /zos
        proxyTo: http://127.0.0.1:8081
```

**Result**: 404 Not Found (not proxied)

**Working Config**:
```yaml
global:
  loadModules:
    - rproxy
  port: 8446
  proxyTo: http://127.0.0.1:8081
```

**Result**: ✅ Proxied correctly

**Testing**: Tried with explicit Host header, IP address, localhost - all return 404 with host-based config.

## Nix Build Support

We added `flake.nix` for reproducible Nix builds:

```nix
{
  description = "Ferron web server";
  
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = 
      nixpkgs.legacyPackages.x86_64-linux.rustPlatform.buildRustPackage {
        pname = "ferron";
        version = "2.5.5";
        src = ./.;
        buildFeatures = [ "config-yaml-legacy" ];
        cargoLock = {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "async-compression-0.4.36" = "sha256-5rNEP5A7ahy+wv2U+lkGrG1ewVFhoFREsgeiQyXZzno=";
            "cache_control-0.2.0" = "sha256-Xw8JMo5bCgLfOsjsdyOxl956ggjWqywoQZA8Liz7bKE=";
            "dns-update-0.1.6" = "sha256-V5mUHWj6qAxRVCuQ6/XyvB992iJK22f5R+YNn1/BS+I=";
            "monoio-0.2.4" = "sha256-SnYzht1J3NedIjHK0MJVZFFWfjsZ42Dwnk2UJzFN8ZQ=";
          };
        };
      };
  };
}
```

**Build**: `nix build`  
**Result**: Successfully builds Ferron 1.x and 2.x

## Deployment

### System Service
```ini
[Unit]
Description=Ferron Web Server - ZOS Proxy
After=network.target

[Service]
Type=simple
ExecStart=/nix/store/.../ferron-1.3.9/bin/ferron -c /etc/ferron/zos.yaml
Restart=always

[Install]
WantedBy=multi-user.target
```

### Status
```bash
sudo systemctl status ferron-zos
# Active: active (running)
```

## Questions for Upstream

1. **Monoio Permissions**: Does monoio require specific capabilities beyond standard socket binding?
2. **Host Matching**: Is there specific syntax required for domain matching in 1.x?
3. **Tokio Fallback**: Would you accept a PR adding tokio runtime as fallback?
4. **Nix Support**: Would you like us to contribute the flake.nix upstream?

## Our Forks

- **Ferron**: https://github.com/meta-introspector/ferron/tree/develop-2.x
- **Monoio**: https://github.com/meta-introspector/monoio/tree/fix-nix-build

## Feedback

We love Ferron! Version 1.x works great for our production use case. We'd be happy to:
- Test any fixes for the issues above
- Contribute Nix build improvements
- Help debug the monoio permission issue
- Improve documentation

## Contact

- Project: ZOS (Zero Ontology System)
- GitHub: @meta-introspector
- Use Case: Reverse proxy for distributed compute platform

---

**Status**: Ferron 1.x in production ✅  
**Date**: 2026-03-07
