import React, { useState } from 'react'
import { Swords } from 'lucide-react'

// ─── Helpers ──────────────────────────────────────────────────────────────────
function getUserRankInModel(modelResult, userBrand) {
  const found = modelResult.topBrands.find(
    b => b.brand.toLowerCase().includes(userBrand.toLowerCase()) ||
         userBrand.toLowerCase().includes(b.brand.toLowerCase())
  )
  return found ? found.position : null
}

function getCompetitorRankInModel(modelResult, competitorBrand) {
  const found = modelResult.topBrands.find(
    b => b.brand.toLowerCase().includes(competitorBrand.toLowerCase()) ||
         competitorBrand.toLowerCase().includes(b.brand.toLowerCase())
  )
  return found ? found.position : null
}

// For a single model: user wins if both present & user rank < competitor rank
// Returns 'win' | 'lose' | 'tie' | 'absent'
function getResult(userRank, competitorRank) {
  if (userRank === null && competitorRank === null) return 'absent'
  if (userRank === null) return 'lose'       // competitor present, user not
  if (competitorRank === null) return 'win'  // user present, competitor not
  if (userRank < competitorRank) return 'win'
  if (userRank > competitorRank) return 'lose'
  return 'tie'
}

// ─── Styles ───────────────────────────────────────────────────────────────────
const RESULT_STYLE = {
  win:    { bg: '#ECFDF5', border: '#059669', color: '#059669', label: 'WIN',    icon: '🏆' },
  lose:   { bg: '#FEF2F2', border: '#EF4444', color: '#EF4444', label: 'LOSE',   icon: '📉' },
  tie:    { bg: '#FFFBEB', border: '#F59E0B', color: '#F59E0B', label: 'TIE',    icon: '🤝' },
  absent: { bg: '#F5F6FF', border: '#E5E7EB', color: '#ADB5BD', label: 'BOTH –', icon: '–'  },
}

const MODEL_ICONS = {
  'DeepSeek R1 70B':   '🟢',
  'Llama 3.3 70B':     '🟠',
  'Gemini 1.5 Flash':  '🔵',
  'DeepSeek Qwen 32B': '🔴',
  'Llama 3.1 8B':      '🟡',
  'Mistral 7B':        '🟤',
}

// ─── Component ────────────────────────────────────────────────────────────────
export default function VSCompetitors({ data }) {
  const { userBrand, topCompetitors, modelResults } = data
  const [selected, setSelected] = useState(0)

  if (!topCompetitors || topCompetitors.length === 0) {
    return (
      <div className="card p-6 text-center" style={{ color: '#ADB5BD', fontSize: 13 }}>
        No competitor data found for this query.
      </div>
    )
  }

  const competitor = topCompetitors[selected]

  // Per-model results
  const modelComparisons = modelResults.map(r => {
    const userRank = getUserRankInModel(r, userBrand)
    const compRank = getCompetitorRankInModel(r, competitor.brand)
    const result   = getResult(userRank, compRank)
    return { model: r.model, icon: MODEL_ICONS[r.model] || '🤖', userRank, compRank, result }
  })

  // Overall: count wins
  const wins   = modelComparisons.filter(m => m.result === 'win').length
  const losses = modelComparisons.filter(m => m.result === 'lose').length
  const overallResult = wins > losses ? 'win' : losses > wins ? 'lose' : 'tie'
  const overallStyle  = RESULT_STYLE[overallResult]

  return (
    <div className="card p-5" style={{ marginBottom: 24 }}>

      {/* Section Header */}
      <div className="flex items-center gap-2 mb-4">
        <div style={{ width: 28, height: 28, borderRadius: 8, background: '#EEF2FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Swords size={15} style={{ color: '#4F46E5' }} />
        </div>
        <span style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 16, color: '#0F0A2C' }}>
          Your Brand vs Competitors
        </span>
      </div>

      {/* Competitor Tabs */}
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 20 }}>
        {topCompetitors.map((c, i) => (
          <button key={i} onClick={() => setSelected(i)}
            style={{
              padding: '6px 14px',
              borderRadius: 999,
              border: selected === i ? '1.5px solid #4F46E5' : '1.5px solid #E5E7EB',
              background: selected === i ? '#EEF2FF' : '#fff',
              color: selected === i ? '#4F46E5' : '#6B7280',
              fontFamily: 'DM Sans, sans-serif',
              fontWeight: selected === i ? 600 : 400,
              fontSize: 12,
              cursor: 'pointer',
              transition: 'all 0.15s',
            }}>
            {c.brand}
          </button>
        ))}
      </div>

      {/* VS Card */}
      <div style={{ border: '1.5px solid #E5E7EB', borderRadius: 16, overflow: 'hidden' }}>

        {/* Overall VS Bar */}
        <div style={{ background: overallStyle.bg, borderBottom: '1px solid #E5E7EB', padding: '16px 20px' }}
          className="flex items-center justify-between">

          {/* Your Brand */}
          <div style={{ textAlign: 'center', flex: 1 }}>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#4F46E5', marginBottom: 4 }}>YOU</div>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 15, color: '#0F0A2C' }}>{userBrand}</div>
            <div style={{ marginTop: 6 }}>
              <span style={{
                fontFamily: 'JetBrains Mono, monospace', fontSize: 10, fontWeight: 700,
                padding: '3px 10px', borderRadius: 999,
                background: '#4F46E5', color: '#fff',
              }}>
                {wins} model{wins !== 1 ? 's' : ''} won
              </span>
            </div>
          </div>

          {/* VS Badge */}
          <div style={{ textAlign: 'center', padding: '0 16px' }}>
            <div style={{
              width: 48, height: 48, borderRadius: '50%',
              background: overallStyle.bg,
              border: `2px solid ${overallStyle.border}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 20, margin: '0 auto 4px',
            }}>
              {overallStyle.icon}
            </div>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: 13, color: overallStyle.color }}>
              {overallStyle.label}
            </div>
          </div>

          {/* Competitor */}
          <div style={{ textAlign: 'center', flex: 1 }}>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#ADB5BD', marginBottom: 4 }}>COMPETITOR</div>
            <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 700, fontSize: 15, color: '#0F0A2C' }}>{competitor.brand}</div>
            <div style={{ marginTop: 6 }}>
              <span style={{
                fontFamily: 'JetBrains Mono, monospace', fontSize: 10, fontWeight: 700,
                padding: '3px 10px', borderRadius: 999,
                background: '#F5F6FF', color: '#6B7280',
                border: '1px solid #E5E7EB',
              }}>
                {losses} model{losses !== 1 ? 's' : ''} won
              </span>
            </div>
          </div>
        </div>

        {/* Per Model Breakdown */}
        {modelComparisons.map((m, i) => {
          const rs = RESULT_STYLE[m.result]
          return (
            <div key={i}
              style={{
                display: 'flex', alignItems: 'center',
                padding: '12px 20px',
                borderBottom: i < modelComparisons.length - 1 ? '1px solid #F5F6FF' : 'none',
                background: '#fff',
              }}>

              {/* User rank */}
              <div style={{ flex: 1, textAlign: 'center' }}>
                {m.userRank ? (
                  <span style={{
                    fontFamily: 'JetBrains Mono, monospace', fontSize: 13, fontWeight: 700,
                    color: m.result === 'win' ? '#059669' : '#0F0A2C',
                  }}>
                    #{m.userRank}
                  </span>
                ) : (
                  <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, color: '#ADB5BD' }}>—</span>
                )}
              </div>

              {/* Model name + result badge */}
              <div style={{ textAlign: 'center', flex: 1.4 }}>
                <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#6B7280', marginBottom: 4 }}>
                  {m.icon} {m.model
    .replace('DeepSeek R1 70B','DeepSeek R1')
    .replace('DeepSeek Qwen 32B','DS Qwen')
    .replace('Gemini 1.5 Flash','Gemini')
    .replace('Llama 3.3 70B','Llama 3.3')
    .replace('Llama 3.1 8B','CF Llama')
    .replace('Mistral 7B','Mistral')}
                </div>
                <span style={{
                  fontFamily: 'JetBrains Mono, monospace', fontSize: 9, fontWeight: 700,
                  padding: '2px 8px', borderRadius: 999,
                  background: rs.bg, color: rs.color,
                  border: `1px solid ${rs.border}40`,
                }}>
                  {rs.label}
                </span>
              </div>

              {/* Competitor rank */}
              <div style={{ flex: 1, textAlign: 'center' }}>
                {m.compRank ? (
                  <span style={{
                    fontFamily: 'JetBrains Mono, monospace', fontSize: 13, fontWeight: 700,
                    color: m.result === 'lose' ? '#EF4444' : '#0F0A2C',
                  }}>
                    #{m.compRank}
                  </span>
                ) : (
                  <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, color: '#ADB5BD' }}>—</span>
                )}
              </div>

            </div>
          )
        })}
      </div>

      {/* Legend */}
      <div style={{ display: 'flex', gap: 12, marginTop: 12, flexWrap: 'wrap' }}>
        {Object.entries(RESULT_STYLE).filter(([k]) => k !== 'absent').map(([key, s]) => (
          <div key={key} style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <span style={{
              fontFamily: 'JetBrains Mono, monospace', fontSize: 9, fontWeight: 700,
              padding: '2px 8px', borderRadius: 999,
              background: s.bg, color: s.color,
              border: `1px solid ${s.border}40`,
            }}>{s.label}</span>
            <span style={{ fontSize: 10, color: '#ADB5BD', fontFamily: 'DM Sans, sans-serif' }}>
              {key === 'win' ? 'Your rank is higher' : key === 'lose' ? 'Competitor ranks higher' : 'Same rank'}
            </span>
          </div>
        ))}
        <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#ADB5BD' }}>—</span>
          <span style={{ fontSize: 10, color: '#ADB5BD', fontFamily: 'DM Sans, sans-serif' }}>Not mentioned</span>
        </div>
      </div>

    </div>
  )
}
