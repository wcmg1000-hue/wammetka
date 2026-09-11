-- RLS policies call private.jwt_role() / private.is_staff().
-- Revoking EXECUTE from authenticated made SELECT profiles fail (42501).
grant usage on schema private to anon, authenticated;
grant execute on function private.jwt_role() to anon, authenticated;
grant execute on function private.is_staff() to anon, authenticated;
