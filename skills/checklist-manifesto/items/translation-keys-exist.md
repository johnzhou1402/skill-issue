---
name: translation-keys-exist
created: 2026-02-17
source_pr: https://github.com/whopio/whop-monorepo/pull/3611
reviewer: self
---

# Translation Keys Exist

## Pattern to Check
Any frontend `.tsx` or `.ts` file in the diff that references `t('...')` or `t("...")` translation calls.

## What to Do
For every `t('some_key')` call in the changed code, verify the key exists in `frontend/apps/core/locales/en.json`. If a new translation key is introduced but not present in `en.json`, flag it — the UI will render the raw key name instead of user-friendly text.

Only check `en.json` — other locale files are handled by the autoglot bot.

## Original Comment
> The copy prompt button references t('network_landing_copied') and t('network_landing_copy_prompt'), but none of the locale file changes in this diff add these translation keys.

— PR review on examples page
