Fixtures for tests/taste.sh. All text is invented. `ok/` passes every command; each other folder is `ok/`
with one change. The `bad-` folders must make the named check FAIL (and only that check); the `warn-` folders
must still exit 0 and print the named WARN.

| Folder | The one change | Expect |
|---|---|---|
| bad-unsaid-line | I1 says more than the words file | intent FAIL TG1 |
| bad-unsealed | no `approved:` line | intent FAIL TG2 |
| bad-edited-after-seal | I3 and the words file both edited after the seal | intent FAIL TG2 |
| bad-blocking-open | approved while a `blocking:` question is open | intent FAIL TG2; seal refuses |
| warn-date-only | `approved:` has a date but no who/hash | intent WARN TG2 |
| bad-spec-number | "under 150 kb gzipped" became "small" | spec FAIL TG3 (number and bound) |
| bad-spec-quoted | I1 has a quoted label the spec drops | spec FAIL TG3 |
| bad-spec-negation | "never alters" became "alters" | spec FAIL TG3 |
| bad-spec-only | I1 ends "only"; the spec lacks the word | spec FAIL TG3 |
| bad-spec-uncovered | no A, scope or open line mentions I4 | spec FAIL CHAIN |
| bad-spec-orphan | A3 has no (I..) citation | spec FAIL CHAIN |
| bad-result-missing-row | I3 has no row | result FAIL TG4 |
| bad-result-extra-row | a row for I9, which does not exist | result FAIL TG4 |
| bad-result-outcome | outcome `done` | result FAIL TG4 |
| bad-result-no-evidence | delivered with `-` | result FAIL TG5 |
| bad-result-dead-file, -dead-line, -dead-heading, -dead-test | pointer to nothing | result FAIL TG5 |
| bad-result-no-unrequested | no Unrequested section | result FAIL TG6 |
| warn-result-url | evidence is a URL | result WARN TG5 |

`transcripts/` holds an intent interview that passes, a five-question round that is still allowed, and one that breaks each of TR1 to TR5.
`asks/` holds a vague ask and a precise one.
