# Storing projects.conf in 1Password

1Password 8 removed the Document category. Store `projects.conf` as a **Secure Note** instead.

## Upload

1. Open **1Password**
2. Click **New Item** → **Secure Note**
3. Set the title to exactly: `dotfiles/projects.conf`
4. Paste the contents of your `projects.conf` into the note body
5. Choose a vault (e.g. **Personal**)
6. Click **Save**

## Test the fetch

After saving in 1Password, verify the script can pull it:

```bash
bash scripts/fetch-projects-conf.sh
```

Then inspect the result:

```bash
cat projects.conf
```

Confirm directories look correct, then delete the local copy — it will be fetched automatically on next install:

```bash
rm projects.conf
```

## Update later

1. Find the `dotfiles/projects.conf` item
2. Click **Edit**
3. Replace the note body with the new contents
4. Click **Save**
