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

	// �G���R�[�h�p�e�[�u��������
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
	[����]
	LPCSTR RedmineUrl	POST��URL
	LPCSTR ApiKey		���[����M�pAPI�L�[
	LPCSTR FromAddress	�`�P�b�g�o�^�҂̃��[���A�h���X
	LPCSTR Subject		�`�P�b�g�̌���
	LPCSTR Body			�`�P�b�g�̓��e�BProject:���̃L�[���[�h���w�肷��B
	LPCSTR AttachFile	�Y�t�t�@�C���̃t���p�X���B�Y�t�t�@�C�����Ȃ��ꍇ��NULL�B

	Body�̏����̓��[���ɂ��`�P�b�g�o�^�Ɠ��������𗘗p����B�����̏ڍׂ�
	���LURL���Q�ƁB
	http://www.redmine.org/wiki/redmine/RedmineReceivingEmails

	[�߂�l]
	Redmine����Ԃ��ꂽHTTP�X�e�[�^�X�R�[�h�܂���0�i��O�����j�B
	����Ƀ`�P�b�g���o�^���ꂽ�ꍇ��201�B

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
		// CDO.Message�I�u�W�F�N�g���g�p����RFC822�`���̃f�[�^���쐬�B
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

		// Redmine��POST
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

