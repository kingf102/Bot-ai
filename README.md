# ESMO Receipt Bot  (Order -> AI -> Receipt)

Send an order as text or a photo. The AI reads it, the bot asks about anything missing (retail / wholesale /
supply, payment method, customer name, address, discount, missing quantity or price), then sends the receipt as a
picture + PDF with your logo and records it in a sales ledger.

---------------------------------------------------------------------------------------------
## A) Host it ONLINE for free (Render + Supabase)  -  no need to keep your computer on
---------------------------------------------------------------------------------------------
Render runs the bot. Render's free disk is wiped on every restart, so your ledger, products and invoice
counter live in a free Supabase database instead.

**1. Database (Supabase)**
- supabase.com -> New project (any name, pick a region near you, save the password).
- SQL Editor -> New query -> paste everything from `supabase_setup.sql` -> Run.
- Project Settings -> API Keys: copy the **Project URL** and the **secret** key.
  The secret key is for the server only. Never put it in the web app, never share it.

**2. Code on GitHub**
- Put your logo in this folder as `logo.png`.
- Create a PRIVATE GitHub repository and upload this whole folder. (`.env` is ignored on purpose - never upload keys.)

**3. Bot on Render**
- render.com -> New -> Blueprint -> pick your repository (it reads `render.yaml`).
- Fill in the secret values it asks for: `TELEGRAM_BOT_TOKEN` (from @BotFather), `SUPABASE_URL`, `SUPABASE_KEY`,
  and, if you want better accuracy, a free AI key (`GEMINI_API_KEY`: https://aistudio.google.com/apikey).
  With no AI key at all the bot uses the keyless Pollinations service.
  `WEBHOOK_SECRET` is generated for you.
- Leave `ALLOWED_USER_IDS` empty for the first deploy. When it is live, message your bot `/myid`, then put that
  number in `ALLOWED_USER_IDS` in Render's Environment tab and save (it restarts). Only listed IDs can use the bot.

**4. First use**
- Send your web app's `backup.json` to the bot (it loads all products + prices and the next invoice number;
  it ignores logins/transactions and deletes the file from the chat).

**Free-tier facts to know**
- Render free sleeps after 15 minutes without traffic. The first message after a quiet spell can take about a
  minute; Telegram keeps retrying, so it still arrives. A free uptime pinger hitting `/healthz` every 10 minutes
  keeps it awake - one always-on service uses about 720 of Render's 750 free hours a month.
- Supabase free pauses a project after a week with no activity. Using the bot at least weekly prevents this;
  if it ever pauses, press Restore in the Supabase dashboard (data is kept).
- Terms change. Check render.com/docs/free and supabase.com/pricing if something behaves differently.

---------------------------------------------------------------------------------------------
## B) Run it on your own computer (optional)
---------------------------------------------------------------------------------------------
`cp .env.example .env`, fill it in, `pip install -r requirements.txt`, `python bot.py`.
Without SUPABASE_* the bot keeps data in the `data/` folder. With OLLAMA_MODEL set it can also use a free
local AI (free forever, private) - that option only works on your own machine, not on Render.

## Free AI
Keys are optional. With NO key the bot uses the keyless Pollinations service. Adding free keys makes it far more
reliable and accurate: the bot tries Gemini -> Groq -> OpenRouter -> Pollinations (no key) -> Ollama (local) and moves
on when one is busy or out of free quota.
- Keyless = anonymous third-party service: slower, rate-limited, can change or stop without notice, and your
  orders (customer names, addresses) pass through it. Gemini's free tier may also use data to improve Google products.
- Photos of handwriting are read less reliably by keyless models; always check the "I read:" list the bot sends.

## Commands
/products - /setprice NAME | retail | whole | supply (one per line for many) - /delproduct NAME - /setinv N -
/today - /export - or send backup.json to load every product.

## Notes
- Void any invoice with the button under it (the number stays used, as in normal accounting).
- If the database is unreachable the receipt is still sent, marked "NOT saved to the sales ledger".
- Bot and web app stay separate: bot sales do not reduce the web app's stock, and each counts invoice numbers
  on its own (re-send backup.json or use /setinv to realign).
