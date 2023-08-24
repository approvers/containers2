# Containers2

限界開発鯖共有サーバーでホストするコンテナの各種 Compose ファイルや設定ファイルを管理するリポジトリです．
旧[approvers/containers](https://github.com/approvers/containers)の後継です．

## 使い方

1. このリポジトリをクローンして新しいブランチを作成する．
1. プロジェクト名のディレクトリを作成する．
1. ディレクトリ内に `compose.yml` を作成 & 編集する．
1. コミット & プッシュして PR を作成する．

### `compose.yml` 内で参照する環境変数やシークレットなどの秘密情報を扱う場合

秘密情報は PGP 鍵を用いて暗号化することで管理します．暗号化されたファイルは GitHub Actions にてデプロイ前に復号されます．

1. `compose.yml` と同じディレクトリに参照するファイルを作成する．(例: `.env`)
1. ファイルを編集して秘密情報を記述する．
1. `compose.yml` で秘密情報を参照するように設定する．(例: `env_file: .env`)
1. `<repository root>/encrypt.sh` を使ってファイルを暗号化する．(実行例: `./encrypt.sh .env`)
1. `.env` が削除され， `.env.secret` が作成される．
1. `.env.secret` をコミット & プッシュする．
1. 場合に応じて， `.env.example` などを作成するといいでしょう．

## 注意

- マウント方式のボリュームを使用してこのリポジトリ内のファイルを参照することはできません．
- 上記の運用はあくまで暫定ですので，今後変更される可能性があります．
