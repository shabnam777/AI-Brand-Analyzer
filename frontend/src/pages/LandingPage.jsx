import React, { useState } from 'react'
import { Search, Zap, BarChart3, Bot, ChevronRight, Sparkles, Send } from 'lucide-react'

const MODELS = [
  { icon: '🟢', name: 'DeepSeek R1 70B',  provider: 'Groq',          color: '#059669' },
  { icon: '🟠', name: 'Llama 3.3 70B',    provider: 'Groq',          color: '#FF6B35' },
  { icon: '🔵', name: 'Gemini 1.5 Flash', provider: 'Google',        color: '#4285F4' },
  { icon: '🔴', name: 'DeepSeek Qwen 32B',provider: 'Groq',          color: '#EF4444' },
  { icon: '🟡', name: 'Llama 3.1 8B',     provider: 'Cloudflare AI', color: '#F59E0B' },
  { icon: '🟤', name: 'Mistral 7B',        provider: 'Hugging Face',  color: '#92400E' },
]

const EXAMPLES = [
  { query: 'best magnesium supplement for seniors', brand: 'Nature Made' },
  { query: 'best wireless earbuds under $50',       brand: 'Anker Soundcore' },
  { query: 'best protein powder for weight loss',   brand: 'Garden of Life' },
]

const STEPS = [
  { icon: Send,     color: '#4F46E5', title: 'Query 6 AI Models',   desc: 'Sends your shopper question to DeepSeek, Llama, Gemini, Cloudflare & HuggingFace simultaneously.' },
  { icon: Search,   color: '#7C3AED', title: 'Extract Rankings',    desc: 'Parses each response — brand mentions, positions, and frequency.' },
  { icon: BarChart3,color: '#F59E0B', title: 'Get Your AEO Score',  desc: 'Score 0–100, competitor breakdown, and actions to improve.' },
]

export default function LandingPage({ onAnalyze }) {
  const [query, setQuery] = useState('')
  const [brand, setBrand] = useState('')

  const handleSubmit = () => {
    if (!query.trim() || !brand.trim()) return
    onAnalyze({ query: query.trim(), brand: brand.trim() })
  }

  return (
    <div className="min-h-screen" style={{ background: '#F5F6FF' }}>

      {/* Nav */}
      <nav style={{ background: '#fff', borderBottom: '1px solid #E5E7EB' }}
        className="flex items-center justify-between px-6 py-4 sticky top-0 z-50">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl flex items-center justify-center"
            style={{ background: 'linear-gradient(135deg,#4F46E5,#7C3AED)' }}>
            <Zap size={18} color="white" />
          </div>
          <span style={{ fontFamily:'Syne,sans-serif', fontWeight:700, fontSize:16, color:'#0F0A2C' }}>
            AEO Diagnostic
          </span>
        </div>
        <div className="badge badge-indigo">
          <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
          6 AI Models Active
        </div>
      </nav>

      {/* Hero */}
      <div style={{ background:'linear-gradient(135deg,#4F46E5 0%,#7C3AED 100%)' }} className="px-6 pt-12 pb-14">
        <div className="max-w-2xl mx-auto">
          <div className="badge mb-5" style={{ background:'rgba(255,255,255,.15)', color:'white', border:'1px solid rgba(255,255,255,.2)' }}>
            <Sparkles size={11} /> Answer Engine Optimization
          </div>
          <h1 style={{ fontFamily:'Syne,sans-serif', fontWeight:800, fontSize:'clamp(26px,5vw,46px)', color:'white', lineHeight:1.15 }}>
            How does your brand<br />rank in AI search?
          </h1>
          <p className="mt-4" style={{ color:'rgba(255,255,255,.75)', fontSize:14, lineHeight:1.6, maxWidth:460 }}>
            Shoppers ask 6 different AI models what to buy. See where your brand appears across all of them.
          </p>
        </div>
      </div>

      {/* Query Card */}
      <div className="px-6 max-w-2xl mx-auto" style={{ marginTop:-28 }}>
        <div className="card p-6">
          <label style={{ fontFamily:'JetBrains Mono,monospace', fontSize:10, color:'#ADB5BD', letterSpacing:'0.08em' }}>
            WHAT SHOPPERS ASK AI
          </label>
          <div className="relative mt-2 mb-4">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color:'#ADB5BD' }} />
            <input type="text" value={query} onChange={e => setQuery(e.target.value)}
              onKeyDown={e => e.key==='Enter' && handleSubmit()}
              placeholder="e.g. best magnesium supplement for seniors"
              className="input-field" />
          </div>

          <label style={{ fontFamily:'JetBrains Mono,monospace', fontSize:10, color:'#ADB5BD', letterSpacing:'0.08em' }}>
            YOUR BRAND NAME
          </label>
          <div className="relative mt-2 mb-5">
            <Bot size={16} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color:'#ADB5BD' }} />
            <input type="text" value={brand} onChange={e => setBrand(e.target.value)}
              onKeyDown={e => e.key==='Enter' && handleSubmit()}
              placeholder="e.g. Nature Made, Anker, Garden of Life"
              className="input-field" />
          </div>

          <button onClick={handleSubmit} disabled={!query.trim()||!brand.trim()}
            className="gradient-btn w-full py-4 rounded-xl flex items-center justify-center gap-3 text-white disabled:opacity-40 disabled:cursor-not-allowed"
            style={{ fontFamily:'Syne,sans-serif', fontWeight:700, fontSize:15 }}>
            <BarChart3 size={18} /> Run AEO Diagnostic <ChevronRight size={18} />
          </button>

          <div className="mt-5">
            <p style={{ fontFamily:'JetBrains Mono,monospace', fontSize:10, color:'#ADB5BD', letterSpacing:'0.08em', marginBottom:8 }}>
              TRY AN EXAMPLE
            </p>
            <div className="flex flex-wrap gap-2">
              {EXAMPLES.map((ex, i) => (
                <button key={i} onClick={() => { setQuery(ex.query); setBrand(ex.brand) }}
                  className="badge badge-indigo cursor-pointer hover:opacity-80 transition-opacity">
                  {ex.query}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Models — 2x3 grid (2 cols, 3 rows) */}
      <div className="px-6 max-w-2xl mx-auto mt-6">
        <p style={{ fontFamily:'JetBrains Mono,monospace', fontSize:10, color:'#ADB5BD', letterSpacing:'0.08em', marginBottom:10 }}>
          POWERED BY 6 FREE AI MODELS
        </p>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>
          {MODELS.map(m => (
            <div key={m.name} className="card p-3 flex items-center gap-3">
              <div style={{ width:36, height:36, borderRadius:10, background:`${m.color}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
                <span style={{ fontSize:20 }}>{m.icon}</span>
              </div>
              <div>
                <div style={{ fontFamily:'JetBrains Mono,monospace', fontSize:11, fontWeight:600, color:'#0F0A2C' }}>{m.name}</div>
                <div style={{ fontFamily:'JetBrains Mono,monospace', fontSize:9, color:'#ADB5BD' }}>{m.provider}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* How it works */}
      <div className="px-6 max-w-2xl mx-auto mt-8 pb-16">
        <p style={{ fontFamily:'Syne,sans-serif', fontWeight:700, fontSize:18, color:'#0F0A2C', marginBottom:14 }}>
          How It Works
        </p>
        {STEPS.map((s, i) => (
          <div key={i} className="card p-4 flex items-start gap-4 mb-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
              style={{ background:`${s.color}18` }}>
              <s.icon size={18} style={{ color:s.color }} />
            </div>
            <div>
              <div style={{ fontFamily:'DM Sans,sans-serif', fontWeight:600, fontSize:13, color:'#0F0A2C' }}>{s.title}</div>
              <div style={{ fontSize:12, color:'#6B7280', lineHeight:1.5, marginTop:2 }}>{s.desc}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
