@echo off

rem ==============================================================================
rem   機能
rem     ファイルシステムをチェックする
rem   構文
rem     :USAGE 参照
rem
rem   Copyright (c) 2007-2017 Yukio Shiiya
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
set CHKDSK_OPTIONS=

rem システム環境 依存変数

rem プログラム内部変数

rem **********************************************************************
rem * サブルーチン定義
rem **********************************************************************
:def_subroutine
goto end_def_subroutine

:USAGE
	echo Usage:                                                                1>&2
	echo   fs_check.bat MOUNT [CHKDSK_OPTIONS ...]                             1>&2
	echo.                                                                      1>&2
	echo   MOUNT : Specify the drive letter to check.                          1>&2
	echo   CHKDSK_OPTIONS : Specify options which execute chkdsk command with. 1>&2
goto :EOF

rem ファイルシステムのチェック
:FS_CHECK
	rem 処理開始メッセージの表示
	echo -I デバイス^(%~1^) のチェックを開始します

	rem マウント済み判定
	rem 実行不要

	rem チェック
	chkdsk %~1: %CHKDSK_OPTIONS%
	set CHKDSK_RC=!errorlevel!

	rem 処理終了メッセージの表示
	if !CHKDSK_RC! equ 0 (
		rem 成功
		echo -I デバイス^(%~1^) のチェックが正常終了しました
		exit /b 0
	) else (
		rem 失敗
		echo -E デバイス^(%~1^) のチェックが異常終了しました 1>&2
		echo      'chkdsk' return code: !CHKDSK_RC! 1>&2
		exit /b !CHKDSK_RC!
	)
goto :EOF

:end_def_subroutine

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if "%~1"=="" (
	echo -E Missing MOUNT argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT=%~1
)

rem CHKDSK_OPTIONSの取得
shift
:processArgs
	if "%~1"=="" goto end_processArgs
	set CHKDSK_OPTIONS=%CHKDSK_OPTIONS% %1
	shift
goto processArgs
:end_processArgs

rem ファイルシステムのチェック
call :FS_CHECK "%MOUNT%"

