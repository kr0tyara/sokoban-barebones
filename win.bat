:: I don't guarantee this build code works, and I didn't test it that much.
:: So please be careful with that.

:: Replace with the path of vcvars64.bat on your PC.
call "C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Auxiliary/Build/vcvars64.bat"
cd "./build/bin"
:: Replace with the path to your Hashlink
cl /Ox /Fo:main.obj /Fe:../win/game.exe game.c /I ./ /I C:/HaxeToolkit/hashlink-1.14.0-win/include /link /LIBPATH:C:/HaxeToolkit/hashlink-1.14.0-win libhl.lib ssl.lib ui.lib directx.lib openal.lib fmt.lib /subsystem:windows
cd "../win"
start "" game.exe