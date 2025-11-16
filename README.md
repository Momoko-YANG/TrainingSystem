# 教務管理システム (TeachingAffairsAdministrationSystem)

学生、教師、管理者向けの総合的な教務管理システムです。

## 📋 必要な環境

- **Node.js**: v16.20.2（nvmを使用して管理）
- **Go**: v1.25.4以上
- **MySQL**: v9.5.0以上
- **Yarn**: v1.22.22以上

## 🚀 初期セットアップ

### 1. Node.jsのインストール（nvmを使用）

```bash
# nvmのインストール
brew install nvm

# nvm環境変数の設定
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# Node.js 16のインストール
nvm install 16
nvm use 16
```

### 2. Goのインストール

```bash
brew install go
```

### 3. MySQLのインストールと起動

```bash
# MySQLのインストール
brew install mysql

# MySQLサービスの起動
brew services start mysql
```

### 4. データベースのセットアップ

```bash
# データベース構造のインポート
mysql -u root school < backend/school.sql

# 日本語版テストデータのインポート
mysql -u root school < backend/test_data_ja.sql
```

## 💻 開発環境での実行

### バックエンドの起動

```bash
cd backend/src
go run main.go
```

バックエンドは `http://localhost:9090` で起動します。

### フロントエンドの起動

別のターミナルウィンドウで：

```bash
# Node.js 16に切り替え
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
nvm use 16

# フロントエンドディレクトリに移動
cd frontend

# 依存関係のインストール（初回のみ）
yarn install --ignore-engines

# 開発サーバーの起動
yarn dev
```

フロントエンドは `http://localhost:3000` で起動します。

## 🔑 テストアカウント

すべてのアカウントのパスワードは：`123456`

### 管理者アカウント
- **ユーザー名**: `admin`
- **パスワード**: `123456`

### 学生アカウント（例）
- **ユーザー名**: `2021001`（田中太郎 - 情報工学部）
- **ユーザー名**: `2021002`（佐藤花子 - 情報工学部）
- **ユーザー名**: `2021101`（渡辺愛 - ソフト工学部）
- **パスワード**: `123456`

### 教師アカウント（例）
- **ユーザー名**: `T001`（山田教授 - 情報工学部）
- **ユーザー名**: `T101`（鈴木教授 - ソフト工学部）
- **パスワード**: `123456`

## 📊 データベース統計

- **ユーザーアカウント**: 20件（管理者1名 + 学生12名 + 教師7名）
- **学部**: 5件
- **コース**: 12件
- **履修登録記録**: 33件（成績データを含む）

## 🐳 本番環境での実行（Docker）

```bash
# フロントエンドとバックエンドを同時に起動
docker-compose up --build
```

Nginxなどのウェブサーバーを使用して、`:30003`と`:30004`を同じポートにプロキシすることをお勧めします。

## 📝 注意事項

- フロントエンドとバックエンドは異なるポートで実行されます
- CORS問題を回避するため、本番環境ではNginxなどのリバースプロキシの使用を推奨します
- データベース接続設定は `backend/src/utils/connect.go` で変更できます

## 🛠️ トラブルシューティング

### Node.jsのバージョンエラー
```bash
nvm use 16
```

### MySQLへの接続エラー
MySQLサービスが起動していることを確認してください：
```bash
brew services list
```

### ポートが使用中のエラー
他のアプリケーションが同じポートを使用していないか確認してください。

## 📖 APIドキュメント

詳細なAPIドキュメントは `backend/api.md` を参照してください。

## 🗄️ データベース設計

データベーススキーマの詳細は `backend/school.md` を参照してください。
