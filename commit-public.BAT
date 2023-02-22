@echo OFF
set /p msg="Commit message: "
echo ==============================
echo Adding all files...
echo ==============================
git add .
echo ==============================
echo Commiting with the message %msg%...
echo ==============================
git commit -m "%msg%"
echo ==============================
echo Pushing...
echo ==============================
git push -u origin main