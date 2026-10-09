Fixtures for tests/grill.sh. All text is invented. `ok/` is a finished /grill-with-docs run: words, a sealed
intent, a transcript, and the two candidate files. Each `bad-` folder is `ok/` with one change.

| Folder | The one change | Expect |
|---|---|---|
| bad-unsaid-line | I1 says more than the words file | intent FAIL TG1 |
| bad-no-recommendation | a question has no `Recommended:` line | transcript FAIL TR1 |
