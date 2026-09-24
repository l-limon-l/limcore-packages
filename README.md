# limcore-packages

Copies of the OpenWrt packages [LimCore](https://github.com/l-limon-l/LimCoreWRT) installs
on demand. LimCore installs them only from here, so an upstream repository going away
breaks nothing.

| Package | Upstream packaging | Original project |
|---|---|---|
| `zapret2` | [1andrevich/zapret2-openwrt](https://github.com/1andrevich/zapret2-openwrt) | [bol-van/zapret2](https://github.com/bol-van/zapret2) |
| `byedpi` | [1andrevich/ByeDPI-OpenWrt](https://github.com/1andrevich/ByeDPI-OpenWrt) | [hufrea/byedpi](https://github.com/hufrea/byedpi) |

All credit goes to the authors above; files are copied unchanged, signatures included.

A [workflow](.github/workflows/mirror.yml) checks upstream every six hours and publishes:

- **`zapret2`, `byedpi`** — rolling releases LimCore downloads from. The release title is
  the upstream version it holds. ByeDPI files lose the version from their names
  (`byedpi_<arch>.apk`), so the download URL never changes.
- **`zapret2-<tag>`, `byedpi-<tag>`** — a frozen copy of every upstream release seen.
