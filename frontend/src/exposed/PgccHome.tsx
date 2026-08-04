import { useEffect, useState } from 'react'

const PGCC_API_URL = import.meta.env.VITE_PGCC_API_URL ?? 'http://localhost:8082'

interface BackendMessage {
  message: string
}

export default function PgccHome() {
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetch(`${PGCC_API_URL}/api/pgcc/message`)
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        return res.json() as Promise<BackendMessage>
      })
      .then((data) => setMessage(data.message))
      .catch((err: unknown) => setError(err instanceof Error ? err.message : 'Errore sconosciuto'))
  }, [])

  return (
    <div style={{ padding: '2rem' }}>
      <h1>PGCC</h1>
      {error && <p style={{ color: 'red' }}>Errore: {error}</p>}
      {!error && !message && <p>Caricamento...</p>}
      {message && <p data-testid="pgcc-message">{message}</p>}
    </div>
  )
}
