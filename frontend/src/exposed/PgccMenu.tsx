import { useEffect, useState } from 'react'

const PGCC_API_URL = import.meta.env.VITE_PGCC_API_URL ?? ''

interface MenuMessage {
  message: string
}

export default function PgccMenu() {
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    fetch(`${PGCC_API_URL}/api/pgcc/menu`)
      .then((res) => (res.ok ? (res.json() as Promise<MenuMessage>) : null))
      .then((data) => { if (data) setMessage(data.message) })
      .catch(() => setMessage('Menù'))
  }, [])

  return <span>{message ?? '...'}</span>
}
