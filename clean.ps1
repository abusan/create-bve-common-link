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

# リンクを削除したいディレクトリのパスを取得
if (-not [System.String]::IsNullOrEmpty($Env:TARGET_DIR_PATH)) {
	$targetDir = $Env:TARGET_DIR_PATH
	if (Test-Path $targetDir) {
		# do-nothing
	} else {
		Write-Host "指定されたパスは存在しません。env:TARGET_DIR_PATHを確認してください。"
		Exit-PSHostProcess
	}
} else {
	while ($input = Read-Host "リンクを削除したいディレクトリが含まれているディレクトリ") {
		if (Test-Path $input) {
			$targetDir = Get-Item $input
			break
		} else {
			Write-Host "指定されたパスは存在しません。再度入力してください。"
		}
	}
}

# リンクを削除したいディレクトリを列挙
[System.IO.DirectoryInfo[]] $targetDirs = Get-ChildItem $targetDir -Directory
$index = 1
foreach ($dir in $targetDirs) {
	Write-Host "$index $($dir.FullName)"
	$index++
}

# リンクを作成する対象を選択させる
$input = Read-Host "リンクを削除したいディレクトリ番号を入力(READMEを参照)"

# 入力された番号に基づき、対象ディレクトリを決定
# 入力なし = 全選択
# ハイフン区切り = 範囲選択
# カンマ区切り = 個別選択

# 入力なし = 全選択
if ([string]::IsNullOrWhiteSpace($input)) {
    $selectedDirs = $targetDirs
    Write-Host "全てのディレクトリを選択しました。"
} else {
    if ($input.Contains(',')) {
        # カンマ区切り = 個別選択
        $indices = $input.split(',')
        $selectedDirs = @()
        foreach ($index in $indices) {
            $selectedDirs += $targetDirs[$index.Trim() - 1]
        }
        Write-Host "ディレクトリ $input を選択しました。"
    } elseif ($input.Contains('-')) {
        # ハイフン区切り = 範囲選択
        $start, $end = $input.split('-')
        if ($end) {
            $selectedDirs = $targetDirs[($start - 1)..($end - 1)]
        } else {
            $selectedDirs = @($targetDirs[$start - 1])
        }
        Write-Host "ディレクトリ $start ~ $end を選択しました。"
    }
}

# common系ディレクトリ名一覧
[System.IO.DirectoryInfo[]] $linkTargetDirs = Get-ChildItem $commonDir -Directory
$commonNames = $linkTargetDirs | ForEach-Object { $_.Name }

# シンボリックリンク削除
foreach ($dir in $selectedDirs) {
	foreach ($name in $commonNames) {
		$linkPath = Join-Path $dir.FullName $name
		if (Test-Path $linkPath) {
			$item = Get-Item $linkPath -Force
			if ($item.LinkType -eq "SymbolicLink" -and
                $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
            ) {
				Remove-Item $linkPath -Force -Recurse
				Write-Host "リンクを削除しました: $linkPath"
			} else {
				Write-Host "リンクではありません: $linkPath"
			}
		} else {
			Write-Host "リンクが存在しません: $linkPath"
		}
	}
}
