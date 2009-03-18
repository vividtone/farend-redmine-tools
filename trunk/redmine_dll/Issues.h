//
// redmine.dll - Utility functions to access Redmine
//
// Copyright (C) 2009 FAR END Technologies Corporation
// Licensed under the MIT License.
//
//---------------------------------------------------------------------------

#ifndef IssuesH
#define IssuesH
//---------------------------------------------------------------------------
#include <windows.h>
//---------------------------------------------------------------------------

// PostIssueWithFileおよびPostIssueの戻り値。
// REDMINE_UNKNOWN_EXCEPTION以外はHTTPステータスコードをそのまま返しているので
// 下記以外のコードが返される可能性もある。
//
// 登録成功
const int REDMINE_POST_CREATED = 201;
// APIキーが誤っている
const int REDMINE_POST_INVALID_KEY = 403;
// メッセージが不正(Projectキーワードがない、メールアドレスが誤っている等)
const int REDMINE_POST_UNPROCESSABLE_ENTITY = 422;
// 未定義エラー(処理中に例外が発生した)
const int REDMINE_POST_UNKNOWN_EXCEPTION = 0;
//---------------------------------------------------------------------------

extern "C" int __export __stdcall PostIssueWithFile(
									LPCSTR RedmineUrl,
									LPCSTR ApiKey,
									LPCSTR FromAddress,
									LPCSTR Subject,
									LPCSTR Body,
									LPCSTR AttachFile);

extern "C" int __export __stdcall PostIssue(
									LPCSTR RedmineUrl,
									LPCSTR ApiKey,
									LPCSTR FromAddress,
									LPCSTR Subject,
									LPCSTR Body);
#ifdef COMMENT
extern "C" int __export __stdcall PostIssueWithFileW(
									LPCWSTR RedmineUrl,
									LPCWSTR ApiKey,
									LPCWSTR FromAddress,
									LPCWSTR Subject,
									LPCWSTR Body,
									LPCWSTR AttachFile);

extern "C" int __export __stdcall PostIssueW(
									LPCWSTR RedmineUrl,
									LPCWSTR ApiKey,
									LPCWSTR FromAddress,
									LPCWSTR Subject,
									LPCWSTR Body);
#endif

//---------------------------------------------------------------------------
#endif


