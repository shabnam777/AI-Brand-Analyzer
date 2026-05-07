# 🎯 AEO Diagnostic — AI Visibility Report Card

**Answer Engine Optimization tool for Amazon sellers and DTC brands.**

Shoppers are asking GPT, Gemini, and Llama "what's the best [product]?" instead of Googling. This tool tells you exactly where your brand ranks in those answers — and how to climb.

🔗 **Live Demo:** [[your-app.vercel.app](https://your-app.vercel.app)  ](https://ai-brand-analyzer-rose.vercel.app/)
📦 **GitHub:** [github.com/shabnam777/aeo-diagnostic](https://github.com/shabnam777/aeo-diagnostic)

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- API keys: Anthropic, Groq, Google Gemini (all free tiers work)

### 1. Clone & Install
```bash
git clone https://github.com/shabnam777/aeo-diagnostic.git
cd aeo-diagnostic
npm run install:all
```

### 2. Set up environment variables
```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env`:
```env

GROQ_API_KEY="gsk_......"
GEMINI_API_KEY="AIza...."
CF_ACCOUNT_ID="xxxxxx"
CF_API_TOKEN="cfat_....."
HF_API_TOKEN="hf_....."        
PORT=5000
FRONTEND_URL=*
```

### 3. Run locally
```bash
# Terminal 1 — Backend
cd backend && npm run dev

# Terminal 2 — Frontend (Flutter)
cd flutter_frontend && flutter pub get && flutter run -d chrome
```

App runs at: **http://localhost:5173**

---

## 🌐 Deploy (Free)

### Backend → Render (free tier)
1. Go to [render.com](https://render.com) → New → Web Service
2. Connect your GitHub repo
3. Root Directory: `backend`
4. Build: `npm install` | Start: `node server.js`
5. Add environment variables in Render dashboard
6. Copy your Render URL (e.g. `https://aeo-diagnostic-xxx.onrender.com`)

### Frontend → Vercel (free)
1. Update `frontend/vercel.json` — replace `YOUR-RENDER-URL` with your Render URL
2. Go to [vercel.com](https://vercel.com) → Import → Select repo
3. Root Directory: `frontend`
4. Deploy ✅

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                    User (Browser)                    │
│              React + Vite + Tailwind                 │
└──────────────────────┬──────────────────────────────┘
                       │ POST /api/analyze
                       ▼
┌─────────────────────────────────────────────────────┐
│               Node.js + Express Backend              │
│                                                      │
│  ┌──────────────┐ ┌──────────────┐ ┌─────────────┐  │
│  │ Anthropic API   │ │ Gemini API   │ │  Groq API   │  │
│  │ Claude Haiku  │ │ 1.5 Flash    │ │ Llama 3.3   │  │
│  └──────────────┘ └──────────────┘ └─────────────┘  │
│         ↓ Parallel Promise.all() ↓                   │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Brand Extraction + Score Calculation            │ │
│  │ + Recommendation Generation (Groq)              │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Scoring Algorithm
```
Position Score = max(0, 100 - (rank - 1) × 15)
  → Rank #1 = 100pts, #2 = 85pts, #3 = 70pts...

Mention Bonus = min(mentions × 5, 20)

AEO Score = min(100, PositionScore + MentionBonus)

Overall Score = average of scores across all 3 models
```

### Grades
| Score | Grade | Label |
|-------|-------|-------|
| 80-100 | A | Excellent AEO |
| 65-79 | B | Good AEO |
| 50-64 | C | Average AEO |
| 35-49 | D | Poor AEO |
| 0-34 | F | Not Visible |

---

## 📋 Assessment Questions Coverage

### Q: What 2+ tools/APIs did you use?
1. **Anthropic API** (Claude Haiku) — shopper query response
2. **Google Gemini API** (Gemini 1.5 Flash, free tier) — shopper query response
3. **Groq API** (Llama 3.3 70B, free tier) — shopper query response + recommendation generation

### Q: Why this design?
The user is an Amazon seller who doesn't understand AI infrastructure — they just want to know "am I winning?" So I led with a single score and letter grade (like an SEO tool), not raw API responses. Competitors are shown as a bar chart because sellers think in terms of who's beating them, not abstract rankings.

### Q: If you had more time?
- **Weekly tracking**: Cron job to store AEO scores in Supabase, show trend lines
- **More models**: Perplexity, Claude, Bing Copilot
- **Amazon integration**: Auto-suggest keywords by scraping your listing + competitors
- **Alerts**: Email/Slack when brand drops from top 5
- **Multi-query**: Test 10 different shopper queries at once, show aggregate score

---

## 📁 Project Structure
```
aeo-diagnostic/
├── backend/
│   ├── server.js          # Express API + all AI integrations
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── App.jsx
│   │   ├── pages/
│   │   │   ├── LandingPage.jsx    # Hero + query form
│   │   │   ├── AnalysisPage.jsx   # Animated loading
│   │   │   └── ResultsPage.jsx    # Full report card
│   │   └── index.css
│   ├── index.html
│   ├── vite.config.js
│   └── vercel.json
├── render.yaml
└── README.md
```

---

## 🆓 All APIs Are Free

| API | Free Tier | Rate Limit |
|-----|-----------|------------|
| Groq (Llama 3.3) | Unlimited (generous) | 30 req/min |
| Google Gemini 1.5 Flash | 1M tokens/day | 15 req/min |
|Cloudflare | Free  | Very cheap |
---

Built for the **Pixii.ai Founding Engineer** assessment · May 2025
