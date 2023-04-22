@echo OFF
git add .
echo ==============================
echo Commiting with the message %1...
echo ==============================
git commit -a -m %1
echo ==============================
echo Pushing...
echo ==============================
git push -u dev main