:: I don't guarantee this build code works, and I didn't test it that much.
:: So please be careful with that.

:: Replace with the path of vcvars64.bat on your PC.
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cd "./build/bin"
:: Replace with the path to your Hashlink

cl /Ox /Fo:main.obj /Fe:../win/game.exe game.c ^
  /I ./ ^
  /I C:/HaxeToolkit/hashlink-1.15.0-win/include ^
  /I C:/HaxeToolkit/hashlink-1.15.0-win/include/openal/include ^
  /link ^
  /LIBPATH:C:/HaxeToolkit/hashlink-1.15.0-win ^
  /LIBPATH:C:/HaxeToolkit/hashlink-1.15.0-win/include/openal/libs/Win64 ^
  /LIBPATH:. ^
  libhl.lib ssl.lib ui.lib uv.lib sdl.lib fmt.lib ^
  openal_new.lib OpenAL32.lib ^
  /subsystem:windows

cd "../win"
start "" game.exe