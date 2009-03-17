' redmine_post_issue.vbs - 
'     HTTP POST��Redmine�Ƀ`�P�b�g��o�^����T���v���X�N���v�g
'
' Copyright (C) 2009 FAR END Technologies Corporation
' Licensed under The MIT License.
'
'
' �����̃X�N���v�g�ɂ��ā�
' VBScript��Redmine�̃`�P�b�g��o�^����T���v���ł��BHTTP POST�ɂ��`�P�b�g��
' ���e��Redmine�ɑ��M���܂��B���[���Ń`�P�b�g��o�^����@�\�œ����I�Ɏg�p�����
' ����R���g���[���𗘗p���Ă��܂��B
'
' ���������
' �ERedmine 0.8�ȍ~
' �EVBScript�����삷��Windows��
'
' ���g�p���邽�߂̏�����
' (1) Redmine�́u�Ǘ��v���u�ݒ�v���u��M���[���v�ŁAAPI�L�[��o�^���܂��B
' (2) REDMINE_API_KEY�萔�̒l��(1)�œo�^����API�L�[�̒l�ɂ��܂��B
' (3) REDMINE_URL�萔�̒l���`�P�b�g��o�^������Redmine��URL�ɂ��܂��B
'
' ���g������
' PostIssue�֐���K�؂Ȉ����ƂƂ��ɌĂяo����Redmine�Ƀ`�P�b�g���o�^����܂��B
'
' �`�P�b�g�̓o�^�ɐ��������True�A���s�����False���Ԃ���܂��B
' �T�[�o�Ƃ̒ʐM�����s�����Ƃ��Ȃǂ͎��s���G���[�����������f���܂��B


Option Explicit

Const REDMINE_API_KEY = "uIPT9i2IkmuwdyQtQzat"
Const REDMINE_URL = "http://redmine.example.jp/mail_handler"

Dim ReqStatus
Dim Body

Body = _
    "Project: sandbox" & vbCrLf & _
    "Tracker: �@�\" & vbCrLf & _
    "�e�X�g�`�P�b�g�̓o�^�ł��B" & vbCrLf & _
    "HTTP POST�œo�^���܂��B" & vbCrLf

ReqStatus = PostIssue("redmine-user@example.jp", "VBScript����̃e�X�g", Body)

If ReqStatus <> False Then
    MsgBox "�o�^����"
Else
    ' False���Ԃ����󋵂̗�:
    ' * FromAddr�Ŏw�肳�ꂽ���[���A�h���X�̃��[�U�[�����݂��Ȃ�
    ' * Body�̒���Project�L�[���[�h���w�肳��Ă��Ȃ�
    ' * Project�L�[���[�h�Ŏw�肳�ꂽ�v���W�F�N�g���ʎq�����݂��Ȃ�
    ' * URL�̃p�X���������������Ȃ�
    '
    MsgBox "�o�^���s"
End If


' PostIssue - Redmine�Ƀ`�P�b�g��o�^����
'
' [����]
' FromAddr: �o�^�҂̃��[���A�h���X(Redmine�ɓo�^����Ă������)
'
' Subject:  �`�P�b�g�̑薼
'
' Body:     �`�P�b�g�̓��e�B�v���W�F�N�g��g���b�J�[�������[���ɂ��`�P�b�g
'           �o�^�Ɠ��������Ŏw�肷��B
'           http://www.redmine.org/wiki/redmine/RedmineReceivingEmails
'
' [�߂�l]
' True:  ����
' False: ���s
'
Function PostIssue(FromAddr, Subject, Body)
  PostIssue = PostIssueWithFile(FromAddr, Subject, Body, "")
End Function



' PostIssueWithFile - Redmine�Ƀ`�P�b�g��o�^����i�Y�t�t�@�C���t���j
'
' [����]
' FromAddr: �o�^�҂̃��[���A�h���X(Redmine�ɓo�^����Ă������)
'
' Subject:  �`�P�b�g�̑薼
'
' Body:     �`�P�b�g�̓��e�B�v���W�F�N�g��g���b�J�[�������[���ɂ��`�P�b�g
'           �o�^�Ɠ��������Ŏw�肷��B
'           http://www.redmine.org/wiki/redmine/RedmineReceivingEmails
'
' AttachFile: �Y�t�t�@�C���̃t���p�X���B�󕶎���̏ꍇ�͓Y�t�����B
'
' [�߂�l]
' True:  ����
' False: ���s
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
    Set strm = iMsg.GetStream ' RFC822�`���̃f�[�^�𓾂�
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
