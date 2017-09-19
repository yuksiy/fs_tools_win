@echo off

rem ==============================================================================
rem   �@�\
rem     �t�@�C���V�X�e�����}�E���g����
rem   �\��
rem     :USAGE �Q��
rem
rem   Copyright (c) 2006-2017 Yukio Shiiya
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
set MOUNT_OPTIONS=
set UMOUNT_OPTIONS=

rem �V�X�e���� �ˑ��ϐ�
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set CYGWINROOT=%SystemDrive%\cygwin64
) else (
	set CYGWINROOT=%SystemDrive%\cygwin
)
set SLEEP=%CYGWINROOT%\bin\sleep.exe

rem �v���O���������ϐ�
set DP_LIST=dp_list.bat
set DP_ASSIGN=dp_assign.bat
set DP_REMOVE=dp_remove.bat

rem **********************************************************************
rem * �T�u���[�`����`
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

rem �t�@�C���V�X�e���̃}�E���g
:FS_MOUNT
	rem �����J�n���b�Z�[�W�̕\��
	echo -I �f�o�C�X^(%~1^) �̃}�E���g�|�C���g^(%~2^) �ւ̃}�E���g���J�n���܂�

	rem �}�E���g�ςݔ���(���[�J��)
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
			echo -W �f�o�C�X^(%~1^) �͊��Ƀ}�E���g�|�C���g^(%~2^) �Ƀ}�E���g����Ă��܂� 1>&2
			exit /b 0
		)
	rem �}�E���g�ςݔ���(�����[�g)
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
			echo -W �f�o�C�X^(%~1^) �͊��Ƀ}�E���g�|�C���g^(%~2^) �Ƀ}�E���g����Ă��܂� 1>&2
			exit /b 0
		)
	)

	rem �s���}�E���g����(���[�J��)
	if "%MOUNT_TYPE%"=="local" (
		if not "%MNT%"=="%~2" (
			if not "%MNT%"=="" (
				rem �}�E���g����
				call "%DP_REMOVE%" letter %VOL_NUM% %MNT% >nul 2>&1
				set DP_REMOVE_RC=!errorlevel!
				if !DP_REMOVE_RC! equ 0 (
					rem ����
					echo -W �f�o�C�X^(%~1^) �̕s���ȃ}�E���g�|�C���g^(%MNT%^) �ւ̃}�E���g����������܂��� 1>&2
				) else (
					rem ���s
					echo -E �f�o�C�X^(%~1^) �̕s���ȃ}�E���g�|�C���g^(%MNT%^) �ւ̃}�E���g�������ُ�I�����܂��� 1>&2
					echo      '%DP_REMOVE%' return code: !DP_REMOVE_RC! 1>&2
					exit /b !DP_REMOVE_RC!
				)
			)
		)
	rem �s���}�E���g����(�����[�g)
	) else if "%MOUNT_TYPE%"=="remote" (
		if not "%MNT%"=="%~2:" (
			if not "%MNT%"=="" (
				rem �}�E���g����
				net use %MNT% /delete /y >nul 2>&1
				set NET_USE_DELETE_RC=!errorlevel!
				%SLEEP% 3
				rem �}�E���g����
				net use 2>&1 | findstr /i /c:"%~1" >nul 2>&1
				if not !errorlevel! equ 0 (
					rem �}�E���g�������s (=�}�E���g��������)
					echo -W �f�o�C�X^(%~1^) �̕s���ȃ}�E���g�|�C���g^(%MNT%^) �ւ̃}�E���g����������܂��� 1>&2
				) else (
					rem �}�E���g�������� (=�}�E���g�������s)
					echo -E �f�o�C�X^(%~1^) �̕s���ȃ}�E���g�|�C���g^(%MNT%^) �ւ̃}�E���g�������ُ�I�����܂��� 1>&2
					echo      'net use /delete' return code: !NET_USE_DELETE_RC! 1>&2
					exit /b !NET_USE_DELETE_RC!
				)
			)
		)
	)

	rem �}�E���g(���[�J��)
	if "%MOUNT_TYPE%"=="local" (
		call "%DP_ASSIGN%" letter %VOL_NUM% %~2 >nul 2>&1
		set DP_ASSIGN_RC=!errorlevel!
		if !DP_ASSIGN_RC! equ 0 (
			rem ����
			echo -I �f�o�C�X^(%~1^) �̃}�E���g�|�C���g^(%~2^) �ւ̃}�E���g������I�����܂���
			exit /b 0
		) else (
			rem ���s
			echo -E �f�o�C�X^(%~1^) �̃}�E���g�|�C���g^(%~2^) �ւ̃}�E���g���ُ�I�����܂��� 1>&2
			echo      '%DP_ASSIGN%' return code: !DP_ASSIGN_RC! 1>&2
			exit /b !DP_ASSIGN_RC!
		)
	rem �}�E���g(�����[�g)
	) else if "%MOUNT_TYPE%"=="remote" (
		net use %~2: %~1 %MOUNT_OPTIONS%
		set NET_USE_RC=!errorlevel!
		%SLEEP% 3
		rem �}�E���g����
		net use 2>&1 | findstr /i /c:"%~1" >nul 2>&1
		if !errorlevel! equ 0 (
			rem �}�E���g�������� (=�}�E���g����)
			echo -I �f�o�C�X^(%~1^) �̃}�E���g�|�C���g^(%~2^) �ւ̃}�E���g������I�����܂���
			exit /b 0
		) else (
			rem �}�E���g�������s (=�}�E���g���s)
			echo -E �f�o�C�X^(%~1^) �̃}�E���g�|�C���g^(%~2^) �ւ̃}�E���g���ُ�I�����܂��� 1>&2
			echo      'net use' return code: !NET_USE_RC! 1>&2
			exit /b !NET_USE_RC!
		)
	)
goto :EOF

:end_def_subroutine

rem **********************************************************************
rem * ���C�����[�`��
rem **********************************************************************

rem ��1�����̃`�F�b�N
if "%~1"=="" (
	echo -E Missing MOUNT_TYPE argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT_TYPE=%~1
	if "!MOUNT_TYPE!"=="local" (
		rem �������Ȃ�
	) else if "!MOUNT_TYPE!"=="remote" (
		rem �������Ȃ�
	) else (
		echo -E Invalid MOUNT_TYPE argument -- "!MOUNT_TYPE!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem ��2�����̃`�F�b�N
if "%~2"=="" (
	echo -E Missing DEVICE argument 1>&2
	call :USAGE & exit /b 1
) else (
	set DEVICE=%~2
)

rem ��3�����̃`�F�b�N
if "%~3"=="" (
	echo -E Missing MOUNT argument 1>&2
	call :USAGE & exit /b 1
) else (
	set MOUNT=%~3
)

rem MOUNT_OPTIONS�̎擾
shift & shift & shift
:processArgs
	if "%~1"=="" goto end_processArgs
	set MOUNT_OPTIONS=%MOUNT_OPTIONS% %1
	shift
goto processArgs
:end_processArgs

rem �t�@�C���V�X�e���̃}�E���g
call :FS_MOUNT "%DEVICE%" "%MOUNT%"

