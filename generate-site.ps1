# 无路之路网站生成器
# 此脚本会扫描所有 .md 文件，生成对应的 HTML 页面，并更新主页

$ErrorActionPreference = "Stop"

# 获取当前目录
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 获取所有 .md 文件（排除 README.md）
$mdFiles = Get-ChildItem -Path $currentDir -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }

Write-Host "发现 $($mdFiles.Count) 个 Markdown 文件" -ForegroundColor Cyan

# 为每个 .md 文件生成 HTML
foreach ($mdFile in $mdFiles) {
    $mdContent = Get-Content $mdFile.FullName -Raw -Encoding UTF8
    $fileName = $mdFile.BaseName
    $htmlFileName = "$fileName.html"
    
    Write-Host "处理: $fileName" -ForegroundColor Green
    
    # 提取标题（第一个 # 标题）
    $titleMatch = [regex]::Match($mdContent, '^#\s+(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { $fileName }
    
    # 提取内容并转换为HTML
    $lines = $mdContent -split "`n"
    $htmlContent = ""
    $inParagraph = $false
    
    foreach ($line in $lines) {
        $line = $line.TrimEnd()
        
        # 跳过空行和文件开头的空行
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($inParagraph) {
                $htmlContent += "</p>`n"
                $inParagraph = $false
            }
            continue
        }
        
        # 处理标题
        if ($line -match '^#{1}\s+(.+)$') {
            if ($inParagraph) {
                $htmlContent += "</p>`n"
                $inParagraph = $false
            }
            $htmlContent += "<h1>$($matches[1])</h1>`n"
        }
        elseif ($line -match '^#{2}\s+(.+)$') {
            if ($inParagraph) {
                $htmlContent += "</p>`n"
                $inParagraph = $false
            }
            $htmlContent += "<h2>$($matches[1])</h2>`n"
        }
        elseif ($line -match '^#{3}\s+(.+)$') {
            if ($inParagraph) {
                $htmlContent += "</p>`n"
                $inParagraph = $false
            }
            $htmlContent += "<h3>$($matches[1])</h3>`n"
        }
        else {
            # 处理普通段落文本
            if (-not $inParagraph) {
                $htmlContent += "<p>"
                $inParagraph = $true
            }
            else {
                $htmlContent += "<br>`n"
            }
            $htmlContent += $line
        }
    }
    
    if ($inParagraph) {
        $htmlContent += "</p>`n"
    }
    
    # 生成完整的HTML文件
    $fullHtml = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.8;
            color: #333;
            background-color: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 15px;
            margin-bottom: 30px;
            font-size: 2em;
        }
        
        h2 {
            color: #34495e;
            margin-top: 30px;
            margin-bottom: 15px;
            font-size: 1.5em;
            border-left: 4px solid #3498db;
            padding-left: 15px;
        }
        
        h3 {
            color: #34495e;
            margin-top: 25px;
            margin-bottom: 12px;
            font-size: 1.2em;
        }
        
        p {
            margin-bottom: 15px;
            text-align: justify;
        }
        
        .back-link {
            display: inline-block;
            margin-top: 30px;
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        
        .back-link:hover {
            background-color: #2980b9;
        }
        
        @media (max-width: 600px) {
            .container {
                padding: 20px;
            }
            
            h1 {
                font-size: 1.5em;
            }
            
            h2 {
                font-size: 1.2em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
$htmlContent
        <a href="index.html" class="back-link">&larr; 返回主页</a>
    </div>
</body>
</html>
"@
    
    # 写入HTML文件
    $htmlPath = Join-Path $currentDir $htmlFileName
    Set-Content -Path $htmlPath -Value $fullHtml -Encoding UTF8
    Write-Host "  ✓ 生成: $htmlFileName" -ForegroundColor Yellow
}

# 更新主页 index.html
Write-Host "`n更新主页..." -ForegroundColor Cyan

# 收集所有文章信息
$articles = @()
foreach ($mdFile in $mdFiles) {
    $mdContent = Get-Content $mdFile.FullName -Raw -Encoding UTF8
    $fileName = $mdFile.BaseName
    
    # 提取标题
    $titleMatch = [regex]::Match($mdContent, '^#\s+(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { $fileName }
    
    # 提取预览文本（标题后的第一段内容）
    $previewLines = $mdContent -split "`n" | Where-Object { 
        $_ -notmatch '^#' -and 
        $_ -notmatch '^\s*$' -and 
        $_.Trim().Length -gt 0 
    } | Select-Object -First 2
    
    $preview = ($previewLines -join " ").Trim()
    if ($preview.Length -gt 100) {
        $preview = $preview.Substring(0, 100) + "..."
    }
    
    # 获取文件修改时间
    $lastModified = $mdFile.LastWriteTime
    $dateStr = "$($lastModified.Year)年$($lastModified.Month)月"
    
    $articles += @{
        Title = $title
        FileName = "$($fileName).html"
        Preview = $preview
        Date = $dateStr
    }
}

# 按文件名排序（可以改为按日期排序）
$articles = $articles | Sort-Object { $_.FileName }

# 生成文章卡片HTML
$articleCards = ""
foreach ($article in $articles) {
    $articleCards += "                <a href=`"$($article.FileName)`" class=`"article-card`">`n"
    $articleCards += "                    <h2>$($article.Title)</h2>`n"
    $articleCards += "                    <div class=`"preview`">`n"
    $articleCards += "                        $($article.Preview)`n"
    $articleCards += "                    </div>`n"
    $articleCards += "                    <div class=`"date`">更新于 $($article.Date)</div>`n"
    $articleCards += "                </a>`n                `n"
}

# 生成完整的index.html
$indexHtml = @"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>无路之路 - 文章列表</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            color: white;
            padding: 40px 20px;
            margin-bottom: 30px;
        }
        
        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        
        header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .articles-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            padding: 20px 0;
        }
        
        .article-card {
            background-color: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .article-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        
        .article-card h2 {
            color: #2c3e50;
            font-size: 1.4em;
            margin-bottom: 10px;
        }
        
        .article-card .date {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-top: 15px;
        }
        
        .article-card .preview {
            color: #555;
            font-size: 0.95em;
            line-height: 1.5;
            margin-top: 10px;
        }
        
        footer {
            text-align: center;
            color: white;
            padding: 30px 20px;
            margin-top: 40px;
            opacity: 0.8;
        }
        
        @media (max-width: 600px) {
            header h1 {
                font-size: 2em;
            }
            
            .articles-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>&#x1F4DA; 无路之路</h1>
            <p>修心路上的迷茫与指引</p>
        </header>
        
        <main>
            <div class="articles-grid">
$articleCards
            </div>
        </main>
        
        <footer>
            <p>&amp;copy; 2026 无路之路 | 持续更新中...</p>
        </footer>
    </div>
</body>
</html>
"@

# 写入index.html
$indexPath = Join-Path $currentDir "index.html"
Set-Content -Path $indexPath -Value $indexHtml -Encoding UTF8
Write-Host "✓ 主页已更新" -ForegroundColor Green

Write-Host "`n✅ 网站生成完成！" -ForegroundColor Green
Write-Host "打开 index.html 查看您的网站" -ForegroundColor Cyan
