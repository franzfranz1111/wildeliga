-- Update user_profiles table for Wilde Liga Bremen
-- Add missing columns if they don't exist

-- Add role column if it doesn't exist
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'contact_person', 'admin'));

-- Add team_id column if it doesn't exist
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS team_id UUID REFERENCES teams(id);

-- Add phone column if it doesn't exist  
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS phone TEXT;

-- Add name column if it doesn't exist (might be called display_name or similar)
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS name TEXT;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_team_id ON user_profiles(team_id);

-- Add comments
COMMENT ON COLUMN user_profiles.role IS 'User role: user, contact_person, or admin';
COMMENT ON COLUMN user_profiles.team_id IS 'Optional team assignment for contact persons';

-- Update RLS policies for contact persons
DROP POLICY IF EXISTS "Contact persons can view team users" ON user_profiles;
CREATE POLICY "Contact persons can view team users" ON user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.id = auth.uid() 
            AND up.role = 'contact_person'
            AND up.team_id = user_profiles.team_id
        )
    );

-- Show current table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
ORDER BY ordinal_position;
