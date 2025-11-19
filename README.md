# Alamahant Overlay

The **alamahant-overlay** provides additional ebuilds that are not available in the main Gentoo repository.  
It contains personal, experimental, and supplemental packages maintained by **Alamahant**.

---

## Adding the Overlay

This overlay is **not enabled by default**.  
Enable it using **eselect-repository** (recommended modern method):

    eselect repository add alamahant-overlay git https://github.com/alamahant/alamahant-overlay.git
    emaint sync -r alamahant-overlay

---

## Packages Provided

This overlay includes:

- Personal ebuilds maintained by **Alamahant**
- Experimental or work-in-progress software
- Additional utilities not found in ::gentoo

See the repository tree for a full package list.

---

## Bug Reports / Contributions

Issues and PRs welcome:  
https://github.com/alamahant/alamahant-overlay

---

## License

Licensing is per-package as defined in the included ebuilds.
