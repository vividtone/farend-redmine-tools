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

// PostIssueWithFile�����PostIssue�̖߂�l�B
// REDMINE_UNKNOWN_EXCEPTION�ȊO��HTTP�X�e�[�^�X�R�[�h�����̂܂ܕԂ��Ă���̂�
// ���L�ȊO�̃R�[�h���Ԃ����\��������B
//
// �o�^����
const int REDMINE_POST_CREATED = 201;
// API�L�[������Ă���
const int REDMINE_POST_INVALID_KEY = 403;
// ���b�Z�[�W���s��(Project�L�[���[�h���Ȃ��A���[���A�h���X������Ă��铙)
const int REDMINE_POST_UNPROCESSABLE_ENTITY = 422;
// ����`�G���[(�������ɗ�O����������)
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


