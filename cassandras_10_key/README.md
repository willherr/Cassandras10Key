# 10_key_adding_machine

## Logo Attribution
This link is required for attribution of the logo.
<a href="https://www.flaticon.com/free-icons/adding-machine" title="adding machine icons">Adding machine icons created by Freepik - Flaticon</a>

## Publishing
1. Increment pubspec.yml build version number.
2. Run `flutter build appbundle --obfuscate --split-debug-info=.\build\app\outputs\bundle\release\ && start .\build\app\outputs\bundle\release\ && start .\build\app\intermediates\merged_native_libs\release\out\lib`
  a. The second part of the command opens up the file explorer window for easily dragging and dropping the aab in the Google Play Console.
  b. The third part of the command opens up the file explorer window where the three folders should be zipped and included as debug symbols in the Google Play Console.
3. Click the create a new release button in the [Google Play Console](https://play.google.com/console/u/0/developers/5199002862287665816/app/4974365505926820594/tracks/production)
  a. Sign in with herrmanw@mail.gvsu.edu > will-i-am.dev
4. Upload the app bundle