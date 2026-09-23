const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Use Service Key for Backend Operations (Bypass RLS)
const supabaseUrl = process.env.SUPABASE_URL || 'https://zmikoaaptvxmwbomlsov.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

// Lazy/optional client: the server must boot in local (SQLite) dev mode
// without Supabase keys. Supabase-backed features (e.g. storage uploads)
// will fail at request time with a clear error if unconfigured.
let supabase = null;
if (supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey);
} else {
  console.warn('SUPABASE_SERVICE_KEY not set — Supabase client disabled (local dev mode).');
}

module.exports = supabase;
