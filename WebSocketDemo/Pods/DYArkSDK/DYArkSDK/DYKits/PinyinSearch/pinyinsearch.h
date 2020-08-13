
/****************************************************************************
Author: yy
Email : yy@yy.com
Mobile: 134567890
Remark:
****************************************************************************/
#pragma once
#ifndef _PINYINSEARCH_H
#define _PINYINSEARCH_H
#include <string>
#include <vector>


//#define PINYIN_TEST

namespace yycommon
{
	//param pool , words dictionary
	//param pinYin , word to be searched
	//param result , the search result
    //param ignoringCase, ignoring Case
    void search(const std::vector<std::wstring>& pool, const std::wstring& pinYin, std::vector<std::wstring>& result, bool ignoringCase);

	/*
	用拼音匹配姓名
	pool:名字集合
	pinyin:用户输入的查找拼音 非字母或者‘'’会被过滤掉
	result:接收结果
	注意：该函数线程安全
	*/
	void pinyinSearch(const std::vector<std::wstring>& pool, const std::wstring& pinYin, std::vector<std::wstring>& result);

	/*
	first:名字
	second:附带的key，使用者传入，无脑返回，可以用来作为唯一id。
	*/
	void pinyinSearchEx(const std::vector<std::pair<std::wstring, unsigned int> >& pool, const std::wstring& pinYin, std::vector<std::pair<std::wstring, unsigned int> >& result);

	bool hasChinese(const std::wstring &searthstring);

	bool hasNumber(const std::wstring &searthstring);


}
#endif
