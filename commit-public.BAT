@echo OFF
echo ==============================
echo Adding all files...
echo ==============================
git add .
echo ==============================
echo Commiting with the message %1...
echo ==============================
git commit -m %1
echo ==============================
echo Pushing...
echo ==============================
git push -u origin main