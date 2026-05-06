import React, { useState, useEffect, useRef } from 'react'
import { Zap } from 'lucide-react'

const STEPS = [
  { emoji:'🟢', color:'#059669', label:'Querying DeepSeek R1 70B...',   ms:1400 },
  { emoji:'🟠', color:'#FF6B35', label:'Querying Llama 3.3 70B...',     ms:1100 },
  { emoji:'🔵', color:'#4285F4', label:'Querying Gemini 1.5 Flash...',  ms:1000 },
  { emoji:'🔴', color:'#EF4444', label:'Querying DeepSeek Qwen 32B...', ms:1200 },
  { emoji:'🟡', color:'#F59E0B', label:'Querying Cloudflare AI...',      ms:1100 },
  { emoji:'🟤', color:'#92400E', label:'Querying HuggingFace Mistral...', ms:1300 },
  { emoji:'🔍', color:'#4F46E5', label:'Extracting brand mentions...',   ms:700  },
  { emoji:'📊', color:'#7C3AED', label:'Calculating AEO scores...',      ms:700  },
  { emoji:'✨', color:'#F59E0B', label:'Generating recommendations...',  ms:900  },
]

export default function AnalysisPage({ query, brand }) {
  const [stepState, setStepState] = useState(Array(STEPS.length).fill(0))
  const running = useRef(false)

  useEffect(() => {
    if (running.current) return
    running.current = true
    const run = async () => {
      for (let i = 0; i < STEPS.length; i++) {
        setStepState(prev => { const n=[...prev]; n[i]=1; return n })
        await new Promise(r => setTimeout(r, STEPS[i].ms))
        setStepState(prev => { const n=[...prev]; n[i]=2; return n })
        await new Promise(r => setTimeout(r, 100))
      }
    }
    run()
  }, [])

  const done   = stepState.filter(s=>s===2).length
  const active = stepState.filter(s=>s===1).length
  const progress = Math.round(((done + active*0.5)/STEPS.length)*100)

  return (
    <div className="min-h-screen flex items-center justify-center px-6" style={{ background:'#F5F6FF' }}>
      <div className="w-full max-w-md">

        <div className="flex flex-col items-center mb-8">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center mb-5"
            style={{ background:'linear-gradient(135deg,#4F46E5,#7C3AED)', boxShadow:'0 8px 24px rgba(79,70,229,.35)' }}>
            <Zap size={32} color="white" />
          </div>
          <h2 style={{ fontFamily:'Syne,sans-serif', fontWeight:700, fontSize:22, color:'#0F0A2C' }}>
            Analyzing Your Brand
          </h2>
          <p className="mt-2 text-center" style={{ fontSize:13, color:'#6B7280' }}>
            Querying <span style={{ color:'#4F46E5', fontWeight:600 }}>6 AI models</span> for<br/>
            <span style={{ color:'#4F46E5', fontWeight:600 }}>"{query}"</span>
          </p>
        </div>

        {/* Progress */}
        <div className="mb-5">
          <div className="flex justify-between mb-2">
            <span style={{ fontFamily:'JetBrains Mono,monospace', fontSize:11, color:'#ADB5BD' }}>Progress</span>
            <span style={{ fontFamily:'JetBrains Mono,monospace', fontSize:11, color:'#4F46E5', fontWeight:600 }}>{progress}%</span>
          </div>
          <div className="progress-bar"><div className="progress-fill" style={{ width:`${progress}%` }} /></div>
        </div>

        {/* Steps */}
        <div style={{ background:'#fff', borderRadius:20, border:'1px solid #E5E7EB', padding:5, boxShadow:'0 2px 12px rgba(15,10,44,.05)' }}>
          {STEPS.map((s,i) => {
            const isDone    = stepState[i]===2
            const isCurrent = stepState[i]===1
            return (
              <div key={i} style={{
                display:'flex', alignItems:'center', gap:10,
                padding:'9px 12px', borderRadius:13, margin:2,
                background: isCurrent ? '#EEF2FF' : 'transparent',
                opacity: stepState[i]===0 ? 0.2 : isDone ? 0.45 : 1,
                transition:'all .2s ease',
              }}>
                <div style={{ width:32, height:32, borderRadius:9, flexShrink:0,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  background: isDone ? 'rgba(5,150,105,.1)' : `${s.color}${isCurrent?'22':'0D'}` }}>
                  {isDone ? <span style={{fontSize:16}}>✅</span> : <span style={{fontSize:18}}>{s.emoji}</span>}
                </div>
                <span style={{ flex:1, fontSize:12, fontFamily:'DM Sans,sans-serif',
                  color: isCurrent ? '#0F0A2C' : '#6B7280',
                  fontWeight: isCurrent ? 600 : 400,
                  textDecoration: isDone ? 'line-through' : 'none' }}>
                  {s.label}
                </span>
                {isCurrent && (
                  <div style={{ display:'flex', gap:3 }}>
                    {[0,1,2].map(j=>(
                      <div key={j} className="animate-bounce"
                        style={{ width:4, height:4, borderRadius:'50%', background:'#4F46E5', animationDelay:`${j*.15}s` }} />
                    ))}
                  </div>
                )}
              </div>
            )
          })}
        </div>

        <p className="text-center mt-4"
          style={{ fontFamily:'JetBrains Mono,monospace', fontSize:11, color:'#ADB5BD' }}>
          Checking visibility of "{brand}"
        </p>
      </div>
    </div>
  )
}
