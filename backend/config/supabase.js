const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Use Service Key for Backend Operations (Bypass RLS)
const supabaseUrl = process.env.SUPABASE_URL || 'https://zmikoaaptvxmwbomlsov.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_SERVICE_KEY environment variable is required');
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
