# .envの読み込み
Get-Content -Path "$PSScriptRoot\.env" -Raw -Encoding UTF8 | ForEach-Object {
    $raws = $_.split("`n")
    foreach ($raw in $raws) {
        $name, $value = $raw.split('=')
        if ([string]::IsNullOrWhiteSpace($name) -Or $name.Contains('#')) {
          continue
        }
        Write-Host "$name=$value"
        Set-Content env:\$name $value
    }
}

# common系ディレクトリのパスを取得
if (-not [System.String]::IsNullOrEmpty($Env:COMMON_DIR_PATH)) {
    $commonDir = $env:COMMON_DIR_PATH
    if (Test-Path $commonDir) {
        # do-nothing
    } else {
        Write-Host "指定されたパスは存在しません。env:COMMON_DIR_PATHを確認してください。"
        Exit-PSHostProcess
    }
} else {
    while ($input = Read-Host "common系(Nagoya_Common, GeneralAtsPluginなど)が含まれているディレクトリ") {
        if (Test-Path $input) {
            $commonDir = Get-Item $input
            break
        } else {
            Write-Host "指定されたパスは存在しません。再度入力してください。"
        }
    }
}

# リンクを作成したいディレクトリのパスを取得
if (-not [System.String]::IsNullOrEmpty($Env:TARGET_DIR_PATH)) {
    $targetDir = $Env:TARGET_DIR_PATH
    if (Test-Path $targetDir) {
        # do-nothing
    } else {
        Write-Host "指定されたパスは存在しません。env:TARGET_DIR_PATHを確認してください。"
        Exit-PSHostProcess
    }
} else {
    while ($input = Read-Host "リンクを作成したいディレクトリが含まれているディレクトリ") {
        if (Test-Path $input) {
            $targetDir = Get-Item $input
            break
        } else {
            Write-Host "指定されたパスは存在しません。再度入力してください。"
        }
    }
}

# リンクを作成したいディレクトリを列挙
[System.IO.DirectoryInfo[]] $targetDirs = Get-ChildItem $targetDir -Directory
$index = 1
foreach ($dir in $targetDirs) {
    Write-Host "$index $($dir.FullName)"
    $index++
}

# リンクを作成する対象を選択させる
$input = Read-Host "リンクを作成したいディレクトリ番号を入力(READMEを参照)"
$start, $end = $input.split('-')
if ($end) {
    $selectedDirs = $targetDirs[($start - 1)..($end - 1)]
} else {
    $selectedDirs = @($targetDirs[$start - 1])
}

# リンク元となるcommon系ディレクトリの一覧を取得
[System.IO.DirectoryInfo[]] $linkTargetDirs = Get-ChildItem $commonDir -Directory

# シンボリックリンクを作成
foreach ($dir in $selectedDirs) {
    foreach ($linkTargetDir in $linkTargetDirs) {
        $linkPath = Join-Path $dir.FullName $linkTargetDir.Name # リンク作成先のパス
        if (-not (Test-Path $linkPath)) {
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $linkTargetDir.FullName
            Write-Host "シンボリックリンクを作成しました: $linkPath -> $($linkTargetDir.FullName)"
        } else {
            Write-Host "シンボリックリンクは既に存在します: $linkPath"
        }
    }
}
