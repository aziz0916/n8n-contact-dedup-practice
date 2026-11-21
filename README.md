# n8n 客戶名單去重練習

> 本專案為模擬接案練習，使用虛構公司與測試資料，並非真實客戶委託或商業交付。

## 功能

- 讀取 CSV 新客戶名單。
- 與 PostgreSQL 中的既有客戶 Email 比對。
- 標記既有客戶、新客戶、本次名單重複或資料異常。
- 匯出結果 CSV，並在 n8n 中查看筆數統計。
- CSV 缺少 `email` 標題欄位時停止流程並顯示錯誤。

## 使用工具

- Docker Desktop 與 Docker Compose
- n8n 2.20.7
- PostgreSQL 16
- Git

## 準備與啟動

以下 PowerShell 指令請在專案根目錄執行。

1. 複製環境變數範例：

   ```powershell
   Copy-Item .env.example .env
   ```

2. 開啟 `.env`，將 `POSTGRES_PASSWORD` 設為自行選擇的密碼。

3. 建立執行資料夾，並複製虛構的測試名單：

   ```powershell
   New-Item -ItemType Directory -Force data
   Copy-Item examples/new-contacts.csv data/new-contacts.csv
   ```

4. 啟動服務：

   ```powershell
   docker compose up -d
   ```

5. 等待 PostgreSQL 準備完成：

   ```powershell
   docker compose exec postgres pg_isready -U contact_user -d contact_practice
   ```

6. **首次建立空白資料庫時**，執行初始化檔：

   ```powershell
   Get-Content -Raw -Encoding UTF8 .\init-contacts.sql | docker compose exec -T postgres psql -U contact_user -d contact_practice -v ON_ERROR_STOP=1
   ```

   如果 `contacts` 資料表已存在，不要重複執行此初始化檔。

## 匯入並執行工作流程

1. 開啟 `http://localhost:5682`，依畫面建立或登入本機 n8n 帳號。
2. 在 n8n 匯入 `workflows/contact-dedup.json`。
3. 為 PostgreSQL 節點建立並選擇自己的憑證：
   - Host：`postgres`
   - Database：`contact_practice`
   - User：`contact_user`
   - Password：`.env` 中設定的密碼
   - Port：`5432`
   - SSL：關閉
4. 執行工作流程。
5. 在 `data/contact-results.csv` 查看結果；在「統計名單結果」節點查看統計。

每次成功執行會以相同路徑寫入結果檔，既有結果可能被覆寫。

## 測試結果

使用範例名單時，預期共 5 筆：

- 既有客戶：1 筆
- 新客戶：1 筆
- 本次名單重複：1 筆
- 資料異常：2 筆

目前已測試缺少 `email` 標題時，流程會顯示錯誤並停止後續寫檔；也已測試相同名單重複執行，結果一致。

## 目前範圍與限制

- 使用 PostgreSQL 模擬 CRM，尚未串接 Pipedrive。
- Email 使用基本格式檢查，不驗證信箱是否存在。
- CSV 標題檢查採簡單逗號分隔格式。
- 本版本不自動新增或修改客戶資料。
- 原案件的網站資料擷取、整理與分類是後續練習階段。