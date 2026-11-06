# BLOCKED — git push to origin

**Status:** Push blocked; all work is committed locally on its feature branch.

## Exact error
```
$ git push -u origin feature/project-foundation
remote: Permission to studiojrba/Playrite.git denied to jr-resilia.
fatal: unable to access 'https://github.com/studiojrba/Playrite.git/': The requested URL returned error: 403
```

## Cause
`git clone` (anonymous read) succeeded. Pushing uses the `gh` credential helper, whose **active** account is
`jr-resilia`, which has no write access to `studiojrba/Playrite`. The `studiojrba` account is also logged in to
`gh` but inactive. Claude was not permitted to read or route that account's token, so it did not push.

## To unblock (run in the morning)
```bash
gh auth switch --user studiojrba
```
```bash
cd ~/Projects/Playrite && for b in $(git for-each-ref --format='%(refname:short)' refs/heads/feature/); do git push -u origin "$b"; done
```
Then switch back if needed: `gh auth switch --user jr-resilia`.
