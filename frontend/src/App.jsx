import React, { useState } from 'react'
import LandingPage from './pages/LandingPage'
import AnalysisPage from './pages/AnalysisPage'
import ResultsPage from './pages/ResultsPage'
import ResponsiveShell from './components/ResponsiveShell'

export default function App() {
  const [page, setPage] = useState('landing')
  const [analysisData, setAnalysisData] = useState(null)
  const [formData, setFormData] = useState(null)

  const handleAnalyze = async (data) => {
    setFormData(data)
    setPage('analyzing')
    try {
      const res = await fetch('/api/analyze', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: data.query, userBrand: data.brand }),
      })
      if (!res.ok) throw new Error('Analysis failed')
      const result = await res.json()
      setAnalysisData(result)
      setPage('results')
    } catch (err) {
      console.error(err)
      alert('Analysis failed. Please check your backend is running and API keys are set.')
      setPage('landing')
    }
  }

  const handleReset = () => {
    setPage('landing')
    setAnalysisData(null)
    setFormData(null)
  }

  const content = (() => {
    if (page === 'landing')   return <LandingPage onAnalyze={handleAnalyze} />
    if (page === 'analyzing') return <AnalysisPage query={formData?.query} brand={formData?.brand} />
    if (page === 'results')   return <ResultsPage data={analysisData} onReset={handleReset} />
    return null
  })()

  return <ResponsiveShell>{content}</ResponsiveShell>
}
