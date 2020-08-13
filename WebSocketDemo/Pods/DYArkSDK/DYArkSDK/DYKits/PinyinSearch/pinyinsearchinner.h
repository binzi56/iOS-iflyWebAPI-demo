#pragma once
#ifndef _PINYINSEARCHINNER_H
#define _PINYINSEARCHINNER_H
#include <vector>

class PinYinInfo
{
public:
	const int& operator[](int index) const { return m_info[index + 1]; }
	int& operator[](int index) { return m_info[index + 1]; }
	size_t size() const{ return m_info[0]; }
	void setSize(int s) { m_info[0] = s; }

private:
	int m_info[4];
};

class CPinYinSearch
{
public:
	CPinYinSearch();
	~CPinYinSearch();

	inline int preparePinYinIndex(const std::wstring& name, wchar_t* noChineseBuf, int& nNoChineseBufSize);
	inline void getPinYinIndex(int index, std::vector<int>& pinYinIndex);

private:
	std::vector<PinYinInfo> m_pinYinForName;//一个中文名对应的拼音，由于多音字的存在，每个汉字的拼音用一个vector表示
	std::vector<int> m_coeffecient;	//为了枚举出一个中文名的所有拼音组合
};
#endif