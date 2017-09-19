@echo off

rem ==============================================================================
rem   機能
rem     ファイルシステムをマウントする
rem   構文
rem     :USAGE 参照
rem
rem   Copyright (c) 2006-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * 基本設定
rem **********************************************************************
rem 環境変数のローカライズ開始
setlocal

rem 遅延環境変数展開の有効化
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem **********************************************************************
rem * 変数定義
rem **********************************************************************
rem ユーザ変数
set MOUNT_OPTIONS=
set UMOUNT_OPTIONS=

rem システム環境 依存変数
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set CYGWINROOT=%SystemDrive%\cygwin64
) else (
	set CYGWINROOT=%SystemDrive%\cygwin
)
set SLEEP=%CYGWINROOT%\bin\sleep.exe

rem プログラム内部変数
set DP_LIST=dp_list.bat
set DP_ASSIGN=dp_assign.bat
set DP_REMOVE=dp_remove.bat

rem **********************************************************************
rem * サブルーチン定義
rem **********************************************************************
:def_subroutine
goto end_def_subroutine

:USAGE
	echo Usage:                                                                1>&2
	echo   fs_mount.bat MOUNT_TYPE DEVICE MOUNT [MOUNT_OPTIONS ...]            1>&2
	echo.                                                                      1>&2
	echo   MOUNT_TYPE : {local^|remote}                                        1>&2
	echo   DEVICE : Specify the device to mount.                               1>&2
	echo   MOUNT  : Specify the mount point directory or drive letter to mount 1>&2
	echo            the device to.                                             1>&2
	echo   MOUNT_OPTIONS : Specify options which execute mount command with.   1>&2
goto :EOF

rem ファイルシステムのマウント
:FS_MOUNT
	rem 処理開始メッセージの表示
	echo -I デバイス^(%~1^) のマウントポイント^(%~2^) へのマウントを開始します

	rem マウント済み判定(ローカル)
	if "%MOUNT_TYPE%"=="local" (
		for /f "tokens=2,3,4" %%i in ('%DP_LIST% volume 2^>^&1 ^| findstr /i /r /c:"\<Volume[ ]*[0-9]*[A-Z ].*%~1\>"') do (
			if "%%k"=="%~1" (
				set VOL_NUM=%%i
				set MNT=%%j
				set DEV=%%k
			) else (
				set VOL_NUM=%%i
				set MNT=
				set DEV=%%j
			)
		)
		if "!MNT!"=="%~2" (
			echo -W デバイス^(%~1^) は既にマウントポイント^(%~2^) にマウントされています 1>&2
			exit /b 0
		)
	rem マウント済み判定(リモート)
	) else if "%MOUNT_TYPE%"=="remote" (
		for /f "tokens=1,2,3" %%i in ('net use 2^>^&1 ^| findstr /i /c:"%~1"') do (
			if "%%k"=="%~1" (
				set MNT=%%j
				set DEV=%%k
			) else (
				set MNT=%%i
				set DEV=%%j
			)
		)
		if "!MNT!"=="%~2:" (
			echo -W デバイス^(%~1^) は既にマウントポイント^(%~2^) にマウントされています 1>&2
			exit /b 0
		)
	)

	rem 不正マウント判定(ローカル)
	if "%MOUNT_TYPE%"=="local" (
		if not "%MNT%"=="%~2" (
			if not "%MNT%"=="" (
				rem マウント解除
				call "%DP_REMOVE%" letter %VOL_NUM% %MNT% >nul 2>&1
				set DP_REMOVE_RC=!errorlevel!
				if !DP_REMOVE_RC! equ 0 (
					rem 成功
					echo -W デバイス^(%~1^) の不正なマウントポイント^(%MNT%^) へのマウントが解除されました 1>&2
				) else (
					rem 失敗
					echo -E デバイス^(%~1^) の不正なマウントポイント^(%MNT%^) へのマウント解除が異常終了しました 1>&2
					echo      '%DP_REMOVE%' return code: !DP_REMOVE_RC! 1>&2
					exit /b !DP_REMOVE_RC!
				)
			)
		)
	rem 不正マウント判定(リモート)
	) else if "%MOUNT_TYPE%"=="remote" (
		if not "%MNT%"=="%~2:" (
			if not "%MNT%"=="" (
				rem マウント解除
				net use %MNT% /delete /y >nul 2>&1
				set NET_USE_DELETE_RC=!errorlevel!
				%SLEEP% 3
				rem マウント検索
				net use 2>&1 | findstr /i /c:"%~1" >nul 2>&1
				if not !errorlevel! equ 0 (
					rem マウント検索失敗 (=マウント解除成功)
					echo -W デバイス^(%~1^) の不正なマウントポイント^(%MNT%^) へのマウントが解除されました 1>&2
				) else (
					rem マウント検索成功 (=マウント解除失敗)
					echo -E デバイス^(%~1^) の不正なマウントポイント^(%MNT%^) へのマウント解除が異常終了しました 1>&2
					echo      'net use /delete' return code: !NET_USE_DELETE_RC! 1>&2
					exit /b !NET_USE_DELETE_RC!
				)
			)
		)
	)

	rem マウント(ローカル)
	if "%MOUNT_TYPE%"=="local" (
		call "%DP_ASSIGN%" letter %VOL_NUM% %~2 >nul 2>&1
		set DP_ASSIGN_RC=!errorlevel!
		if !DP_ASSIGN_RC! equ 0 (
			rem 成功
			echo -I デバイス^(%~1^) のマウントポイント^(%~2^) へのマウントが正常終了しました
			exit /b 0
		) else (
			rem 失敗
			echo -E デバイス^(%~1^) のマウントポイント^(%~2^) へのマウントが異常終了しました 1>&2
			echo      '%DP_ASSIGN%' return code: !DP_ASSIGN_RC! 1>&2
			exit /b !DP_ASSIGN_RC!
		)
	rem マウント(リモート)
	) else if "%MOUNT_TYPE%"=="remote" (
		net use %~2: %~1 %MOUNT_OPTIONS%
		set NET_USE_RC=!errorlevel!
		%SLEEP% 3
		rem マウント検索
		net use 2>&1 | findstr /i /c:"%~1" >nul 2>&1
		if !errorlevel! equ 0 (
			rem マウント検索成功 (=マウント成功)
			echo -I デバイス^(%~1^) のマウントポイント^(%~2^) へのマウントが正常終了しました
			exit /b 0
		) else (
			rem マウント検索失敗 (=マウント失敗)
			echo -E デバイス^(%~1^) のマウントポイント^(%~2^) へのマウントが異常終了しました 1>&2
			echo      'net use' return code: !NET_USE_RC! 1>&2
			exit /b !NET_USE_RC!
		)
	)
goto :EOF

:end_def_subroutine

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if "%~1"=="" (
	echo -E Missing MOUNT_TYPE argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT_TYPE=%~1
	if "!MOUNT_TYPE!"=="local" (
		rem 何もしない
	) else if "!MOUNT_TYPE!"=="remote" (
		rem 何もしない
	) else (
		echo -E Invalid MOUNT_TYPE argument -- "!MOUNT_TYPE!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem 第2引数のチェック
if "%~2"=="" (
	echo -E Missing DEVICE argument 1>&2
	call :USAGE & exit /b 1
) else (
	set DEVICE=%~2
)

rem 第3引数のチェック
if "%~3"=="" (
	echo -E Missing MOUNT argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT=%~3
)

rem MOUNT_OPTIONSの取得
shift & shift & shift
:processArgs
	if "%~1"=="" goto end_processArgs
	set MOUNT_OPTIONS=%MOUNT_OPTIONS% %1
	shift
goto processArgs
:end_processArgs

rem ファイルシステムのマウント
call :FS_MOUNT "%DEVICE%" "%MOUNT%"

