# 🎯 AEO Diagnostic — AI Visibility Report Card

**Answer Engine Optimization tool for Amazon sellers and DTC brands.**

Shoppers are asking GPT, Gemini, and Llama "what's the best [product]?" instead of Googling. This tool tells you exactly where your brand ranks in those answers — and how to climb.

🔗 **Live Demo:** [your-app.vercel.app](https://your-app.vercel.app)  
📦 **GitHub:** [github.com/your-username/aeo-diagnostic](https://github.com/your-username/aeo-diagnostic)

---

## 🎬 Video Script (3 min max)

**[0:00 – 0:20] Intro**
> "Hi, I'm [Your Name] from [School], CGPA [X.X]. My favorite accomplishment is [1 sentence]. Today I built AEO Diagnostic — a tool that answers: when a shopper asks an AI 'what's the best magnesium supplement for seniors,' does YOUR brand show up?"

**[0:20 – 1:30] Demo**
> - Go to the live app
> - Type: "best magnesium supplement for seniors" + brand: "Nature Made"
> - Watch loading screen (3 AI models being queried in real time)
> - Show the report card: AEO Score, Grade, Per-model breakdown, Competitor chart, Recommendations
> - "This is not hypothetical — these are live API calls to Claude Haiku, Gemini 1.5 Flash, and Llama 3.3 70B happening right now"

**[1:30 – 2:00] Why I designed it this way**
> "The USER is an Amazon seller or DTC brand manager. Their problem: they're spending on SEO and Amazon ads, but AI search is eating into discovery. AEO is the next SEO. I focused on giving them one number — the AEO score — plus specific, prioritized actions."

**[2:00 – 2:30] How it works + APIs**
> - Node.js backend makes 3 parallel API calls
> - Parses ranked lists from each model's response
> - Scores based on position (rank #1 = 85 pts) + mention frequency
> - Groq's Llama generates the 4 recommendations with impact/effort rating
> - **APIs used:** Anthropic (Claude Haiku), Google Gemini 1.5 Flash, Groq (Llama 3.3 70B)

**[2:30 – 3:00] If I had more time**
> - Track AEO score over time (weekly cron job + database)
> - Add Perplexity + Claude to the model roster
> - Scrape competitor Amazon listings to auto-suggest better keywords
> - Email alerts when rank changes significantly
> - White-label dashboard for Pixii.ai customers

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- API keys: Anthropic, Groq, Google Gemini (all free tiers work)

### 1. Clone & Install
```bash
git clone https://github.com/your-username/aeo-diagnostic.git
cd aeo-diagnostic
npm run install:all
```

### 2. Set up environment variables
```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env`:
```env
ANTHROPIC_API_KEY=sk-ant-...   # console.anthropic.com (free $5 credits)
GROQ_API_KEY=gsk_...           # console.groq.com (free)
GEMINI_API_KEY=AIza...         # aistudio.google.com (free)
PORT=5000
FRONTEND_URL=http://localhost:5173
```

### 3. Run locally
```bash
# Terminal 1 — Backend
cd backend && npm run dev

# Terminal 2 — Frontend
cd frontend && npm run dev
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
| Anthropic Claude Haiku | Free $5 credits new users | Very cheap |

Total cost to run this for the demo: **~$0.002 per analysis** (just the Anthropic portion)

---

Built for the **Pixii.ai Founding Engineer** assessment · May 2025
