import React from 'react'

// On screens > 1024px: center panel is 1/3 width, sides are decorative
export default function ResponsiveShell({ children }) {
  return (
    <>
      {/* Mobile / tablet — full width */}
      <div className="block lg:hidden w-full">
        {children}
      </div>

      {/* Desktop — centered 1/3 panel */}
      <div className="hidden lg:flex w-full min-h-screen">
        {/* Left side */}
        <div className="flex-1 flex flex-col items-start justify-center px-12"
          style={{ background: 'linear-gradient(to left, #EEF2FF, #E8EAF6)' }}>
          <div className="w-12 h-12 rounded-2xl flex items-center justify-center mb-5"
            style={{ background: 'linear-gradient(135deg, #4F46E5, #7C3AED)' }}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="white"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
          </div>
          <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: 32, color: '#4F46E5', lineHeight: 1.1 }}>
            AEO<br/>Diagnostic
          </div>
          <p style={{ fontFamily: 'DM Sans, sans-serif', fontSize: 14, color: '#6B7280', marginTop: 12, lineHeight: 1.6 }}>
            See how your brand ranks<br/>when AI answers shoppers.
          </p>
          <div style={{ marginTop: 32, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {['🟢 DeepSeek R1 70B', '🟠 Llama 3.3 70B', '🔵 Gemini 1.5 Flash', '🔴 DeepSeek Qwen 32B'].map(m => (
              <div key={m} style={{
                padding: '8px 14px', background: '#fff',
                borderRadius: 10, border: '1px solid #E5E7EB',
                fontFamily: 'JetBrains Mono, monospace', fontSize: 12, color: '#6B7280',
              }}>{m}</div>
            ))}
          </div>
        </div>

        {/* Center panel — 1/3 width */}
        <div style={{
          width: '33.333%', minWidth: 360, maxWidth: 480,
          background: '#F5F6FF',
          boxShadow: '0 0 60px rgba(0,0,0,0.1)',
          position: 'relative', zIndex: 1,
          display: 'flex', flexDirection: 'column',
          overflowY: 'auto',
        }}>
          {children}
        </div>

        {/* Right side */}
        <div className="flex-1 flex flex-col items-center justify-center gap-4 px-12"
          style={{ background: 'linear-gradient(to right, #EEF2FF, #E8EAF6)' }}>
          {[
            ['3', 'AI Models'],
            ['100%', 'Free APIs'],
            ['~5s', 'Analysis Time'],
          ].map(([val, label]) => (
            <div key={label} style={{
              width: '100%', maxWidth: 180, padding: 16,
              background: '#fff', borderRadius: 14, border: '1px solid #E5E7EB',
              textAlign: 'center',
            }}>
              <div style={{ fontFamily: 'Syne, sans-serif', fontWeight: 800, fontSize: 28, color: '#4F46E5' }}>{val}</div>
              <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#ADB5BD' }}>{label}</div>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
