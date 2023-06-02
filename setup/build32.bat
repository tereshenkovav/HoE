"C:\Program Files (x86)\NSIS\makensis.exe" HoE.nsi

rm -f HeroesOfEquestria-1.0.0-Win32.zip
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\bin
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\configs
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\fonts
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\images
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\manuals
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\maps
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\scenes
7z a -mx9 HeroesOfEquestria-1.0.0-Win32.zip ..\usermaps
