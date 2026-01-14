# Augentix SoC – `/bin` Executables

This directory contains a selection of executable binaries found in the
`/bin` directory of an Augentix-based SoC.

These programs appear to be internal utilities and diagnostic tools provided
by the vendor. At the time of writing, **no official documentation is
available** for any of them.

Static analysis and reverse engineering have shown that **some of these
executables are reduced or modified builds of well-known open-source
software**, in particular components from projects such as *wireless-tools
(iwconfig/iwlist)* and *hostapd*. In several cases, **copyright notices,
license texts, and attribution have been removed**, which constitutes a
**clear violation of the GNU General Public License (GPL)** under which these
programs were originally released.

The manual pages included alongside these binaries are **unofficial** and
**best-effort** reconstructions. They are based on static analysis, limited
runtime testing, and reverse-engineering of the executables, as well as
comparison with their upstream open-source counterparts.

The purpose of this collection is to:
- record observed behaviour and command interfaces,
- document the relationship between the firmware binaries and their
  upstream open-source origins,
- provide a starting point for further analysis,
- and make otherwise opaque system tools more approachable.

All information should be considered **preliminary** and **subject to change**.
Nothing here should be assumed to be complete or authoritative.

Use with due caution.
