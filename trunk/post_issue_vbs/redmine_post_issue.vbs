' redmine_post_issue.vbs - 
'     HTTP POSTでRedmineにチケットを登録するサンプルスクリプト
'
' Copyright (C) 2009 FAR END Technologies Corporation
' Licensed under The MIT License.
'
'
' ＜このスクリプトについて＞
' VBScriptでRedmineのチケットを登録するサンプルです。HTTP POSTによりチケットの
' 内容をRedmineに送信します。メールでチケットを登録する機能で内部的に使用されて
' いるコントローラを利用しています。
'
' ＜動作環境＞
' ・Redmine 0.8以降
' ・VBScriptが動作するWindows環境
'
' ＜使用するための準備＞
' (1) Redmineの「管理」→「設定」→「受信メール」で、APIキーを登録します。
' (2) REDMINE_API_KEY定数の値を(1)で登録したAPIキーの値にします。
' (3) REDMINE_URL定数の値をチケットを登録したいRedmineのURLにします。
'
' ＜使い方＞
' PostIssue関数を適切な引数とともに呼び出すとRedmineにチケットが登録されます。
'
' チケットの登録に成功するとTrue、失敗するとFalseが返されます。
' サーバとの通信が失敗したときなどは実行時エラーが発生し中断します。


Option Explicit

Const REDMINE_API_KEY = "uIPT9i2IkmuwdyQtQzat"
Const REDMINE_URL = "http://redmine.example.jp/mail_handler"

Dim ReqStatus
Dim Body

Body = _
    "Project: sandbox" & vbCrLf & _
    "Tracker: 機能" & vbCrLf & _
    "テストチケットの登録です。" & vbCrLf & _
    "HTTP POSTで登録します。" & vbCrLf

ReqStatus = PostIssue("redmine-user@example.jp", "VBScriptからのテスト", Body)

If ReqStatus <> False Then
    MsgBox "登録成功"
Else
    ' Falseが返される状況の例:
    ' * FromAddrで指定されたメールアドレスのユーザーが存在しない
    ' * Bodyの中でProjectキーワードが指定されていない
    ' * Projectキーワードで指定されたプロジェクト識別子が存在しない
    ' * URLのパス名部分が正しくない
    '
    MsgBox "登録失敗"
End If


' PostIssue - Redmineにチケットを登録する
'
' [引数]
' FromAddr: 登録者のメールアドレス(Redmineに登録されているもの)
'
' Subject:  チケットの題名
'
' Body:     チケットの内容。プロジェクトやトラッカー等もメールによるチケット
'           登録と同じ書式で指定する。
'           http://www.redmine.org/wiki/redmine/RedmineReceivingEmails
'
' [戻り値]
' True:  成功
' False: 失敗
'
Function PostIssue(FromAddr, Subject, Body)
  PostIssue = PostIssueWithFile(FromAddr, Subject, Body, "")
End Function



' PostIssueWithFile - Redmineにチケットを登録する（添付ファイル付き）
'
' [引数]
' FromAddr: 登録者のメールアドレス(Redmineに登録されているもの)
'
' Subject:  チケットの題名
'
' Body:     チケットの内容。プロジェクトやトラッカー等もメールによるチケット
'           登録と同じ書式で指定する。
'           http://www.redmine.org/wiki/redmine/RedmineReceivingEmails
'
' AttachFile: 添付ファイルのフルパス名。空文字列の場合は添付無し。
'
' [戻り値]
' True:  成功
' False: 失敗
'
Function PostIssueWithFile(FromAddr, Subject, Body, AttachFile)

    Dim iMsg
    Dim iConf
    Dim strm
    Dim xhr

    Set iConf = CreateObject("CDO.Configuration")
    iConf.Load -1  ' cdoSourceDefaults

    Set iMsg = CreateObject("CDO.Message")
    With iMsg
        Set .Configuration = iConf
        .From = FromAddr
        .Subject = Subject
        .TextBody = Body
        .TextBodyPart.Charset = "utf-7"
        If Trim(AttachFile) <> "" Then
            .AddAttachment AttachFile
        End If
    End With

    Set xhr = CreateObject("Microsoft.XMLHTTP")
    xhr.Open "POST", REDMINE_URL, False
    xhr.SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    Set strm = iMsg.GetStream ' RFC822形式のデータを得る
    xhr.Send _
        "key=" & REDMINE_API_KEY & _
        "&allow_override=tracker,category,priority" & _
        "&email=" & UrlEncode(strm.ReadText)

    If xhr.status = 201 Then
        PostIssueWithFile = True
    Else 
        PostIssueWithFile = False
    End If

    Set iMsg = Nothing
    Set iConf = Nothing
   
End Function

Function UrlEncode(ByRef FromStr)

    Const ExceptChars = _
        "0123456789$-_.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ% +"

    Dim i
    Dim ch
    Dim EncodeTbl(256)

    UrlEncode = FromStr

    UrlEncode = Replace(UrlEncode, "%", "%25")
    UrlEncode = Replace(UrlEncode, "+", "%2B")
    UrlEncode = Replace(UrlEncode, " ", "+")
    For i = 0 To 255
        ch = Chr(i)
        If InStr(ExceptChars, ch) = 0 Then
            UrlEncode = Replace(UrlEncode, ch, "%" & Right("0" & Hex(i), 2))
        End If
    Next

End Function
