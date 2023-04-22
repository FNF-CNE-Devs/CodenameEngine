## DEV (PRIVATE) REPO INSTRUCTIONS TO SYNC UP WITH IT INSTEAD OF SYNCING WITH THE PUBLIC ONE
- Open a Command Prompt window in the public codename repo folder
- Type those commands:
    - `git remote add dev https://www.github.com/YoshiCrafter29/CodenameEngine-Dev`
    - `git branch --set-upstream-to dev/main`
- GitHub desktop should be synchronized with the dev repo now. If you're unsure,
    - Repo name should still say "CodenameEngine"
    - Current branch should still say "main"
    - "Fetch" button should say "Fetch dev"
    - You shouldn't have any commit to push.