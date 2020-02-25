# Painikepeliasiakas

Ohjelman kääntämiseen tarvitaan Flutter SDK, jonka voi ladata Flutterin [www-sivuilta](https://flutter.dev/docs/get-started/install). Tämän jälkeen ohjelman voi kääntää esimerkiksi Android apk-tiedostoksi komenolla
```
flutter build apk
```
Seuraavaksi ohjelman voi asentaa automaattisesti adb:n kautta komennolla
```
flutter install -d <deviceId>
```
Ohjelmaa voi myös testata debug-moodissa adb:n kautta komennolla
```
flutter run -d <deviceId>
```
Flutterin tunnistamien laitteiden listan saa komennolla
```
flutter devices
```