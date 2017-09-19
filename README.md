# fs_tools_win

## 概要

ファイルシステム関連ツール (Windows)

## 使用方法

* 以下のコマンドはすべて「管理者として実行」した「コマンド プロンプト」から実行する必要があります。

### fs_mount.bat

    ローカルファイルシステムをマウントします。
    fs_mount.bat local ボリュームラベル ドライブ文字

### fs_umount.bat

    ローカルファイルシステムをマウント解除します。
    fs_umount.bat local ボリュームラベル ドライブ文字

### fs_check.bat

    ファイルシステムをチェックします。
    fs_check.bat ドライブ文字 [chkdsk コマンド オプション(例：/f)]

### その他

* 上記で紹介したツールの詳細については、各ファイルのヘッダー部分を参照してください。

## 動作環境

OS:

* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* [dp_tools](https://github.com/yuksiy/dp_tools)

## インストール

ソースからインストールする場合:

    (Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/fs_tools_win>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/fs_tools_win/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2006-2017 Yukio Shiiya
