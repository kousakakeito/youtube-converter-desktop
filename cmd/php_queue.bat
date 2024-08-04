@echo off
cd C:\Users\k-kousaka\youtube-converter
php artisan queue:work --queue=mp3_conversion

