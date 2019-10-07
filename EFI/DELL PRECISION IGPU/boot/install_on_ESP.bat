@echo off
set install_dir=\EFI\Dell_E6540_UEFI_eGPU_configurator

:: Get executing directory
set curpath=%~dp0
set curpath=%curpath:~0,-1%

:: Change to executing drive and directory
pushd . & cd /D %curpath%


  call :checkadmin
  if errorlevel 1 goto :EOF
  mountvol s: /s > nul
  rd /q /s s:%install_dir% 2> nul
  md s:%install_dir% 2> nul
  echo Copying files from %CurPath% to s:%install_dir%  [overwrite existing files]. . .
  xcopy %CurPath% s:%install_dir% /e/s/Y > nul
  if exist s:%install_dir%\bootx64.efi (
     echo Successfully installed. Now configure your BIOS to use these files by:
     echo **********************************************************************************************************************
     echo 1. Reboot the system
	 echo 2. Hit F2 to enter BIOS
     echo 3. Select General-Boot Sequence
     echo 4. Select Boot List Option-UEFI, Add Boot Option
     echo 5. Under File Name, select "..."	 
	 echo 6. Inspect the File Systems looking for %install_dir%\bootx64.efi, click OK
	 echo 7. In Boot Option Name, provide a description like "eGPU configurator", click OK
	 echo 8. Reboot, hit F12 for Boot List, select eGPU configurator to configure your system for eGPU use
     echo **********************************************************************************************************************
  ) else (
     echo Installation failed!! 
    echo Please manually copy these files to your UEFI ESP folder, then hit F12 and add a new UEFI bootitem pointing to this bootx64.efi file."
  )
:exit
  echo.&echo Done. Press any key to exit . . . & pause > nul 
  :: Return to originating directory and clear all variables used
  popd
  mountvol s: /d > nul
  goto :EOF

::---------
:checkadmin
::---------

 set randname=%random%%random%%random%%random%%random%
 md "%windir%\%randname%" 2>nul
 if %errorLevel% == 0 (
        echo %username% has "run as local administrator" access. Good.
        rd "%windir%\%randname%" 2>nul 
        exit /B 0
  ) else (
      echo ERROR!! %username% doesn't have local administrator access. 
      echo Please right click install_on_ESP.bat and select "run as administrator". Exiting now.  
      echo.
      if not "%1"=="nopause" pause 
       exit /B 1
  )
  goto :EOF
