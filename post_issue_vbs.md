post\_issue\_vbs - VBScriptからRedmineに対してチケットを登録するサンプルスクリプト


# 概要 #

post\_issue\_vbsは、Windows上でRedmineにチケットを登録する、VBScriptによるサンプルです。他のツールと組み合わせてチケットの登録を自動化したり、Excelからチケットを一括登録したり等の応用が可能です。


# ダウンロード #

  * [post\_issue\_vbs\_20090317\_r2.zip](http://code.google.com/p/farend-redmine-tools/downloads/detail?name=post_issue_vbs_20090317_r2.zip)
  * svn: http://farend-redmine-tools.googlecode.com/svn/trunk/post_issue_vbs/


# 使用方法 #

## 使用するための準備 ##

  1. Redmineの「管理」→「設定」→「受信メール」で、APIキーを登録します。
  1. REDMINE\_API\_KEY定数の値を(1)で登録したAPIキーの値にします。
  1. REDMINE\_URL定数の値をチケットを登録したいRedmineのURLにします。


## 使い方 ##

PostIssue関数を適切な引数とともに呼び出すとRedmineにチケットが登録されます。

チケットの登録に成功するとTrue、失敗するとFalseが返されます。
サーバとの通信が失敗したときなどは実行時エラーが発生し中断します。

```
Const REDMINE_API_KEY = "uIPT9i2IkmuwdyQtQzat"
Const REDMINE_URL = "http://redmine.example.jp/mail_handler"

Body = _
    "Project: sandbox" & vbCrLf & _
    "Tracker: 機能" & vbCrLf & _
    "テストチケットの登録です。" & vbCrLf & _
    "HTTP POSTで登録します。" & vbCrLf

ReqStatus = PostIssue("redmine-user@example.jp", "VBScriptからのテスト", Body)

If ReqStatus <> False Then
    MsgBox "登録成功"
Else
    MsgBox "登録失敗"
End If
```


# 動作環境 #

Windows XP SP2 + Redmine 0.8.1で動作確認しています。