# IMVE review data inputs

- `canada.tsv` adds cited Canadian public terminology, events, names and RCMP-reported identifiers.
- `NVE-RESEARCH-PILOT.tsv` is the public-source pilot documented in `docs/imve-review/`.
- `context-mentions.tsv` adds opt-in threat, incident, sport, first-aid and historical references.
- `zero-nihl.tsv` is the ZERO_NIHL masterlist from commit [5189406](https://github.com/jeyapalc/ZERO_NIHL/blob/5189406a8a92951422e3c4be5052009e67cb041f/lists/masterlist.tsv).
- `zero-naz.tsv` is the ZERO_NAZ masterlist from commit [7cc8d09](https://github.com/jeyapalc/ZERO_NAZ/blob/7cc8d095dc2928977dd14ea2d40bda3ce2ba0b2e/lists/masterlist.tsv).
- The ZERO_FAITH masterlist is read directly from `lists/masterlist.tsv` in this branch.

Run `python tools/build.py` and `python tools/build_imve_review.py` from the repository root to rebuild the cited TSVs, text files and ZIP. The builder consolidates identical case-insensitive spellings and keeps source IDs, citations and review notes. It carries forward the source selection and keeps the codes and symbols category opt-in. Review coverage in both the default and complete passes when refreshing the inputs.
