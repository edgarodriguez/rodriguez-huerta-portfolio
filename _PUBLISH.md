# How to publish updates

Local notes. The leading `_` means Quarto ignores this file — it never reaches the website.

Open a terminal and make sure you are in the project folder first:

```
cd ~/ERH/50-Sites/rodriguez-huerta-portfolio
```

---

## 1. Look at it before you publish

```
quarto preview
```

Opens the site in your browser and reloads as you save. Press `Ctrl + C` in the terminal to stop it.

---

## 2. Publish

```
git add -A
git commit -m "Describe what you changed"
git push
```

Change the message in quotes to whatever you actually did. That's it — GitHub builds and deploys automatically. Live in about 2 minutes at <https://www.rodriguez-huerta.com>.

---

## 3. Check it actually deployed

```
open https://github.com/edgarodriguez/rodriguez-huerta-portfolio/actions
```

Green tick = published. Red cross = the build failed, nothing changed on the live site. Click it to read the error.

---

## If the push is rejected

Error says *"Updates were rejected because the tip of your current branch is behind"*. This happens when you edited a file on the GitHub website, so GitHub has a change your computer doesn't.

```
git pull --rebase --autostash origin main
git push
```

Pulls GitHub's changes in underneath yours, keeps both, then pushes. Nothing is lost.

---

## If a page won't update

Quarto caches pages that contain R or Python code, in a folder called `_freeze`. If you changed code but the page looks the same, the cache is stale — especially after editing anything in `R/`.

```
rm -rf _freeze
quarto render
```

Rebuilds everything from scratch. Slow, but it always works.

---

## Useful one-offs

```
git status
```
Shows which files you changed but haven't published.

```
git diff
```
Shows exactly what changed, line by line. Press `q` to exit.

```
git log --oneline -10
```
Your last 10 published updates.

```
quarto render
```
Builds the site into `_site/` without opening a browser.

---

## Adding new content

Drop a new `.qmd` file into the matching folder — `blog/`, `projects/`, `publications/`, `portfolio/`, or `conferences/` — and it appears on that section's page by itself. Copy an existing file as a starting point. Then preview, then publish (steps 1 and 2).
