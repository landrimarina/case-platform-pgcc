import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import PgccHome from './exposed/PgccHome'

// Standalone entry point (dev only, not used when embedded in Shell)
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PgccHome />
  </StrictMode>,
)
