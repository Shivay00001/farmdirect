const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Use Service Key for Backend Operations (Bypass RLS)
const supabaseUrl = process.env.SUPABASE_URL || 'https://zmikoaaptvxmwbomlsov.supabase.co';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptaWtvYWFwdHZ4bXdib21sc292Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTQyNzU2OSwiZXhwIjoyMDgxMDAzNTY5fQ.lnmHmZ4HWmJKLCXQFuGxCKvlMFfhOv4ar8TldSjcc-c';

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
