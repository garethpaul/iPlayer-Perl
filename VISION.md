## iPlayer Perl Vision

iPlayer Perl is a copy of `get_iplayer`, a Perl tool for accessing BBC iPlayer
TV and radio content.

The repository is useful as a preserved Perl command-line tool with install
notes, license text, a man page, and the main `get_iplayer` script.

The goal is to keep the tool understandable while respecting content access
rules, licensing, and legacy runtime assumptions.

The current focus is:

Priority:

- Preserve the command-line tool, install notes, license, and man page
- Keep security policy visible
- Avoid undocumented behavior around content access or downloads
- Maintain submodule and script structure

Next priorities:

- Document runtime and dependency expectations
- Verify the CLI help path and basic script execution
- Clarify upstream relationship and update policy
- Keep content-access behavior aligned with applicable terms and user controls

Contribution rules:

- One PR = one focused CLI, dependency, documentation, or upstream-sync change.
- Preserve license and attribution files.
- Do not add credential capture or hidden telemetry.
- Document any behavior that changes content access or storage.

## Security And Compliance

Media-access tools should be transparent about what they download, where files
are stored, and which credentials or cookies they use. Do not add hidden
credential collection or automated access beyond documented user intent.

## What We Will Not Merge For Now

- Hidden credential or cookie collection
- Content-access changes without compliance notes
- License or attribution removals
- Bulk generated downloads in the repository
