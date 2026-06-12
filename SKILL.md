---
name: weekly-market-wrap
description: >
  每週市場回顧（Weekly Market Wrap）週報生成器。當用戶提到"市場周報"、"每週市場回顧"、"Weekly Market Wrap"、
  "周報"、"一週市場總結"、"本週市場回顧"、"上週行情總結"、"週度復盤"、"market weekly"等關鍵詞時觸發此技能。
  也適用於用戶詢問"這週/上週市場怎麼樣"、"上週美股/A股/港股表現如何"、"下週有什麼重要事件"、
  "下週財經日曆"等跨市場週度行情與宏觀總結的場景。
  此技能通過 WebSearch 收集美股、A股、港股、商品、外匯、加密貨幣的週度數據，
  生成包含市場總覽、宏觀大事、資金流向、下週前瞻四大部分的完整週報。
  最終報告以 HTML 文件（含板塊漲跌熱力圖，排版復刻原版 Weekly Market Wrap PDF）
  輸出到 ~/Reports/，自動發佈到 GitHub Pages（https://stevenhchang.github.io/weekly-market-wrap/），
  並通過飛書 Webhook 發送摘要卡片通知。
  注意：本技能是"週度全市場綜述"，區別於"美股日報"（us-stock-daily，每日板塊深度）和"加密貨幣日報"。
---

# 每週市場回顧 Weekly Market Wrap

## 概述

本技能用於生成跨市場的每週市場回顧週報（Weekly Market Wrap），覆蓋六大市場 + 四大內容板塊：

**六大市場**：美股、商品、A股、外匯、港股、加密貨幣

**四大內容板塊**：
1. **主要市場總覽** — 各市場指數週漲跌表格 + 板塊漲跌熱力圖（美股 GICS / A股 GICS / 主題觀察清單）
2. **上週市場總覽** — 中國宏觀&政策、美國經濟數據、全球央行動態、地緣政治風險、產業與科技亮點
3. **市場資金流向** — 美股板塊輪動信號、A股行業資金流向、港股南向資金
4. **本週重要事項與經濟事件關注焦點** — 下週財經日曆 + 關鍵風險提示

**運行時間**：北京時間每週日上午 9:00（定時任務自動觸發，也可手動觸發）。

> **時間窗口說明**：北京時間週日上午 9:00 時，美股上週五已收盤（北京時間週六凌晨 4:00/5:00），
> A股/港股上週五已收盤，因此覆蓋的報告週期為**剛剛結束的一週（週一至週五）**。
> - 報告週數 = 上週五所在的 ISO 週數（如 2026-06-07 週日運行 → 第23週，2026.06.01—06.05）
> - 各市場"上週五/本週五"對比：本週五 = 剛結束的週五收盤；上週五 = 再往前一週的週五收盤

**報告語言**：繁體中文（與原版 Weekly Market Wrap 模板一致），股票代碼/技術指標保留英文。

最終輸出 **HTML 主報告**（保存到 `~/Reports/`），並通過 **飛書 Webhook** 發送摘要卡片：
- **HTML 主報告**（含色塊熱力圖，A4 三頁排版，瀏覽器打開即可閱讀/打印為 PDF）

---

## 執行流程

收到請求後，按以下四個階段執行：

### 第一階段：數據採集（搜索階段）

使用 **WebSearch** 工具**並行**進行多輪搜索（每批3條同時發出），以提高效率。
`{週一日期}`/`{週五日期}` 指剛結束一週的起止日，`{當前月份}`/`{當前年份}` 按實際填入。

**批次1（並行，美股指數+商品）：**
- `"S&P 500 Nasdaq Dow Jones Russell 2000 weekly close {週五日期} weekly performance"`
- `"SOXX semiconductor ETF weekly performance week ending {週五日期}"`
- `"gold silver WTI Brent copper price weekly close {週五日期}"`

**批次2（並行，A股+港股指數）：**
- `"上证指数 深证成指 沪深300 创业板指 本周收盘 周涨跌 {當前年份}年{當前月份}月"`
- `"恒生指数 {上週五日期} 收盘 {本週五日期} 收盘 周涨跌"`
- `"恒生科技指数 恒生国企指数 {本週五日期} 收盘点位 {上週五日期}"`
- `"中证新能源指数 本周 周涨跌 {當前年份}年{當前月份}月"`

**批次3（並行，外匯+加密貨幣）：**
- `"DXY dollar index close {上週五日期} {本週五日期} 2026"`
- `"USD/JPY EUR/USD GBP/USD close {上週五日期} {本週五日期} exchange rate"`
- `"Bitcoin Ethereum price weekly performance week ending {週五日期}"`
- `"crypto market week recap BTC ETH {當前月份} {當前年份}"`

**批次4（並行，美股板塊熱力圖）：**
- `"S&P 500 sector ETF weekly performance XLK XLV XLF XLE XLI XLU XLY XLP XLB XLC XLRE week ending {週五日期}"`
- `"nuclear clean energy stocks weekly GEV SMR OKLO VST CEG CCJ LEU MP {當前月份} {當前年份}"`
- `"mega cap tech semiconductor stocks weekly NVDA TSM MSFT AMZN META GOOG AAPL TSLA MU MRVL ALAB SNDK {當前月份} {當前年份}"`

**批次5（並行，光通信+A股港股主題股）：**
- `"optical networking stocks weekly COHR LITE VRT {當前月份} {當前年份}"`
- `"宁德时代 阳光电源 新易盛 中际旭创 天孚通信 {上週五日期} {本週五日期} 收盘价 周涨跌"`
- `"腾讯控股 阿里巴巴 京东 小米 中芯国际 舜宇光学 香港交易所 {上週五日期} {本週五日期} 收盘价 周涨跌"`

**批次6（並行，中國宏觀+美國數據+CNY中間價）：**
- `"中国央行 公开市场操作 LPR CPI PPI 贸易数据 政策 本周 {當前年份}年{當前月份}月"`
- `"US economic data this week PMI nonfarm payrolls CPI jobless claims {當前月份} {當前年份}"`
- `"Federal Reserve officials speech FOMC rate expectations {當前月份} {當前年份}"`
- `"人民币对美元中间价 {週五日期}"`

**批次7（並行，全球央行+地緣+產業）：**
- `"ECB BOJ central bank decisions rate this week {當前月份} {當前年份}"`
- `"geopolitical risk oil supply Middle East this week {當前月份} {當前年份}"`
- `"AI semiconductor EV tech industry news highlights this week {當前月份} {當前年份}"`

**批次8（並行，資金流向）：**
- `"sector ETF fund flows rotation defensive growth this week {當前月份} {當前年份}"`
- `"A股 行业 资金流向 成交额 融资余额 本周 {當前年份}年{當前月份}月"`
- `"港股通 南向资金 净流入 本周 每日 {當前年份}年{當前月份}月"`

**批次9（並行，下週前瞻）：**
- `"economic calendar next week CPI PPI Fed ECB {下週起止日期} {當前年份}"`
- `"earnings calendar next week major companies {下週起止日期} {當前年份}"`
- `"中国 下周 经济数据 CPI PPI 公布 {當前年份}年{當前月份}月"`

搜索結果通常已包含足夠數據。如某條關鍵數據缺失，按以下優先級使用 **WebFetch** 補充：

**WebFetch 優先級（根據可訪問性）：**
1. **國內財經網站**（優先，通常不被阻擋）：東方財富（eastmoney.com）、新浪財經（finance.sina.com.cn）、證券時報（stcn.com）
2. **港股數據**：AASTOCKS（aastocks.com）、RTHK（rthk.hk）
3. **國際網站**（可能被安全策略阻擋）：Yahoo Finance、Investing.com、MarketWatch——僅在前兩類無法獲取時嘗試

### 第一點五階段：美股精度核驗（Yahoo Finance WebFetch）

Phase 1 的9批 WebSearch 完成後，立即並行發出以下3批 WebFetch，精確核驗美股個股與板塊 ETF 的週漲跌幅。**此步驟在 HTML 生成前完成**，Phase 1.5 數據優先於 Phase 1 搜索結果填入磁貼/chip。

**API 端點**
```
GET https://query1.finance.yahoo.com/v8/finance/chart/{TICKER}?interval=1wk&range=1mo
```

**週漲跌幅計算**
```
weekly_closes = JSON result[0].indicators.quote[0].close
weekly_pct    = (close[-1] - close[-2]) / close[-2] × 100
```
週日上午9:00執行時，`close[-1]` = 上週五收盤，`close[-2]` = 前週五收盤，與報告窗口完全吻合。

**3批並行 WebFetch Ticker 清單**

| 批次 | Ticker 清單 | 數量 |
|------|------------|------|
| B1 — Sector SPDR ETF | XLK XLV XLF XLE XLI XLU XLY XLP XLB XLC XLRE | 11 |
| B2 — 科技/半導體/光通信 | NVDA TSM MSFT AMZN META GOOG AAPL TSLA MU MRVL ALAB SNDK COHR LITE VRT | 15 |
| B3 — 能源/核能/清潔能源 | GEV SMR OKLO VST CEG BE MP CCJ LEU USAR BLDP CAT | 12 |

B1/B2/B3 三批**同時並行**發出（共38個 WebFetch）。

**失敗處理**
- 單一 ticker HTTP 429 或 JSON 解析失敗 → 保留 Phase 1 搜索結果 + ² 標注，不中斷流程
- `len(weekly_closes) < 2`（月底邊界週數據不足）→ 同上，視為解析失敗
- 整批全部失敗（網絡問題）→ 記錄警告，Phase 1 數據降級使用，報告照常生成
- **USAR**：低流動性微型鈾基金，若 Yahoo Finance 返回空 `close[]`，保留 ²（可考慮從觀察清單移除）

成功取得 Phase 1.5 數據的 ticker，在報告中**不標 ²**。

### 第一點六階段：缺口補搜（Gap Fill）

Phase 1 + 1.5 完成後，**必須逐項檢查**以下關鍵數據是否缺失，若有缺口立即用**精確日期格式**的 WebSearch 補搜。此步驟在 HTML 生成前完成，目標是將 ² 標註降到最低。

**補搜優先級（按重要性排序）：**

| 優先級 | 數據項目 | 補搜關鍵詞模板 | 目標來源 |
|--------|---------|--------------|---------|
| P0 | 恒生指數收盤 | `"恒生指数 {上週五日期} 收盘 {本週五日期} 收盘 点位"` | 新華社、東方財富 |
| P0 | 恒生科技收盤 | `"恒生科技指数 {上週五日期} 收盘 {本週五日期} 收盘"` | 鳳凰網、東方財富 |
| P0 | 恒生國企收盤 | `"恒生中国企业指数 {上週五日期} {本週五日期} 收盘"` | Yahoo Finance HK |
| P0 | DXY 收盤 | `"DXY dollar index close {上週五日期} {本週五日期}"` | WSJ、Barchart |
| P1 | A股行業週漲跌 | `"申万一级行业 周涨跌 {本週五日期} {當前年份} 通信 电子 计算机"` | 東方財富、證券時報 |
| P1 | 外匯週收盤 | `"USD/JPY EUR/USD GBP/USD close {上週五日期} exchange rate"` | Vietnam News、FXStreet |
| P2 | A股個股週漲跌 | `"寧德時代 中际旭创 新易盛 {上週五日期} {本週五日期} 收盘价"` | 東方財富、同花順 |
| P2 | 港股個股週漲跌 | `"腾讯控股 阿里巴巴 中芯国际 {上週五日期} {本週五日期} 收盘价"` | 東方財富、新浪財經 |

**補搜技巧：**
- **精確日期 >> 模糊時間**：用 `"6月5日 收盘 5月29日"` 而非 `"本周表现"`。搜索引擎對「本周」的理解可能與報告週期不一致
- **國內源優先**：A股/港股數據優先搜中文關鍵詞 → 東方財富、新華社、新浪財經的命中率遠高於國際網站
- **拆分大搜索**：將 `"腾讯 阿里巴巴 京东 小米"` 拆成 2-3 個小搜索，每個含具體日期
- **WebFetch 備援**：若 WebSearch 仍無結果，用 WebFetch 直接訪問東方財富個股歷史行情頁（`https://quote.eastmoney.com/`）或新浪財經港股頁

補搜完成後，更新 ² 標註清單：凡經補搜確認的數據，在報告中移除 ²。

### 第二階段：生成報告文件（HTML 主報告）

#### 2a. HTML 主報告（含熱力圖）

HTML 是主報告格式，排版完整復刻原版 Weekly Market Wrap PDF（含色塊熱力圖）。

**模板**：讀取本技能目錄下的 `assets/template.html`（內含 2026 第23週完整示例數據），
**保留全部 CSS 樣式、頁面結構（3 頁：總覽+熱力圖 / 上週總覽 / 資金流向+本週日曆）和着色腳本不變**，
只替換其中的數據內容：

- 報告頭：週數標籤（`week-tag`）、日期範圍（`range`）
- 六大市場表格的數值與漲跌幅（漲跌幅單元格 class 用 `up`/`dn`，缺數據用 `na`）
- 熱力圖磁貼（`.tile`）、主題分組基準（`.bench`）與個股籤（`.chip`）：
  文字內容 + `data-pct` 屬性同步更新（着色腳本依 `data-pct` 數值自動上色，±8% 飽和，正綠負紅）
- 第二頁五個宏觀板塊（`.macro-block`）的要點列表
- 第三頁三張資金流向表、輪動/A股/港股總結（`.summary`）、下週日曆表、風險提示
- 頁腳日期改為生成日期

板塊/個股觀察清單若當週有成分變化（新增/剔除標的），按實際數據增減磁貼即可，結構不變。

輸出路徑：`~/Reports/weekly-market-wrap-YYYY-WXX.html`。
生成後用 Bash 確認文件存在且大小 > 20KB。

#### 文件命名規則
```
weekly-market-wrap-YYYY-WXX.html     （HTML 主報告，例：weekly-market-wrap-2026-W23.html）
```

輸出到 `~/Reports/`。

### 第三階段：發送飛書通知

報告生成後，通過飛書自定義機器人 Webhook 發送摘要卡片。

#### 飛書 Webhook 配置（已配置，與美股日報相同）

```
https://open.feishu.cn/open-apis/bot/v2/hook/f0529772-a223-4a80-9842-c2101026733e
```

每次生成報告後**自動**發送，無需詢問用戶。

#### 發送方式（重要）

**必須使用 Node.js `https` 模塊發送，不能用 `curl`**（curl 在某些環境有 UTF-8 編碼問題，會導致中文亂碼）。

**腳本命名規範**：生成週數專屬腳本 `feishu-weekly-YYYY-WXX.js`，然後執行：
```bash
node feishu-weekly-YYYY-WXX.js
```

參考 `/tmp/crypto-report/feishu-latest.js` 的代碼結構（若不存在，直接用標準 Node.js https 模塊編寫）。

#### 飛書卡片消息內容要求

飛書交互式卡片（`msg_type: "interactive"`，`template: "blue"`，與每日報告的 indigo 區分），精簡摘要包含：

1. **標題**：📊 每週市場回顧 | 第XX週（MM.DD—MM.DD）
2. **主要市場速覽**：S&P 500 / NASDAQ / 恒生指數 / 上證指數 / 黃金 / BTC 週漲跌幅
3. **板塊輪動一句話**：如"典型 Risk-off：科技/半導體遭拋售，資金流向防禦性板塊"
4. **上週要聞 TOP 3**：含影響圖標（🔴 重大 / 🟡 關注）
5. **本週關注焦點**：下週最重要的 2-3 個事件/風險（日期 + 事件）
6. **note 標籤**：HTML 本地路徑（~/Reports/weekly-market-wrap-YYYY-WXX.html）+ GitHub Pages 連結（https://stevenhchang.github.io/weekly-market-wrap/reports/YYYY-WXX.html）

#### 飛書發送注意事項

- Markdown 支持：加粗、有序/無序列表、分割線（不支持表格、圖片、`#` 標題語法）
- 消息內容不超過 4096 字符
- 發送失敗不影響 HTML 報告的正常交付，記錄錯誤信息即可

### 第四階段：發佈到 GitHub Pages

飛書發送成功後，自動將 HTML 報告發佈到 GitHub Pages。

#### GitHub 倉庫配置

```
本地倉庫：~/projects/weekly-market-wrap/
GitHub   ：https://github.com/stevenhchang/weekly-market-wrap
Pages URL：https://stevenhchang.github.io/weekly-market-wrap/reports/YYYY-WXX.html
```

#### 發佈步驟

在 Bash 中執行 publish.sh：

```bash
cd ~/projects/weekly-market-wrap
bash publish.sh YYYY-WXX "YYYY.MM.DD—MM.DD"
# 範例：bash publish.sh 2026-W23 "2026.06.01—06.05"
```

腳本會自動完成：
1. 從 `~/Reports/weekly-market-wrap-YYYY-WXX.html` 複製報告到 `reports/YYYY-WXX.html`
2. 更新 `reports.json`（新增週數條目，維護歷史索引）
3. `git commit -m "Add weekly market wrap for YYYY-WXX"` 並 `git push`
4. GitHub Actions 自動觸發 Pages 部署（約 1-2 分鐘後上線）

#### 發佈後告知用戶

發佈成功後，回覆用戶以下信息：
- HTML 本地路徑：`~/Reports/weekly-market-wrap-YYYY-WXX.html`
- GitHub Pages URL：`https://stevenhchang.github.io/weekly-market-wrap/reports/YYYY-WXX.html`
- 飛書發送狀態：StatusCode:0 ✓

---

## 報告內容模板

報告嚴格按以下四大部分組織（與原版 Weekly Market Wrap 一致）。

### 一、主要市場總覽

#### 1.1 六大市場週度對比表

每個市場一張表，列：**指數/品種 | 上週五 | 本週五 | 週漲跌幅**。

| 市場 | 品種 |
|------|------|
| 美股 | S&P 500、NASDAQ、Dow Jones、Russell 2000、費城半導體（SOXX） |
| 商品 | 黃金、白銀、WTI原油、布蘭特、銅 |
| A股 | 上證指數、深證成指、滬深300、創業板指、中證新能源 |
| 外匯 | DXY、USD/CNY、USD/JPY、EUR/USD、GBP/USD |
| 港股 | 恒生指數、恒生科技、恒生國企、恒生地產 |
| 加密貨幣 | Bitcoin、Ethereum |

#### 1.2 板塊漲跌熱力圖

**S&P 500 GICS Sector Overview**：11 個 Select Sector SPDR ETF（XLV/XLRE/XLF/XLI/XLP/XLU/XLB/XLC/XLE/XLY/XLK）按週漲跌幅排序展示。

**US Watchlist Theme Groups**（每組列出基準 ETF 週漲跌 + 成分個股週漲跌）：
- **能源/核能 & 清潔能源/稀土/鈾**（XLE、ICLN）：GEV、SMR、OKLO、VST、CEG、BE、BLDP、MP、USAR、CCJ、LEU
- **半導體/AI芯片 & 科技巨頭**（SOXX、XLK）：SNDK、MU、MRVL、ALAB、NVDA、TSM、MSFT、AMZN、META、GOOG、AAPL、TSLA
- **光通信/基建**（XLI）：COHR、LITE、VRT、CAT

**A股 GICS Sector Overview**：11 個 GICS 行業週漲跌幅排序展示。

**A股港股觀察清單主題分組**（每組列出基準指數週漲跌 + 成分個股週漲跌）：
- **新能源電池產業鏈**（申萬鋰電池）：寧德時代、廈鎢新能、龍蟠科技、恩捷股份、星源材質、尚太科技、中一科技
- **光伏/儲能**（中證光伏產業）：陽光電源
- **AI算力/光通信**（中證光通信）：新易盛、中際旭創、天孚通信
- **半導體/電子**（中證半導體）：鼎泰高科、芯原股份、兆易創新
- **數據中心/散熱**（中證數據中心）：英維克
- **互聯網/平台**（恒生科技）：騰訊控股、阿里巴巴、京東集團、小米集團
- **半導體/光學**（港股通電子）：中芯國際、舜宇光學、丘鈦科技
- **金融/交易所**（港股通資本市場）：香港交易所

末尾註明：綠色=上漲 紅色=下跌 | 美股板塊：Select Sector SPDR ETFs | A股板塊：GICS行業分類 | 主題分組引用市場基準指數/ETF

### 二、上週市場總覽

五個小節，每節 3-5 條要點（▸ 項目符號），覆蓋：

1. **中國宏觀 & 政策**：央行流動性操作（OMO/DR007）、重要政策法規、貿易/LPR/CPI/PPI 等數據與前瞻
2. **美國經濟數據**：PMI、就業、通脹、聯儲褐皮書等，附市場對利率路徑的定價變化
3. **全球央行動態**：聯儲官員表態、ECB/BOJ/其他央行決議與預期
4. **地緣政治風險**：重大衝突/制裁/能源供應風險及其對市場的傳導
5. **產業與科技亮點**：AI、半導體、新能源車、加密貨幣、消費電子等產業大事

每條要點必須具體（含數字、機構名、日期），不寫空泛評論。

### 三、市場資金流向

#### 3.1 美股板塊輪動信號
表格：**ETF | 板塊 | 週漲跌幅 | 信號**（信號如"防禦性買入"、"獲利了結"、"成長股拋售"等）。
表後一句話總結輪動模式（如 Risk-on / Risk-off / 板塊輪動方向）。

#### 3.2 A股行業資金流向
- 表格：資金流入 TOP 5 行業（成交額變化 週一→週五）與資金流出 TOP 5 行業
- 融資餘額週度變化（週初→週末，金額與百分比）
- 一句話總結輪動方向（如 TMT/軍工 vs 消費/防禦）

#### 3.3 港股資金流向
- 表格：每日南向淨流入（億）拆分港股通(滬)/港股通(深)，含週合計
- 一句話總結（主力流入日、帶動個股、ETF 成交異動）

### 四、本週重要事項與經濟事件關注焦點

#### 4.1 下週日曆表
表格：**日期（週一至週五，含具體日期）| 宏觀數據 | 央行 | 財報 | 企業/其他**。
覆蓋：中美重要經濟數據（CPI/PPI/貿易/就業等）、央行決議、重點財報（含 EPS 預期）、IPO/產品發布會等。

#### 4.2 關鍵風險提示
編號 ①②③④⑤ 列出 3-5 條下週最重要的風險/催化劑，每條一句話說明影響邏輯。

**末尾必須包含數據來源說明與免責聲明**：本報告由 AI 自動生成，僅供信息參考，不構成投資建議。

---

## 數據來源優先級

**美股/商品/外匯/加密貨幣：**
1. **價格/行情（美股個股）**：Yahoo Finance Chart API 首選（Phase 1.5 WebFetch，`query1.finance.yahoo.com/v8/finance/chart/{TICKER}?interval=1wk&range=1mo`）；輔以 Google Finance、MarketWatch、TradingView、Investing.com
2. **板塊 ETF**：Yahoo Finance Chart API 首選（Phase 1.5 B1 批次，覆蓋11只 SPDR ETF）；輔以 sectorspdrs.com、ETF.com、Barchart
3. **USD/CNY**：人民銀行每日中間價（批次6搜索 `"人民币对美元中间价 {週五日期}"`）；報告標籤用「人行中間價」，不標 ³
4. **宏觀/日曆**：Investing.com、CME FedWatch、FRED、Trading Economics
5. **新聞**：Bloomberg、CNBC、Reuters、MarketWatch

**A股/港股：**
1. **價格/行情**：東方財富（eastmoney.com）、同花順（10jqka.com.cn）、新浪財經
2. **資金面**：東方財富北向/南向資金頁面、融資融券數據
3. **新聞**：財聯社、21世紀經濟報道、證券時報

---

## 數據不可得時的處理

1. 標註"數據暫不可得"（與原版報告一致，如"恒生地產 數據暫不可得"）
2. 提供最近可獲取的數據並註明日期
3. **絕不編造數據**——寧可留空也不要造假

---

## 質量標準

- 所有價格數據與原始精度一致（指數兩位小數，匯率四位小數）
- 百分比精確到小數點後兩位（熱力圖個股可一位小數）
- 週漲跌幅 =（本週五收盤 − 上週五收盤）/ 上週五收盤，注意核對正負號與着色一致
- 事件描述客觀中立，含具體數字與日期
- 免責聲明必須包含，明確標註"不構成投資建議"
- 全文使用繁體中文；股票代碼保留英文大寫 / A股公司用中文名；技術指標/ETF 代碼保留英文

---

## 執行注意事項

1. 報告一次性生成完整，不分段輸出
2. 搜索時美股部分用英文關鍵詞、A股/港股部分用中文關鍵詞，報告以繁體中文撰寫
3. 如果用戶指定了特定週數/日期範圍，按該範圍查詢；否則默認為"剛結束的一週（週一至週五）"
4. 生成前簡要告知用戶正在收集數據，避免長時間沉默
5. **先生成 HTML 主報告（基於 assets/template.html），保存到 ~/Reports/**
6. **然後通過 Node.js 發送飛書卡片**
7. 如果飛書發送失敗，不影響 HTML 報告的正常交付
8. 若該週中美兩市均全週休市（極罕見），發送飛書"本週市場休市"通知後結束；單邊節假日（如美國感恩節、中國國慶）正常出報告並在對應表格標註休市情況

---

## 完整執行清單

```
□ 1. 確定報告週期：上週五所在的週一至週五，計算 ISO 週數（YYYY-WXX）
□ 2. 並行執行 9 批 WebSearch（共約30次；批次6含 CNY 中間價搜索）採集六大市場+宏觀+資金流+下週日曆數據
     注意：港股/外匯/個股搜索必須使用精確日期格式（"{上週五日期} {本週五日期} 收盘"），避免"本周"等模糊詞
□ 2.5 Phase 1.5 核驗：並行發出 3 批 Yahoo Finance Chart API WebFetch
      B1（ETF x11）B2（科技/半導體/光通信 x15）B3（能源/核能/清潔 x12）同時發出
      解析 JSON close[-1]/close[-2] 計算週漲跌幅；len<2 或失敗的 ticker 保留 Phase 1 結果 + ² 標注
□ 2.6 Phase 1.6 缺口補搜：逐項檢查關鍵數據（恒生指數/科技/國企、DXY、A股行業、外匯），
      缺失項立即用精確日期格式 WebSearch 補搜（P0 優先），優先使用國內財經源（東方財富、新華社）
      WebSearch 仍無結果時，用 WebFetch 訪問東方財富/新浪財經個股歷史行情頁
□ 3. 更新 ² 標註清單：經 Phase 1.5 + 1.6 確認的數據移除 ²，僅真正未核驗的保留 ²
□ 4. 讀取技能目錄 assets/template.html，替換數據生成 ~/Reports/weekly-market-wrap-YYYY-WXX.html
     （Phase 1.5 數據優先填入；USD/CNY 標為「人行中間價」；保留 CSS/結構/着色腳本；
      磁貼與 chip 的文字和 data-pct 同步更新；A股行業熱力圖優先使用申萬行業實採數據）
□ 5. 確認 HTML 文件存在且 > 20KB（ls -lh ~/Reports/weekly-market-wrap-YYYY-WXX.html）
□ 6. 編寫飛書腳本 feishu-weekly-YYYY-WXX.js（用 Node.js https 模塊，template: blue，note 含 HTML 文件名）
□ 7. 執行 node feishu-weekly-YYYY-WXX.js，確認飛書響應 StatusCode:0
□ 8. 執行 publish.sh 發佈到 GitHub Pages
      cd ~/projects/weekly-market-wrap && bash publish.sh YYYY-WXX "YYYY.MM.DD—MM.DD"
      確認 git push 成功（GitHub Actions 部署約 1-2 分鐘後上線）
□ 9. 向用戶確認報告路徑、飛書狀態、GitHub Pages 連結
```
