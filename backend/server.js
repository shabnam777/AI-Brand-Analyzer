require("dotenv").config();
const express = require("express");
const cors    = require("cors");
const fetch   = require("node-fetch");
const Groq    = require("groq-sdk").default;
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app  = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: "*", methods: ["GET","POST","OPTIONS"], allowedHeaders: ["Content-Type"] }));
app.options("*", cors());
app.use(express.json());

// ─── Clients ──────────────────────────────────────────────────────────────────
const groq  = new Groq({ apiKey: process.env.GROQ_API_KEY });
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const SYSTEM = "You are a shopping assistant. Give a ranked numbered list of top 5-7 specific brands with brief reasons. Format strictly: 1. Brand Name - reason. 2. Brand Name - reason.";

// ─── Helpers ──────────────────────────────────────────────────────────────────
function extractBrandMentions(text, userBrand) {
  const brandMap = {};
  const numPat   = /^\s*(\d+)[.)]\s+(.+)/;

  text.split("\n").filter(l => l.trim()).forEach(line => {
    const m = line.match(numPat);
    if (m) {
      const rank = parseInt(m[1]);
      const wm   = m[2].match(/([A-Z][a-zA-Z0-9\s&''.\-]{1,40})/);
      if (wm) {
        const brand = wm[1].trim();
        if (!brandMap[brand]) brandMap[brand] = { brand, position: rank, mentions: 1 };
        else brandMap[brand].mentions++;
      }
    }
  });

  const pos = text.toLowerCase().indexOf(userBrand.toLowerCase());
  if (pos !== -1 && !brandMap[userBrand])
    brandMap[userBrand] = { brand: userBrand, position: Math.ceil((pos / text.length) * 10) + 1, mentions: 1 };

  Object.keys(brandMap).forEach(b => {
    const hits = text.match(new RegExp(b.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "gi"));
    brandMap[b].mentions = hits ? hits.length : brandMap[b].mentions;
  });

  return Object.values(brandMap).sort((a, b) => a.position - b.position).slice(0, 10);
}

function calcScore(mentions, userBrand) {
  const found = mentions.find(m =>
    m.brand.toLowerCase().includes(userBrand.toLowerCase()) ||
    userBrand.toLowerCase().includes(m.brand.toLowerCase())
  );
  if (!found) return 0;
  return Math.min(100, Math.round(
    Math.max(0, 100 - (found.position - 1) * 15) + Math.min(found.mentions * 5, 20)
  ));
}

// ─── Model 1 — DeepSeek R1 70B via Groq (FREE) ───────────────────────────────
async function queryDeepSeek(prompt) {
  const start = Date.now();
  try {
    const res = await groq.chat.completions.create({
      model: "deepseek-r1-distill-llama-70b",
      messages: [{ role: "system", content: SYSTEM }, { role: "user", content: prompt }],
      max_tokens: 600, temperature: 0.3,
    });
    return { model: "DeepSeek R1 70B", provider: "Groq", icon: "🟢",
      text: res.choices[0].message.content, latency: Date.now() - start, error: null };
  } catch (e) {
    return { model: "DeepSeek R1 70B", provider: "Groq", icon: "🟢", text: "", latency: 0, error: e.message };
  }
}

// ─── Model 2 — Llama 3.3 70B via Groq (FREE) ─────────────────────────────────
async function queryLlama(prompt) {
  const start = Date.now();
  try {
    const res = await groq.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      messages: [{ role: "system", content: SYSTEM }, { role: "user", content: prompt }],
      max_tokens: 600, temperature: 0.3,
    });
    return { model: "Llama 3.3 70B", provider: "Groq", icon: "🟠",
      text: res.choices[0].message.content, latency: Date.now() - start, error: null };
  } catch (e) {
    return { model: "Llama 3.3 70B", provider: "Groq", icon: "🟠", text: "", latency: 0, error: e.message };
  }
}

// ─── Model 3 — Gemini 1.5 Flash (FREE) ───────────────────────────────────────
async function queryGemini(prompt) {
  const start = Date.now();
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const res   = await model.generateContent(`${SYSTEM}\n\nQuestion: ${prompt}`);
    return { model: "Gemini 1.5 Flash", provider: "Google", icon: "🔵",
      text: res.response.text(), latency: Date.now() - start, error: null };
  } catch (e) {
    return { model: "Gemini 1.5 Flash", provider: "Google", icon: "🔵", text: "", latency: 0, error: e.message };
  }
}

// ─── Model 4 — DeepSeek R1 Qwen 32B via Groq (FREE) ──────────────────────────
async function queryDeepSeekQwen(prompt) {
  const start = Date.now();
  try {
    const res = await groq.chat.completions.create({
      model: "deepseek-r1-distill-qwen-32b",
      messages: [{ role: "system", content: SYSTEM }, { role: "user", content: prompt }],
      max_tokens: 600, temperature: 0.3,
    });
    return { model: "DeepSeek Qwen 32B", provider: "Groq", icon: "🔴",
      text: res.choices[0].message.content, latency: Date.now() - start, error: null };
  } catch (e) {
    return { model: "DeepSeek Qwen 32B", provider: "Groq", icon: "🔴", text: "", latency: 0, error: e.message };
  }
}

// ─── Model 5 — Llama 3.1 8B via Cloudflare Workers AI (FREE) ────────────────
async function queryCloudflare(prompt) {
  const start = Date.now();
  try {
    const res = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${process.env.CF_ACCOUNT_ID}/ai/run/@cf/meta/llama-3.1-8b-instruct`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${process.env.CF_API_TOKEN}`,
          "Content-Type":  "application/json",
        },
        body: JSON.stringify({
          messages: [
            { role: "system", content: SYSTEM },
            { role: "user",   content: prompt },
          ],
          max_tokens: 600,
        }),
      }
    );
    const data = await res.json();
    if (!res.ok) throw new Error(data.errors?.[0]?.message || "Cloudflare error");
    return { model: "Llama 3.1 8B", provider: "Cloudflare AI", icon: "🟡",
      text: data.result?.response || "", latency: Date.now() - start, error: null };
  } catch (e) {
    return { model: "Llama 3.1 8B", provider: "Cloudflare AI", icon: "🟡", text: "", latency: 0, error: e.message };
  }
}



// ─── Recommendations ──────────────────────────────────────────────────────────
async function generateRecommendations(userBrand, query, modelResults, overallScore) {
  try {
    const summary = modelResults
      .map(r => `${r.model}: ${r.topBrands.slice(0,5).map(b => b.brand).join(", ")}`)
      .join("\n");
    const res = await groq.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      messages: [
        { role: "system", content: "You are an AEO expert. Give concise actionable advice." },
        { role: "user",   content: `Brand:"${userBrand}"\nQuery:"${query}"\nScore:${overallScore}/100\nMentions:\n${summary}\n\nReturn exactly 4 recommendations as JSON array:\n[{"title":"...","description":"...","impact":"high|medium|low","effort":"high|medium|low"}]\nJSON only.` },
      ],
      max_tokens: 600, temperature: 0.5,
    });
    return JSON.parse(res.choices[0].message.content.replace(/```json|```/g, "").trim());
  } catch {
    return [
      { title: "Optimize listing title",  description: "Use keyword-rich titles matching how AI describes top products.", impact:"high",   effort:"medium" },
      { title: "Build review volume",     description: "AI models favor 500+ reviews with 4.5+ rating.",                  impact:"high",   effort:"high"   },
      { title: "Get editorial coverage",  description: "Get listed on Wirecutter, BestReviews — AI pulls from these.",    impact:"high",   effort:"medium" },
      { title: "Answer Amazon Q&A",       description: "Thorough Q&A answers get pulled directly by AI models.",          impact:"medium", effort:"low"    },
    ];
  }
}

// ─── Main Endpoint ────────────────────────────────────────────────────────────
app.post("/api/analyze", async (req, res) => {
  const { query, userBrand } = req.body;
  if (!query || !userBrand)
    return res.status(400).json({ error: "query and userBrand are required" });

  // All 6 models in parallel
  const [r1,r4, r5] = await Promise.all([
    queryDeepSeek(query),
    queryLlama(query),
  
    queryCloudflare(query),
   
  ]);

  const rawResults = [r1, r4, r5];

  const modelResults = rawResults.map(r => {
    const topBrands = r.error ? [] : extractBrandMentions(r.text, userBrand);
    const userScore = r.error ? null : calcScore(topBrands, userBrand);
    const idx       = topBrands.findIndex(b =>
      b.brand.toLowerCase().includes(userBrand.toLowerCase()) ||
      userBrand.toLowerCase().includes(b.brand.toLowerCase())
    );
    return { ...r, topBrands, userScore, userRank: idx === -1 ? null : idx+1, userFound: idx !== -1 };
  });

  const valid        = modelResults.filter(r => r.userScore !== null).map(r => r.userScore);
  const overallScore = valid.length ? Math.round(valid.reduce((a,b)=>a+b,0)/valid.length) : 0;
  const grade        = overallScore>=80?"A":overallScore>=65?"B":overallScore>=50?"C":overallScore>=35?"D":"F";
  const gradeLabel   = {A:"Excellent AEO",B:"Good AEO",C:"Average AEO",D:"Poor AEO",F:"Not Visible"}[grade];

  const competitorMap = {};
  modelResults.forEach(r => {
    r.topBrands.forEach(b => {
      const isUser = b.brand.toLowerCase().includes(userBrand.toLowerCase()) ||
                     userBrand.toLowerCase().includes(b.brand.toLowerCase());
      if (!isUser) {
        if (!competitorMap[b.brand]) competitorMap[b.brand] = { brand:b.brand, modelCount:0, positions:[] };
        competitorMap[b.brand].modelCount++;
        competitorMap[b.brand].positions.push(b.position);
      }
    });
  });

  const topCompetitors = Object.values(competitorMap)
    .map(c => ({ ...c, avgPosition: Math.round(c.positions.reduce((a,b)=>a+b,0)/c.positions.length) }))
    .sort((a,b) => b.modelCount-a.modelCount || a.avgPosition-b.avgPosition)
    .slice(0, 5);

  const recommendations = await generateRecommendations(userBrand, query, modelResults, overallScore);
  res.json({ query, userBrand, overallScore, grade, gradeLabel, modelResults, topCompetitors, recommendations, analyzedAt: new Date().toISOString() });
});

app.get("/health", (_, res) => res.json({ status:"ok", timestamp:new Date().toISOString() }));
app.listen(PORT, () => console.log(`✅ AEO Diagnostic running on port ${PORT} — 6 AI models`));
