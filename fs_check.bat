@echo off

rem ==============================================================================
rem   �@�\
rem     �t�@�C���V�X�e�����`�F�b�N����
rem   �\��
rem     :USAGE �Q��
rem
rem   Copyright (c) 2007-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * ��{�ݒ�
rem **********************************************************************
rem ���ϐ��̃��[�J���C�Y�J�n
setlocal

rem �x�����ϐ��W�J�̗L����
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem **********************************************************************
rem * �ϐ���`
rem **********************************************************************
rem ���[�U�ϐ�
set CHKDSK_OPTIONS=

rem �V�X�e���� �ˑ��ϐ�

rem �v���O���������ϐ�

rem **********************************************************************
rem * �T�u���[�`����`
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

rem �t�@�C���V�X�e���̃`�F�b�N
:FS_CHECK
	rem �����J�n���b�Z�[�W�̕\��
	echo -I �f�o�C�X^(%~1^) �̃`�F�b�N���J�n���܂�

	rem �}�E���g�ςݔ���
	rem ���s�s�v

	rem �`�F�b�N
	chkdsk %~1: %CHKDSK_OPTIONS%
	set CHKDSK_RC=!errorlevel!

	rem �����I�����b�Z�[�W�̕\��
	if !CHKDSK_RC! equ 0 (
		rem ����
		echo -I �f�o�C�X^(%~1^) �̃`�F�b�N������I�����܂���
		exit /b 0
	) else (
		rem ���s
		echo -E �f�o�C�X^(%~1^) �̃`�F�b�N���ُ�I�����܂��� 1>&2
		echo      'chkdsk' return code: !CHKDSK_RC! 1>&2
		exit /b !CHKDSK_RC!
	)
goto :EOF

:end_def_subroutine

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
if "%~1"=="" (
	echo -E Missing MOUNT argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT=%~1
)

rem CHKDSK_OPTIONS�̎擾
shift
:processArgs
	if "%~1"=="" goto end_processArgs
	set CHKDSK_OPTIONS=%CHKDSK_OPTIONS% %1
	shift
goto processArgs
:end_processArgs

rem �t�@�C���V�X�e���̃`�F�b�N
call :FS_CHECK "%MOUNT%"

