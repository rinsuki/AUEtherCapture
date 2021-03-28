# サーバーへのアップロードと Discord Webhook 連携

AUEtherCapture は、アップロード先のサーバーを自分で用意することにより、リプレイを自動でアップロードして、(オプションで) Discord の Webhook 経由でリプレイのアップロードを通知することができます。

## `upload_creds.json` を作る

[コンフィグディレクトリ](./config-dir.md)に `upload_creds.json` を置くことにより、サーバーへのリプレイ自動アップロードが有効になります。

`upload_creds.json` に書くべき内容は以下の通りです:


```json
{
    "url": "アップロード先のURL",
    "token": "認証トークン"
}
```

## アップロード先サーバーを作る

AUEtherCapture は以下の通りに HTTP POST リクエストを送信し、HTTPレスポンスとして`200`から`299`までのステータスコードが返ってきた場合は、レスポンス本文の文字列をリプレイの再生URLとして処理します。

|項目名|説明|
|---|---|
|リクエストメソッド|`POST`|
|URL|`upload_creds.json` で指定された URL|
|Content-Type|`application/gzip`|
|Authorization|`Bearer 認証トークンとして指定されたトークン`|
|リクエスト本文|リプレイデータを MessagePack で出力し gzip 圧縮をしたもの|

MessagePack と gzip のデコードができればだいたい何の言語でも書けると思うので、PHP とか CGI とか最近流行りのサーバーレスとか、好きな技術スタックで書いてもらってかまいません。

### リプレイの再生URLについて

aureplayerの公式である https://aureplayer.rinsuki.vercel.app/ は、現状リプレイの再生URLに cdn.rinsuki.net しか指定できません。そのため、独自のリプレイ保存サーバーを使う場合は、aureplayer を fork して自前のサーバーを指定できるように改造する必要があります。

## Discord Webhook

Discord Webhook でのアップロード通知をする場合は、以下の手順を踏む必要があります。

0. Discord 内で Webhook URL を発行する
1. `webhooks.json` に Webhook URL を書く
2. AUEtherCapture の起動時にオプションで `--discord-webhook-name webhooks.jsonでの名前` を指定する

### `webhooks.json` の書き方

[コンフィグディレクトリ](./config-dir.md)に `webhooks.json` を配置し、以下のような JSON を書きます。

```json
{
    "webhook-name": "https://discord.com/api/webhooks/から始まる Discord で発行された Webhook URL"
}
```

`webhook-name` には、JSONの文字列リテラルとして利用できる文字列であれば何でも利用できます (が、オプションに指定する時の手間を考えると `/[a-z0-9-_]{1,20}/` ぐらいが無難でしょう)。

また、日によってあちこちのサーバーで遊んでいる場合でも、`webhooks.json` にあらかじめサーバーごとの Webhook URL を書いておき、起動オプションで切り替えることにより、わざわざ JSON を毎回書き換えずに投稿先を切り替えることができます。