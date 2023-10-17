# Leaflet

<img src="https://i.imgur.com/dvmKX8d.png">

Leaflet notes cross-platform application, written in Flutter, beautiful, fast and secure.
_
## Main features
- Material design version 3
- Completely cross platform
- List/grid view for notes
- Multiple note extras, such as lists, images and drawings
- Lock notes with a pin or password or biometrics
- Hide notes content on the main page
- Search notes with various filters
- Complete theme personalization
- Local backup/restore functionality with encryption
- Trash and archive for notes
- Database encryption
- Tags for notes

## Planned features
- [ ] New sync api integration
- [ ] Folders
- [ ] Refined UI for desktop platforms

## Compiling the app
Before anything, be sure to have a working Flutter SDK setup.

Be sure to disable signing on build.gradle or change keystore to sign the app.

For now the required Flutter channel is 'master', so issue those two commands before starting building:
```
~$ flutter channel master
~$ flutter upgrade
```

After that, building is simple as this:
```
~$ flutter pub get

~$ flutter run           # for debug
~$ flutter build apk --flavor dev     # release build with dev flavor (available flavors are dev, production and ci)
```

## Generating locales
After adding or updating the locales, run the following command from Leaflet root dir:
```
dart bin/locale_gen.dart
```

This will generate and update the required files

## Contributing
The entire app and even the [online sync api](https://github.com/broodroosterdev/potatosync-rust) is completely open source.  
Feel free to open a PR to suggest fixes, features or whatever you want, just remember that PRs are subjected to manual review, you're going to wait for actual people to look at your contributions

For translations, head over to our [Crowdin](https://potatoproject.crowdin.com/leaflet).

If you want to receive the latest news head over to our [Telegram channel](https://t.me/potatonotesnews), if you want to chat we even got the [Telegram group](https://t.me/potatonotes).
