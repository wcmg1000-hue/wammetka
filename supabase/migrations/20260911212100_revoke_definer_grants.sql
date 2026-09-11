revoke all on function public.handle_new_user() from public;
revoke all on function public.handle_new_user() from anon;
revoke all on function public.handle_new_user() from authenticated;
revoke all on function public.crear_pedido(jsonb, text, uuid) from public;
revoke all on function public.crear_pedido(jsonb, text, uuid) from anon;
grant execute on function public.crear_pedido(jsonb, text, uuid) to authenticated;
