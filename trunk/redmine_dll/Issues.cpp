//
// redmine.dll - Utility functions to access Redmine
//
// Copyright (C) 2009 FAR END Technologies Corporation
// Licensed under the MIT License.
//
//---------------------------------------------------------------------------

#pragma hdrstop

#include "Issues.h"
#include <Classes.hpp>
#include <wchar.h>
#include <stdio.h>

//---------------------------------------------------------------------------

#pragma package(smart_init)

String UrlEncode(const AnsiString FromStr)
{
	const char *safe_chars =
		"0123456789$-_.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

	typedef struct {
		int len;
		CHAR encoded[4];
	} encoded_char_t;

	encoded_char_t encode_tbl[256];
	UCHAR *pSrc, *pDst;
	AnsiString Result;

	// エンコード用テーブル初期化
	for (int i = 0 ; i < 256 ; i++) {
		encoded_char_t *p = &encode_tbl[i];
		if (strchr(safe_chars, i)) {
			sprintf(p->encoded, "%c", i);
		} else if (i == ' ') {
			sprintf(p->encoded, "+");
		} else {
			sprintf(p->encoded, "%%%02x", i);
		}
		p->len = strlen(p->encoded);
	}

	Result.SetLength(FromStr.Length() * 3);
	pSrc = (CHAR *)FromStr.data();
	pDst = (CHAR *)Result.data();


	while (*pSrc) {
		encoded_char_t *ptbl = &encode_tbl[*pSrc];
		for (int i = 0 ; i < ptbl->len ; i++) {
			*pDst++ = ptbl->encoded[i];
		}
        pSrc++;
	}
	Result.SetLength(pDst - (CHAR *)Result.data());

	return Result;
}

/*
	[引数]
	LPCSTR RedmineUrl	POST先URL
	LPCSTR ApiKey		メール受信用APIキー
	LPCSTR FromAddress	チケット登録者のメールアドレス
	LPCSTR Subject		チケットの件名
	LPCSTR Body			チケットの内容。Project:等のキーワードも指定する。
	LPCSTR AttachFile	添付ファイルのフルパス名。添付ファイルがない場合はNULL。

	Bodyの書式はメールによるチケット登録と同じ書式を利用する。書式の詳細は
	下記URLを参照。
	http://www.redmine.org/wiki/redmine/RedmineReceivingEmails

	[戻り値]
	Redmineから返されたHTTPステータスコードまたは0（例外発生）。
	正常にチケットが登録された場合は201。

*/
extern "C" int __export __stdcall PostIssueWithFile(
									LPCSTR RedmineUrl,
									LPCSTR ApiKey,
									LPCSTR FromAddress,
									LPCSTR Subject,
									LPCSTR Body,
									LPCSTR AttachFile)
{
	Variant iMsg, iConf, iBodyPart, strm, xhr;
	WideString WBody, RawBodyPart, postdata;
	int body_len;

	WBody = WideString(Body);
	body_len = WBody.Length();
	if (body_len < 2 || WBody.SubString(body_len - 1, 2) != WideString("\r\n")) {
		WBody += "\r\n";
	}

	try {
		// CDO.Messageオブジェクトを使用してRFC822形式のデータを作成。
		iConf = Variant::CreateObject("CDO.Configuration");
		iConf.OleFunction("Load", -1);

		iMsg = Variant::CreateObject("CDO.Message");
		iMsg.OlePropertySet("Configuration", iConf);

		iMsg.OlePropertySet("From", Variant(WideString(FromAddress)));
		iMsg.OlePropertySet("Subject", Variant(WideString(Subject)));
		iMsg.OlePropertySet("TextBody", Variant(WBody));
		iBodyPart = iMsg.OlePropertyGet("TextBodyPart");
		iBodyPart.OlePropertySet("Charset", "utf-8");
		iBodyPart.OlePropertySet("ContentTransferEncoding", "base64");
		if (AttachFile) {
			iMsg.OleFunction("AddAttachment", Variant(WideString(AttachFile)));
		} else {
			iMsg.OleFunction("AddAttachment", "");
		}
		strm = iMsg.OleFunction("GetStream");

		postdata =
			"key=" + WideString(ApiKey) +
			"&allow_override=tracker,category,priority&email=";
		while (1) {
			RawBodyPart = (AnsiString)strm.OleFunction("ReadText", 1024 * 1024);
			if (RawBodyPart.Length() == 0) {
				break;
			}
			postdata += WideString(UrlEncode(RawBodyPart));
		}

		// RedmineにPOST
		xhr = Variant::CreateObject("Microsoft.XMLHTTP");
		xhr.OleFunction("Open", "POST", WideString(RedmineUrl), False);
		xhr.OleFunction("SetRequestHeader", "Content-Type", "application/x-www-form-urlencoded");

		xhr.OleFunction("Send", Variant(postdata));

		return xhr.OlePropertyGet("status");
	} catch (...) {
		return 0;
	}
}


extern "C" int __export __stdcall PostIssue(
									LPCSTR RedmineUrl,
									LPCSTR ApiKey,
									LPCSTR FromAddress,
									LPCSTR Subject,
									LPCSTR Body)
{
	return PostIssueWithFile(RedmineUrl, ApiKey, FromAddress, Subject, Body, NULL);
}

