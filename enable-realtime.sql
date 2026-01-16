-- ============================================
-- SUPABASE REALTIME CONFIGURATION SCRIPT
-- ============================================
-- Run this script in your Supabase SQL Editor
-- to enable real-time chat functionality
-- ============================================

-- Step 1: Enable Realtime for Messages Table
-- This allows real-time updates when new messages are inserted
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Step 2: Enable Realtime for Conversations Table
-- This allows real-time updates when conversations are updated
ALTER PUBLICATION supabase_realtime ADD TABLE conversations;

-- Step 3: Enable Realtime for Profiles Table (Optional)
-- This allows real-time updates for user status changes
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;

-- Step 4: Verify Realtime is Enabled
-- This query should return the tables we just added
SELECT 
    schemaname,
    tablename,
    pubname
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;

-- Expected Output:
-- schemaname | tablename      | pubname
-- -----------|----------------|------------------
-- public     | conversations  | supabase_realtime
-- public     | messages       | supabase_realtime
-- public     | profiles       | supabase_realtime

-- Step 5: Check RLS Policies for Realtime
-- Ensure authenticated users can SELECT messages
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename IN ('messages', 'conversations', 'profiles')
ORDER BY tablename, policyname;

-- Step 6: Grant Realtime Access (if needed)
-- This ensures the realtime role can access the tables
GRANT SELECT ON messages TO authenticated;
GRANT SELECT ON conversations TO authenticated;
GRANT SELECT ON profiles TO authenticated;

-- Step 7: Create Index for Better Realtime Performance
-- This speeds up real-time queries
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created 
ON messages(conversation_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_conversations_last_message 
ON conversations(last_message_at DESC);

-- Step 8: Verify Everything is Set Up
-- Run this final check
SELECT 
    'Realtime Enabled' as status,
    COUNT(*) as table_count
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
AND tablename IN ('messages', 'conversations', 'profiles');

-- Expected Output:
-- status            | table_count
-- ------------------|------------
-- Realtime Enabled  | 3

-- ============================================
-- TROUBLESHOOTING
-- ============================================

-- If realtime is not working, run these diagnostic queries:

-- 1. Check if publication exists
SELECT * FROM pg_publication WHERE pubname = 'supabase_realtime';

-- 2. Check all tables in publication
SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';

-- 3. Check if tables exist
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('messages', 'conversations', 'profiles');

-- 4. Check RLS is enabled
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('messages', 'conversations', 'profiles');

-- ============================================
-- NOTES
-- ============================================
-- 
-- 1. After running this script, you may need to:
--    - Refresh your browser
--    - Clear browser cache
--    - Restart your development server
--
-- 2. Realtime changes may take 1-2 minutes to propagate
--
-- 3. If you still don't see real-time updates:
--    - Check Supabase Dashboard → Database → Replication
--    - Manually toggle realtime for each table
--    - Check browser console for subscription errors
--
-- 4. For production, consider:
--    - Setting up proper indexes
--    - Monitoring realtime connection count
--    - Setting up alerts for failed subscriptions
--
-- ============================================
