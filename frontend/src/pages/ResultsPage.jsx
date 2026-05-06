import React, { useState, useEffect, useRef } from 'react'
import VSCompetitors from '../components/VSCompetitors'
import { RotateCcw, ChevronDown, ChevronUp, Zap, TrendingUp, Users, Target, Lightbulb, BarChart3 } from 'lucide-react'
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Cell, Tooltip, RadarChart, PolarGrid, PolarAngleAxis, Radar } from 'recharts'

const GRADE_COLOR = { A: '#059669', B: '#0EA5E9', C: '#F59E0B', D: '#F97316', F: '#EF4444' }
const GRADE_BG    = { A: '#ECFDF5', B: '#E0F2FE', C: '#FFFBEB', D: '#FFF7ED', F: '#FEF2F2' }
const GRADE_LABEL = { A: 'Excellent AEO', B: 'Good AEO', C: 'Average AEO', D: 'Poor AEO', F: 'Not Visible' }
const IMPACT_COLOR = { high: '#059669', medium: '#F59E0B', low: '#ADB5BD' }
const EFFORT_LABEL = { high: '⚠️ High effort', medium: '⚡ Medium', low: '✅ Quick win' }

function ScoreRing({ score, grade }) {
  const r = 52, circ = 2 * Math.PI * r
  const [dash, setDash] = useState(0)
  const color = GRADE_COLOR[grade] || '#EF4444'
  useEffect(() => {
    setTimeout(() => setDash((score / 100) * circ), 100)
  }, [score, circ])

  return (
    <div style={{ position: 'relative', width: 130, height: 130 }}>
      <svg width="130" height="130" style={{ transform: 'rotate(-90deg)' }}>
        <circle cx="65" cy="65" r={r} fill="none" stroke={`${color}18`} strokeWidth="9" />
        <circle cx="65" cy="65" r={r} fill="none" stroke={color} strokeWidth="9" strokeLinecap="round"
          strokeDasharray={`${dash} ${circ}`}
          style={{ transition: 'stroke-dasharray 1.4s cubic-bezier(0.4,0,0.2,1)', filter: `drop-shadow(0 0 6px ${color}60)` }} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
        <span style={{ fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: 30, color }}>{score}</span>
        <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD' }}>/100</span>
      </div>
    </div>
  )
}

function ModelCard({ result, userBrand }) {
  const [expanded, setExpanded] = useState(false)
  const score = result.userScore ?? 0
  const grade = score >= 80 ? 'A' : score >= 65 ? 'B' : score >= 50 ? 'C' : score >= 35 ? 'D' : 'F'
  const color = GRADE_COLOR[grade]

  return (
    <div className="card model-card-enter mb-3">
      {/* Header */}
      <div className="flex items-center gap-3 p-4 pb-3">
        <span style={{ fontSize: 24 }}>{result.icon}</span>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: 'DM Sans, sans-serif', fontWeight: 600, fontSize: 13, color: '#0F0A2C' }}>{result.model}</div>
          <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD' }}>{result.provider} · {result.latency}ms</div>
        </div>
        {result.error ? (
          <span className="badge" style={{ background: '#FEF2F2', color: '#EF4444', border: '1px solid rgba(239,68,68,0.2)' }}>Error</span>
        ) : (
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 22, color }}>{score}</div>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#ADB5BD' }}>score</div>
          </div>
        )}
      </div>

      {!result.error && (
        <div className="px-4 pb-2">
          {result.userFound ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, fontFamily: 'JetBrains Mono, monospace' }}>
              <span style={{ color }}>✓</span>
              <span style={{ color: '#6B7280' }}>
                <span style={{ color: '#0F0A2C', fontWeight: 600 }}>{userBrand}</span> ranked #{result.userRank}
              </span>
            </div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, fontFamily: 'JetBrains Mono, monospace', color: '#ADB5BD' }}>
              <span style={{ color: '#EF4444' }}>✗</span>
              Not mentioned in this response
            </div>
          )}

          {result.topBrands.slice(0, 3).map((b, i) => {
            const isUser = b.brand.toLowerCase().includes(userBrand.toLowerCase()) ||
                           userBrand.toLowerCase().includes(b.brand.toLowerCase())
            return (
              <div key={i} className="flex items-center gap-3 px-3 py-2 mt-1 rounded-lg"
                style={{ background: isUser ? '#EEF2FF' : '#F5F6FF', border: isUser ? '1px solid rgba(79,70,229,0.2)' : 'none' }}>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD', width: 20 }}>#{b.position}</span>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: isUser ? '#4F46E5' : '#6B7280', fontWeight: isUser ? 600 : 400, flex: 1 }}>{b.brand}</span>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#ADB5BD' }}>{b.mentions}x</span>
              </div>
            )
          })}

          <button onClick={() => setExpanded(!expanded)}
            className="flex items-center gap-1 mt-3 mb-1"
            style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD', cursor: 'pointer', background: 'none', border: 'none' }}>
            {expanded ? <ChevronUp size={12} /> : <ChevronDown size={12} />}
            {expanded ? 'Hide' : 'View'} AI response
          </button>

          {expanded && (
            <div className="p-3 rounded-xl mt-1 mb-2"
              style={{ background: '#F5F6FF', border: '1px solid #E5E7EB' }}>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#6B7280', lineHeight: 1.6, whiteSpace: 'pre-wrap' }}>{result.text}</p>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

export default function ResultsPage({ data, onReset }) {
  const { grade, overallScore, userBrand, query, modelResults, topCompetitors, recommendations, analyzedAt } = data
  const gc = GRADE_COLOR[grade] || '#EF4444'
  const gbg = GRADE_BG[grade] || '#FEF2F2'
  const modelsFound = modelResults.filter(r => r.userFound).length
  const ranks = modelResults.filter(r => r.userRank).map(r => r.userRank)
  const avgRank = ranks.length ? Math.round(ranks.reduce((a, b) => a + b, 0) / ranks.length) : null

  const radarData = modelResults.map(r => ({
    model: r.model.replace('DeepSeek R1 70B','DeepSeek R1').replace('DeepSeek Qwen 32B','DS Qwen').replace('Gemini 1.5 Flash','Gemini').replace('Llama 3.3 70B','Llama 3.3').replace('Llama 3.1 8B','CF Llama').replace('Mistral 7B','Mistral'),
    score: r.userScore ?? 0,
  }))

  const competitorData = topCompetitors.slice(0, 5).map(c => ({
    name: c.brand.length > 13 ? c.brand.slice(0, 13) + '…' : c.brand,
    models: c.modelCount,
  }))

  return (
    <div className="min-h-screen" style={{ background: '#F5F6FF' }}>

      {/* Nav */}
      <nav style={{ background: '#fff', borderBottom: '1px solid #E5E7EB' }}
        className="flex items-center justify-between px-6 py-4 sticky top-0 z-50">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl flex items-center justify-center"
            style={{ background: 'linear-gradient(135deg, #4F46E5, #7C3AED)' }}>
            <Zap size={16} color="white" />
          </div>
          <span style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 15, color: '#0F0A2C' }}>AEO Report</span>
        </div>
        <button onClick={onReset}
          className="flex items-center gap-2 px-4 py-2 rounded-xl card-hover"
          style={{ background: '#F5F6FF', border: '1px solid #E5E7EB', fontSize: 12, color: '#6B7280', cursor: 'pointer' }}>
          <RotateCcw size={13} /> New Analysis
        </button>
      </nav>

      <div className="max-w-2xl mx-auto px-6 py-6">

        {/* Title */}
        <div className="mb-5">
          <h1 style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 22, color: '#0F0A2C' }}>
            {userBrand}
          </h1>
          <p style={{ fontSize: 13, color: '#6B7280' }}>"{query}"</p>
        </div>

        {/* Score Hero */}
        <div className="p-6 rounded-2xl mb-4 flex items-center gap-6"
          style={{ background: gbg, border: `1px solid ${gc}30` }}>
          <ScoreRing score={overallScore} grade={grade} />
          <div>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: 56, color: gc, lineHeight: 1 }}>{grade}</div>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 600, fontSize: 16, color: '#0F0A2C' }}>{GRADE_LABEL[grade]}</div>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#ADB5BD', marginTop: 2 }}>Overall AEO Score</div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          {[
            { icon: Users, label: 'AI Visibility', value: `${modelsFound}/3`, sub: 'models mentioned brand' },
            { icon: TrendingUp, label: 'Avg Rank', value: avgRank ? `#${avgRank}` : 'N/A', sub: 'when mentioned', color: avgRank ? undefined : '#EF4444' },
          ].map((s, i) => (
            <div key={i} className="card p-4">
              <div className="flex items-center gap-2 mb-2">
                <s.icon size={13} style={{ color: '#4F46E5' }} />
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD' }}>{s.label}</span>
              </div>
              <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 26, color: s.color || '#0F0A2C' }}>{s.value}</div>
              <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#ADB5BD' }}>{s.sub}</div>
            </div>
          ))}
        </div>

        {/* VS Competitors */}
        <VSCompetitors data={data} />

        {/* Model Breakdown 2x2 grid */}
        <div className="mb-6">
          <SectionTitle icon={<span>🤖</span>} title="Per-Model Breakdown" />
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, marginTop:10 }}>
            {modelResults.map((r, i) => <ModelCard key={i} result={r} userBrand={userBrand} />)}
          </div>
        </div>

        {/* Charts row */}
        <div className="grid grid-cols-1 gap-4 mb-6">
          {/* Competitors */}
          <div className="card p-5">
            <SectionTitle icon={<Target size={15} style={{ color: '#7C3AED' }} />} title="Competitors in AI" />
            <div className="mt-4">
              {competitorData.length > 0 ? (
                <ResponsiveContainer width="100%" height={180}>
                  <BarChart data={competitorData} layout="vertical" margin={{ left: 0, right: 20 }}>
                    <XAxis type="number" domain={[0, 3]} tick={{ fill: '#ADB5BD', fontSize: 10, fontFamily: 'JetBrains Mono' }} />
                    <YAxis type="category" dataKey="name" tick={{ fill: '#6B7280', fontSize: 10, fontFamily: 'JetBrains Mono' }} width={90} />
                    <Tooltip
                      contentStyle={{ background: '#fff', border: '1px solid #E5E7EB', borderRadius: 10, fontFamily: 'JetBrains Mono', fontSize: 11 }}
                      formatter={v => [`${v} AI models`, 'Mentioned in']}
                    />
                    <Bar dataKey="models" radius={[0, 6, 6, 0]}>
                      {competitorData.map((_, i) => (
                        <Cell key={i} fill={`rgba(79,70,229,${0.9 - i * 0.12})`} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div style={{ textAlign: 'center', padding: '30px 0', color: '#ADB5BD', fontSize: 13 }}>No competitor data</div>
              )}
            </div>
          </div>

          {/* Radar */}
          <div className="card p-5">
            <SectionTitle icon={<BarChart3 size={15} style={{ color: '#4F46E5' }} />} title="Score by Model" />
            <ResponsiveContainer width="100%" height={200}>
              <RadarChart data={radarData}>
                <PolarGrid stroke="#E5E7EB" />
                <PolarAngleAxis dataKey="model" tick={{ fill: '#6B7280', fontSize: 11, fontFamily: 'JetBrains Mono' }} />
                <Radar name={userBrand} dataKey="score" stroke="#4F46E5" fill="#4F46E5" fillOpacity={0.12} strokeWidth={2} />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recommendations */}
        <div className="mb-8">
          <SectionTitle icon={<Lightbulb size={15} style={{ color: '#F59E0B' }} />} title="How to Improve" />
          <div className="grid grid-cols-1 gap-3 mt-3">
            {recommendations.map((rec, i) => {
              const ic = IMPACT_COLOR[rec.impact] || '#ADB5BD'
              return (
                <div key={i} className="card p-4 flex gap-3">
                  <div className="w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0"
                    style={{ background: `${ic}18` }}>
                    <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, color: ic }}>{i + 1}</span>
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: 'DM Sans, sans-serif', fontWeight: 600, fontSize: 13, color: '#0F0A2C', marginBottom: 3 }}>{rec.title}</div>
                    <div style={{ fontSize: 12, color: '#6B7280', lineHeight: 1.5, marginBottom: 8 }}>{rec.description}</div>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <span className="badge" style={{ background: `${ic}12`, color: ic, border: 'none' }}>{rec.impact} impact</span>
                      <span className="badge" style={{ background: '#F5F6FF', color: '#ADB5BD', border: 'none' }}>{EFFORT_LABEL[rec.effort]}</span>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Footer CTA */}
        <button onClick={onReset}
          className="gradient-btn w-full py-4 rounded-xl text-white"
          style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 15, border: 'none', cursor: 'pointer' }}>
          Analyze Another Brand →
        </button>
        <p className="text-center mt-4" style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD' }}>
          AEO changes fast. Run monthly to track improvements.
        </p>
      </div>
    </div>
  )
}

function SectionTitle({ icon, title }) {
  return (
    <div className="flex items-center gap-2 mb-1">
      {icon}
      <span style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 16, color: '#0F0A2C' }}>{title}</span>
    </div>
  )
}
