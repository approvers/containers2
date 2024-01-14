# Containers2

[![Deploy to remote server](https://github.com/approvers/containers2/actions/workflows/deploy.yaml/badge.svg)](https://github.com/approvers/containers2/actions/workflows/deploy.yaml)

限界開発鯖共有サーバーでホストするコンテナの各種 Compose ファイルや設定ファイルを管理するリポジトリです．
旧[approvers/containers](https://github.com/approvers/containers)の後継です．

## 使い方

1. このリポジトリをクローンして新しいブランチを作成する．
1. プロジェクト名のディレクトリを作成する．
1. ディレクトリ内に `compose.yml` を作成 & 編集する．(Docker Compose v2 の設定例は[下記](#docker-compose-の設定例)を参照)
1. コミット & プッシュして PR を作成する．

> [!IMPORTANT]
> コミット偽装を防ぐために, Containers2 では全コミットに GPG 署名を要求しています.
> GPG 署名が行われていないコミットがあるプルリクエストはマージできません. 詳しくは GitHub Docs を参照してください.
>
> [About commit signature verification - GitHub Docs](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)

### `compose.yml` 内で参照する環境変数やシークレットなどの秘密情報を扱う場合

秘密情報は PGP 鍵を用いて暗号化することで管理します．暗号化されたファイルは GitHub Actions にてデプロイ前に復号されます．

1. `compose.yml` と同じディレクトリに参照するファイルを作成する．(例: `.env`)
1. ファイルを編集して秘密情報を記述する．
1. `compose.yml` で秘密情報を参照するように設定する．(例: `env_file: .env`)
1. `<repository root>/encrypt.sh` を使ってファイルを暗号化する．(実行例: `./encrypt.sh .env`)
1. `.env` が削除され， `.env.secret` が作成される．
1. `.env.secret` をコミット & プッシュする．
1. 場合に応じて， `.env.example` などを作成するといいでしょう．

> [!CAUTION]
> 機密情報を扱う場合は必ず暗号化してください．暗号化せずに Commit & Push した場合の責任は負いかねます．

### Docker Compose の設定例

Docker Compose v2 での設定例を以下に示します. あくまで設定例で貴方がデプロイするアプリケーションの仕様に合わせて適宜変更してください.

> [!CAUTION]
> Docker Compose v1 は2023年7月に非推奨になりました.
> これにより, **Containers2 では Docker Compose v1 を用いたデプロイは禁止とします**. 移行方法等については docker docs を参照してください.
>
> [Migrate to Compose V2 - docker docs](https://docs.docker.com/compose/migrate/)

```yaml
services:
  app:
    image: ghcr.io/approvers/ichiyo_ai:v2.1.0
    env_file:
      - .env
    deploy:
      restart_policy:
        delay: 5s
        max_attempts: 3
```

以下は設定時の注意点です.

- `image` に指定する Docker Image のタグは **バージョンを直接指定する** か, **マイナーバージョンだけを指定する**ようにします.
  - `latest` は破壊的変更を常に受け入れる可能性があり, 壊れたバージョンが Containers2 にデプロイされる可能性があります. そのような Docker Compose は受け入れる予定はありません.
  - マイナーバージョンのみを指定する場合, メンテナが手動でデプロイを行うか, 他のコンテナのデプロイが行われるまでは更新されなくなってしまいます. 指定する場合は **バージョンを直接指定すること** を推奨します.
  - バージョンを直接指定した場合は Renovate が自動でイメージの更新を行ってくれます. もちろん, 手動で更新することも可能です.
- `env_file` には **コンテナ上で参照されるファイル名** を指定します. `encrypt.sh` が作成する `*.secret` ファイルを指定しても動作しないのでご注意ください.

## 注意

- マウント方式のボリュームを使用してこのリポジトリ内のファイルを参照することはできません．
  - 何かしらの設定ファイルを参照したい場合は [`config:`](https://docs.docker.com/compose/compose-file/08-configs/) を使用してください．
  - DB 等の永続化をした場合はマウント方式以外のボリュームを使用してください．
- 上記の運用はあくまで暫定ですので，今後変更される可能性があります．
- 秘密情報は GitHub Actions で復号されるため，悪意ある Org メンバーによって秘密情報が盗まれる可能性があります．
  - この問題に関しては今後の変更によって対処する予定です．
