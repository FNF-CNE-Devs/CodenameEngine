@echo OFF
git add .
echo ==============================
echo Commiting with the message %1...
echo ==============================
git commit -a -m %1
echo ==============================
echo Pushing to dev repo...
echo ==============================
git push -u dev main
echo ==============================
echo Pushing to public repo...
echo ==============================
git push -u origin main