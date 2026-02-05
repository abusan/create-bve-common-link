# create-bve-common-link

## これは何？
BVEで共通ライブラリや車両データ(Nagoya_Common, GeneralAtsPlugin, JR TrainPackなど)の管理をやりやすくするためのスクリプトです。

導入している路線が増えると、1つのScenarioフォルダに何百という路線が入ることになり、BVEの起動が遅くなったり、シナリオをバージョンアップしたいときに不便です。
地域や鉄道会社、路線ごとにシナリオフォルダを分割することで管理が楽になりますが、今度は様々なシナリオから読み込まれている共通ライブラリ(Nagoya_Common, GeneralAtsPlugin, JR TrainPackなど)を、それぞれのシナリオフォルダにコピーする必要があります。シナリオの管理が楽になった反面、共通ライブラリの管理という手間が発生します。

そこで、シンボリックリンクという仕組みを利用することで、共通ライブラリたちを一元管理できるようにするのがCreateBVECommonLinkです。

このスクリプトを使用することで、BVE関連フォルダ・ファイルを以下のように管理することが可能です。

+ 共通ライブラリをシナリオフォルダとは別のフォルダで管理する
+ BVE路線データを地域や鉄道会社など、複数のフォルダで管理する

例えば以下のようなフォルダ構成が可能です。

```
BVE
  ├ Scenario
  │  ├ JR East
  │  ├ JR West
  │  ├ Keikyu
  │  └ Hankyu
  │ 
  └ Common
     ├ BveDcTrainPack-master
     ├ GeneralAtsPlugin
     ├ Nagoya_Common
     └ Rock_On
```

BVEをやりこんでいる人なら Nagoya_Common, GeneralAtsPlugin, Rock_On というフォルダを見たことがあるかと思います。
CreateBVECommonLink は、これらの共通ライブラリ群を各シナリオフォルダから読み込めるようにシンボリックリンクを作成します。

## 使い方
このスクリプトはコマンドでの実行を前提としています。そのため、ある程度PCの操作に慣れている人向けです。
以下の文章が理解できる人であれば、特に問題なく使用できるはずです。

+ Powershellまたはターミナルを管理者権限で起動する
+ Powershell Script(ps1ファイル)を実行する

### 0. フォルダの場所を設定する
1. `env.local` ファイルを開きます
2. `COMMON_DIR_PATH` に共通ライブラリを格納しているフォルダのパスを指定します
3. `TARGET_DIR_PATH` にシナリオを格納しているフォルダのパスを指定します
4. `env.local` をコピーして `.env` ファイルを作成します

3 に指定するパスは、実際の路線ファイルがあるフォルダの1つ上になるはずです。

### 1. スクリプトを実行する
1. Powershell またはターミナルを管理者権限で実行します
2. cdコマンドを使用してスクリプトがあるフォルダへ移動します
3. 下記のコマンドを実行します

#### リンクを作成する
※この操作には管理者権限が必要です。
```
PowerShell.exe -ExecutionPolicy RemoteSigned -Command ".\create.ps1"
```

#### リンクを削除する
```
PowerShell.exe -ExecutionPolicy RemoteSigned -Command ".\clean.ps1"
```

### 2. 対象のフォルダを指定する
TARGET_DIR_PATH に指定したフォルダの中にあるフォルダが以下のように番号付きで列挙されます。

```
1 C:\Users\ユーザー名\Documents\BVE\Scenario\JR九州
2 C:\Users\ユーザー名\Documents\BVE\Scenario\JR北海道
3 C:\Users\ユーザー名\Documents\BVE\Scenario\JR四国
4 C:\Users\ユーザー名\Documents\BVE\Scenario\JR東日本
5 C:\Users\ユーザー名\Documents\BVE\Scenario\JR東海
6 C:\Users\ユーザー名\Documents\BVE\Scenario\JR西日本
```

`リンクを削除したいディレクトリ番号を入力(READMEを参照):` と表示されたら、リンクを作成したいフォルダの番号を入力します。

例)  
+ 全てのフォルダを指定する： `Enter` を押す
+ 特定の番号を指定する(例:3番)： `3` を入力後に `Enter` を押す
+ 複数の番号を指定する(例:3と5番)： `3,5` を入力後に `Enter` を押す
+ 複数の番号を範囲で指定する(例:3から5番)： `3-5` を入力後に `Enter` を押す

## サポートについて
このスクリプトは、自力でPowershell Scriptを実行できる、またはスクリプト実行に関するエラーを自力で解消できる人向けです。
動かない、わからない等のサポートはいたしかねます。Googleなどで調べて自力で解決してください。

不具合などがありましたら、GitHubのIssueなどで連絡いただければ修正するかもしれません。
ただ、それほど難しくないスクリプトですので、修正を待つよりも自力で修正したほうが早いと思います。
