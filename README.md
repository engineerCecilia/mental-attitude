# 心理学实验 - 静态网站生成器

## 使用说明

### 添加新文章

1. 在目录下创建新的 `.md` 文件（例如：`新文章标题.md`）
2. 运行以下命令生成HTML：
   ```powershell
   .\generate-site.ps1
   ```

### 手动转换单个文件

如果您只想转换特定的markdown文件，可以手动编辑对应的HTML文件。

## 文件结构

- `*.md` - Markdown源文件
- `*.html` - 生成的HTML文章页面
- `index.html` - 主页（文章列表）
- `generate-site.ps1` - 自动生成脚本

## 自动化流程

每次添加新的 `.md` 文件后，运行 `generate-site.ps1` 脚本会：
1. 扫描所有 `.md` 文件
2. 为每个文件生成对应的HTML页面
3. 自动更新 `index.html` 主页，添加新文章链接

## 注意事项

- 确保markdown文件名使用中文或英文，避免特殊字符
- markdown文件的第一行应该是标题（以 `#` 开头）
- 保持简洁的markdown格式以获得最佳转换效果
