-- Create auth user for contact person
-- Replace the values with the actual data from the admin interface

-- This function creates an auth user and links it to the existing user_profile
CREATE OR REPLACE FUNCTION create_contact_auth_user(
    contact_email TEXT,
    contact_password TEXT,
    contact_id UUID
) RETURNS TEXT AS $$
DECLARE
    auth_user_id UUID;
BEGIN
    -- Insert into auth.users manually (this should be done via Supabase Dashboard)
    -- This function is just a template - use Supabase Dashboard instead
    
    -- Update the user_profiles record with the new auth user ID
    UPDATE user_profiles 
    SET id = contact_id
    WHERE email = contact_email;
    
    RETURN 'Contact person linked successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Alternative: Use Supabase Dashboard to create auth user
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Add User" 
-- 3. Enter email and password
-- 4. Copy the user ID
-- 5. Update user_profiles table with the new ID:

-- UPDATE user_profiles 
-- SET id = 'NEW_AUTH_USER_ID_FROM_DASHBOARD'
-- WHERE email = 'contact@example.com';

-- Show users that need auth accounts
SELECT 
    id,
    name,
    email,
    role,
    temp_password,
    t.name as team_name
FROM user_profiles up
LEFT JOIN teams t ON up.team_id = t.id
WHERE up.role = 'contact_person'
  AND up.temp_password IS NOT NULL
ORDER BY up.name;
