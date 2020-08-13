#include "pinyinsearch.h"
#include "pinyinsearchinner.h"
#include <algorithm>
#include "wchar.h"

#if defined(_UNICODE)
#define _T(x) L ##x
#else
#define _T(x) x
#endif

/*
拼音的总数不超过512，所有用十位来表示足够了，32位可以存储一个字的三个拼音，
可以满足绝大多数的多音词情况
*/
#define FIRST_PINYIN(x)	((x) & 0x000003ff)	
#define SECOND_PINYIN(x) (((x>>10) & 0x000003ff))	
#define THIRD_PINYIN(x) (((x>>20) & 0x000003ff))

//对拼音进行分词
/*
src:用户输入的查找串例如：hujintao
out:切分后的结果，例如：hu,jin,tao
主意：用户可以如果li'nan来区别linan
*/
void segmentPinYin(const std::wstring& src, std::vector<std::wstring>& out);


//快速计算相似度，时间复杂度为O(SIZE(pinYin)+SIZE(pinYinPool)),思想是只有pinYin中所有字母在pinYinPool中出现即得到
//大于0的相似度。
/*
src:用户输入的查找串例如：hujintao
pinYinPool:一个待匹配的姓名的拼音索引
*/
bool filterFast(const std::wstring& pinYin, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf);

/*
精确计算相似度，只匹配每个拼音的前面部分
pinYinSeq:hu,jin,tao
pinYinPool:同similarityFast
*/
double similarityPrecise(const std::vector<std::wstring>& pinYinSeg, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf);
double precise( const std::vector<std::wstring>& pinYinSeg, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf );
double index(const std::wstring& pinYin, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf);
#define CHINESE_WORD_BEGIN	(0x4e00)
#define CHINESE_WORD_END	(0x9fbf)

/*
拼音组合,主意，第一个拼音无效，只是一个占位符， 因为index0代表多音字中没有拼音的意义，为了避免歧义，所以第一个拼音无效
*/
const wchar_t* g_pinYin[] =
{
#include "pinyin.txt"
};

const int g_pinYinNum = (sizeof(g_pinYin)/sizeof(g_pinYin[0]));
/*
汉字到拼音的映射表
*/
int g_c2e[20927] = 
{
#include "c2e.txt"
};

struct Node
{
public:
	Node():m_parent(NULL),m_bLeaf(false)
	{
		for (size_t i = 0; i < 26; ++i)
		{
			m_children[i] = 0;
		}
	}
	~Node()
	{
		for (size_t i = 0; i < 26; ++i)
		{
			delete m_children[i];
			m_children[i] = NULL;
		}
	}
public:
	std::wstring m_str;
	Node* m_children[26];
	Node* m_parent;
	bool m_bLeaf;
};

void constructOne(Node* root,const wchar_t* str)
{
	Node* pParent = root;
	while(*str)
	{
		if (*str < _T('a') || *str > _T('z'))
		{
			//assert(false);
			str++;
			continue;
		}

		Node* node = pParent->m_children[*str - _T('a')];
		if (node)
		{
			pParent = node;
		}
		else
		{
			Node* node = new Node;
			node->m_parent = pParent;
			pParent->m_children[*str - _T('a')] = node;
			node->m_str = pParent->m_str;
			node->m_str += *str;
			pParent = node;
		}
		str++;
	}
	pParent->m_bLeaf = true;
}

//初始化拼音key tree
Node * createPinYinTree()
{
	Node *root = new Node;
	//这里需要从1开始循环，因为第0个元素是无效值
	for (size_t i = 1; i < g_pinYinNum; ++i)
	{
		constructOne(root, g_pinYin[i]);
	}

	return root;
}

enum Category
{
	Digital,
	Letter,
	Space,
	Chinese,
	Other
};

Category _category(wchar_t c)
{
	if (c >= CHINESE_WORD_BEGIN && c <= CHINESE_WORD_END)
	{
		return Chinese;
	}
	else if (c >= _T('a') && c <= _T('z'))
	{
		return Letter;
	}
	else if (c >= _T('A') && c <= _T('Z'))
	{
		return Letter;
	}
	else if (c >= _T('0') && c <= _T('9'))
	{
		return Digital;
	}
	else if (c == _T(' '))
	{
		return Space;
	}

	return Other;
}

bool _hasChinese(const std::wstring &name)
{
	for (std::wstring::const_iterator it = name.begin(); it != name.end(); ++it)
	{
		if (_category(*it) == Chinese)
		{
			return true;
		}
	}
	return false;
}

Node *_getRoot()
{
	static Node *s_root = NULL;
	if(s_root == NULL)
	{
		s_root = createPinYinTree();		
	}

	return s_root;
}

void segmentPinYin(const std::wstring& src, std::vector<std::wstring>& out)
{
	out.clear();

	Node *root = _getRoot();
	Node *node = root;
	Node *tmp = NULL;
	size_t begin = 0;
	for (size_t i = 0; i < src.size(); ++i)
	{
		if (src[i] != _T('\''))
		{	
			tmp = node->m_children[src[i] - _T('a')];
			if (tmp)
			{
				node = tmp;
			}
			else
			{
				out.push_back(src.substr(begin, i-begin));
				node = root;
				begin = i;
				i--;
			}
		}
		else
		{
			out.push_back(src.substr(begin, i-begin));
			node = root;
			begin = i+1;
		}
	}

	//最后一个
	if (begin < src.size())
	{
		out.push_back(src.substr(begin));
	}
}

bool filterFast(const std::wstring& pinYin, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf)
{
	char cInfo[26] = {0};
	const wchar_t* str = NULL;

	int index = 0;
	for (size_t i = 0; i < pinYinPool.size(); ++i)
	{
		index = pinYinPool[i];
		str = (index<g_pinYinNum) ? (g_pinYin[index]):(noChineseBuf + (index-g_pinYinNum));
		for (; *str; str++)
		{
			cInfo[*str - _T('a')]++;
		}
	}

	for (size_t i = 0; i < pinYin.size(); ++i)	//i用户输入的字母index
	{
		if (pinYin[i] == _T('\''))
		{
			continue;
		}

		if (cInfo[pinYin[i] - _T('a')] > 0)
		{
			cInfo[pinYin[i] - _T('a')]--;
		}
		else
		{
			return false;
		}
	}

	return true;
}

struct Result
{
	Result(double w, const std::wstring& s, unsigned int c):m_dWeight(w), m_str(s), m_cookie(c) {}

	bool operator < (Result const& r) const
	{
		return m_dWeight < r.m_dWeight;
	}

	std::wstring string() const { return m_str; }
	unsigned int cookie() const {return m_cookie;}

private:
	double m_dWeight;
	std::wstring m_str;
	unsigned int m_cookie;
};
//There is no function wcsnlen in NDK(R10).so code it again
size_t wcsnlen(const wchar_t *s, size_t maxlen)
{
        size_t len;

        for (len = 0; len < maxlen; len++, s++) {
                if (!*s)
                        break;
        }
        return (len);
}

double similarityPrecise(const std::vector<std::wstring>& pinYinSeg, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf)
{
	if (pinYinSeg.size() > pinYinPool.size())
	{
		return 0;
	}

	double dWeight = 0;
	size_t segIndex = 0;
	size_t poolIndex = 0;
	while (segIndex < pinYinSeg.size() && poolIndex < pinYinPool.size())
	{
		const std::wstring& seg = pinYinSeg[segIndex];
		const wchar_t* pool = (pinYinPool[poolIndex]<g_pinYinNum)
							? (g_pinYin[pinYinPool[poolIndex]]) : (noChineseBuf + (pinYinPool[poolIndex]-g_pinYinNum));
		size_t nPoolLen = wcsnlen(pool, 256);
		if (seg.size() > nPoolLen)
		{
			poolIndex++;
			continue;
		}

		//看pool的开头部分是不是seg
		bool bInclude = true;
		for (size_t i = 0; i < seg.size(); ++i)
		{
			if (seg[i] != pool[i])
			{
				bInclude = false;
				break;
			}
		}

		if (bInclude == true)
		{
			/*
			seg.size()/nPoolLen代表一一匹配时候的相似度
			1/poolIndex-segIndex+1表示匹配的两个拼音之间的位置距离
			1/pinYinPool.size()表示成功匹配一对得到的基准积分奖励
			最终的积分有上述三者共同决定
			*/
			dWeight += 1.0*seg.size()/(nPoolLen*pinYinPool.size()*(poolIndex-segIndex+1));
			segIndex++;
		}
		poolIndex++;
	}

	if (segIndex == pinYinSeg.size())	//成功匹配
	{
		return dWeight;
	}

	return 0;
}

double precise( const std::vector<std::wstring>& pinYinSeg, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf )
{
	if (pinYinSeg.size() > pinYinPool.size() || pinYinSeg.size() == 0)
	{
		return 0;
	}
	size_t firstFit = 1;
	size_t prePos = 0;
	size_t nextPos = 1;
	double dWeight = 0.0;
	size_t segIndex = 0;
	size_t poolIndex = 0;
	while (segIndex < pinYinSeg.size() && poolIndex < pinYinPool.size())
	{
		const std::wstring& seg = pinYinSeg[segIndex];
		const wchar_t* pool = (pinYinPool[poolIndex]<g_pinYinNum)
			? (g_pinYin[pinYinPool[poolIndex]]) : (noChineseBuf + (pinYinPool[poolIndex]-g_pinYinNum));
		size_t nPoolLen = wcsnlen(pool, 256);
		if (seg.size() > nPoolLen)
		{
			poolIndex++;
			continue;
		}

		//看pool的开头部分是不是seg
		bool bInclude = true;
		for (size_t i = 0; i < seg.size(); ++i)
		{
			if (seg[i] != pool[i])
			{
				bInclude = false;
				break;
			}
		}

		if (bInclude == true)
		{
			nextPos = poolIndex + 1;
			if(segIndex == 0)
				firstFit = nextPos < 1 ? 1 : nextPos;
			else if(nextPos - prePos > 1)
			{
				poolIndex = firstFit;
				segIndex = 0;
				dWeight = 0.0;
				continue;
			}
			prePos = nextPos;
			dWeight += (double)seg.size()/(nPoolLen < 1 ? 1 : nPoolLen);
			segIndex++;
		}
		poolIndex++;
	}
	
	if (segIndex == pinYinSeg.size() && dWeight > 0.0)	//成功匹配
	{
		dWeight = (dWeight * 40 + 40 - firstFit + ((double)pinYinSeg.size()) / (pinYinPool.size() < 1 ? 1 : pinYinPool.size()));
		return dWeight;
	}

	return 0;
}

double index(const std::wstring& pinYin, const std::vector<int>& pinYinPool, wchar_t* noChineseBuf)
{
	std::wstring str;
	for (size_t i = 0; i < pinYinPool.size(); ++i)
	{
		int ind = pinYinPool[i];
		str += (ind < g_pinYinNum) ? (g_pinYin[ind]):(noChineseBuf + (ind-g_pinYinNum));
	}
	std::wstring::size_type first = str.find(pinYin);
	if(first != std::wstring::npos)
	{
		return 1e-12 / ((first + 1) < 1 ? 1 : (first + 1));
	}
	return 0;
}

void filterInput(const std::wstring& input, std::wstring& output)
{
	output.reserve(input.size());
	for (size_t i = 0; i < input.size(); ++i)
	{
		if ((input[i] >= _T('a') && input[i] <= _T('z'))
			||(input[i] >= _T('A') && input[i] <= _T('Z')))
		{
			output.push_back(towlower(input[i]));
		}
		else if (input[i] == _T('\''))
		{
			output.push_back(input[i]);
		}
	}
}

CPinYinSearch::CPinYinSearch()
{

}


CPinYinSearch::~CPinYinSearch()
{
}

int CPinYinSearch::preparePinYinIndex(const std::wstring& name, wchar_t* noChineseBuf, int& nNoChineseBufSize)
{
	m_pinYinForName.clear();
	size_t nNoChineseNum = 0;
	int nCurrentFreeReserverPos = 0;
	int nTotalPinYinComposition = 1;	//nTotal表示拼音的所有组合的数目
	for (size_t j = 0; j < name.size(); ++j)
	{
		switch (_category(name[j]))
		{
		case Chinese:
			{
				PinYinInfo pinYin;
				if (nNoChineseNum != 0)	//前面有一个非中文字符串
				{
					if (nNoChineseNum < 16 && nCurrentFreeReserverPos < 16)	//目前只保留了16个位置给一个名字中的英文
					{
						noChineseBuf[nNoChineseNum] = 0;
						pinYin[0] = nCurrentFreeReserverPos*16 + g_pinYinNum;
						pinYin.setSize(1);
						m_pinYinForName.push_back(pinYin);
						nCurrentFreeReserverPos++;
						noChineseBuf += 16;
					}

					nNoChineseNum = 0;
				}
				int nIndex = g_c2e[name[j]-CHINESE_WORD_BEGIN];
				if ( nIndex <= 0)
				{
					break;
				}
				int nFirst = FIRST_PINYIN(nIndex);
				pinYin[0] = nFirst;
				int nSecond = SECOND_PINYIN(nIndex);
				if (nSecond)
				{
					pinYin[1] = nSecond;
					int nThrid = THIRD_PINYIN(nIndex);
					if (nThrid)
					{
						pinYin[2] = nThrid;
						pinYin.setSize(3);
					}
					else
					{
						pinYin.setSize(2);
					}
				}
				else
				{
					pinYin.setSize(1);
				}
				nTotalPinYinComposition *= pinYin.size();
				m_pinYinForName.push_back(pinYin);
			}
			break;
		case Letter:
			{
				if (nNoChineseNum < 16 && nCurrentFreeReserverPos < 16)
				{
					noChineseBuf[nNoChineseNum++] = towlower(name[j]);
				}
			}
			break;
		default:
			break;
		}
		
	}

	if (nNoChineseNum != 0)	//前面有一个非中文字符串
	{
		if (nNoChineseNum < 16 && nCurrentFreeReserverPos < 16)
		{
			PinYinInfo pinYin;
			noChineseBuf[nNoChineseNum] = 0;
			pinYin[0] = nCurrentFreeReserverPos*16 + g_pinYinNum;
			pinYin.setSize(1);
			m_pinYinForName.push_back(pinYin);
			nCurrentFreeReserverPos++;
		}
	}

	nNoChineseBufSize = nCurrentFreeReserverPos*16;
	if (m_coeffecient.size() < m_pinYinForName.size())
	{
		m_coeffecient.resize(m_pinYinForName.size());
	}

	if (!m_pinYinForName.empty())
	{
		m_coeffecient[m_pinYinForName.size()-1] = 1;
	}

	if (m_pinYinForName.size() > 1)
	{
		int nPrev = 1;
		for (int j = (int)m_pinYinForName.size()-2; j >= 0; --j)
		{
			m_coeffecient[j] = nPrev*((int)m_pinYinForName[j+1].size());
			nPrev = m_coeffecient[j];
		}
	}

	return nTotalPinYinComposition;
}

void CPinYinSearch::getPinYinIndex(int index, std::vector<int>& pinYinIndex)
{
	if (pinYinIndex.size() == m_pinYinForName.size())
	{
		for (size_t j = 0; j < m_pinYinForName.size(); ++j)
		{
			pinYinIndex[j] = m_pinYinForName[j][index/m_coeffecient[j]];
			index %= m_coeffecient[j];
		}
	}
	else
	{
		pinYinIndex.clear();
		for (size_t j = 0; j < m_pinYinForName.size(); ++j)
		{
			pinYinIndex.push_back(m_pinYinForName[j][index/m_coeffecient[j]]);
			index %= m_coeffecient[j];
		}
	}
}

void searchBycontext(const std::vector<std::wstring>& pool, const std::wstring& pinYin, std::vector<std::wstring>& result, bool ignoringCase)
{
    if (ignoringCase) {
        std::wstring searchKey = pinYin;
        transform(searchKey.begin(),searchKey.end(), searchKey.begin(),tolower);
        
        for(int i = 0 ; i < pool.size() ; ++i) {
            
            std::wstring origlStr = pool.at(i);
            transform(origlStr.begin(),origlStr.end(),origlStr.begin(),tolower);
            
            if(origlStr.find(searchKey) != std::wstring::npos)
                result.push_back(pool.at(i));
        }
    } else {
        for(int i = 0 ; i < pool.size() ; ++i) {
            
            if(pool.at(i).find(pinYin) != std::wstring::npos)
                result.push_back(pool.at(i));
            
        }
    }
}

namespace yycommon
{
	void pinyinSearch(const std::vector<std::wstring>& pool, const std::wstring& input, std::vector<std::wstring>& result)
	{
		if(hasChinese(input)|| hasNumber(input))
			return;
		std::vector<std::pair<std::wstring, unsigned int> > poolEx;
		poolEx.resize(pool.size());
		for (size_t i = 0; i < pool.size(); ++i)
		{
			poolEx[i].first = pool[i];
			poolEx[i].second = 0;
		}

		std::vector<std::pair<std::wstring, unsigned int> > resultEx;
		pinyinSearchEx(poolEx, input, resultEx);
		result.resize(resultEx.size());
		for (size_t i = 0; i < resultEx.size(); ++i)
		{
			result[i] = resultEx[i].first;
		}
	}

	void pinyinSearchEx(const std::vector<std::pair<std::wstring, unsigned int> >& pool, const std::wstring& input, std::vector<std::pair<std::wstring, unsigned int> >& result)
	{
		if(hasChinese(input) || hasNumber(input))
			return;
		//result.clear();
		std::wstring pinYin;
		filterInput(input, pinYin);
		CPinYinSearch pinYinSearch;

		std::vector<std::wstring> pinYinSeg; //拼音分词后的结果
		std::vector<Result> tmpResult;		//存放带权值的结果
		std::vector<std::wstring> vForNoChinese;	//name中有英文，则pinYin再计算一次不分词时候的权重
		vForNoChinese.push_back(pinYin);
		std::vector<int> pinYinIndex;
		pinYinIndex.reserve(8);
		wchar_t bufferForNoChinense[256] = {0};
		int nNoChineseBufSize = 0;
		for (size_t i = 0; i < pool.size(); ++i)
		{
			double dWeight = 0;
			int nPinYinComposition = pinYinSearch.preparePinYinIndex(pool[i].first, bufferForNoChinense, nNoChineseBufSize);
			for ( int j = 0; j < nPinYinComposition && j < 16; ++j )	//最多16种，避免被攻击
			{
				pinYinSearch.getPinYinIndex(j, pinYinIndex);
				if (filterFast(pinYin, pinYinIndex, bufferForNoChinense))
				{
					if (pinYinSeg.empty())
						segmentPinYin(pinYin, pinYinSeg);

					double d = /*similarityPrecise*/precise(pinYinSeg, pinYinIndex, bufferForNoChinense);
					if (d < dWeight)
					{
						continue;
					}

					dWeight = d;
					if (nNoChineseBufSize > 0) //说明有英文
					{
						double dWeight3 = /*similarityPrecise*/precise(vForNoChinese, pinYinIndex, bufferForNoChinense);
						dWeight = (dWeight < dWeight3)?dWeight3:dWeight;
						if(dWeight == 0 && pinYin != L"")
							dWeight = index(pinYin, pinYinIndex, bufferForNoChinense);
					}
				}
			}

			if (dWeight > 0)
			{
				tmpResult.push_back(Result(dWeight, pool[i].first, pool[i].second));
			}

			if (nNoChineseBufSize > 0)
			{
				memset(bufferForNoChinense, 0, nNoChineseBufSize*sizeof(wchar_t));
			}
		}

		result.reserve(tmpResult.size());
		std::sort(tmpResult.begin(), tmpResult.end());
		/*for (std::vector<Result>::const_reverse_iterator It = tmpResult.rbegin(); It < tmpResult.rend(); ++It)
		{
			result.push_back(std::make_pair(It->string(), It->cookie()));
		}*/
		for(int i = (int)tmpResult.size()-1; i >= 0; --i)
		{
			result.push_back(std::make_pair(tmpResult.at(i).string(), tmpResult.at(i).cookie() ) );
		}
	}
	bool isPinYin(wchar_t ch)
	{
		if (ch >= L'a' && ch <= L'z')
		{
			return true;
		}
		if (ch >= L'A' && ch <= L'Z')
		{
			return true;
		}
		return false;
	}

	bool hasChinese(const std::wstring &searthstring)
	{
		return _hasChinese(searthstring);
	}

	bool hasNumber(const std::wstring &searthstring)
	{
		for (std::wstring::const_iterator it = searthstring.begin(); it != searthstring.end(); ++it)
		{
			if ((*it) >= L'0' && (*it) <= L'9')
			{
				return true;
			}
		}
		return false;
	}

	bool hasPinYin(const std::wstring &searthstring)
	{
		for (std::wstring::const_iterator it = searthstring.begin(); it != searthstring.end(); ++it)
		{
			if(isPinYin(*it))
				return true;
		}
		return false;
	}

    void search(const std::vector<std::wstring>& pool, const std::wstring& pinYin, std::vector<std::wstring>& result, bool ignoringCase)
	{
		if(pinYin.empty()||pool.empty()) {
            return;
        }
        
        if (!hasPinYin(pinYin)) {
            if (!hasChinese(pinYin) && !hasNumber(pinYin)) {
                return;
            }
        } else {
            if (!hasChinese(pinYin) && !hasNumber(pinYin)) {
                return pinyinSearch(pool,pinYin,result);
            }
        }
        return searchBycontext(pool, pinYin, result, ignoringCase);
	}
}
