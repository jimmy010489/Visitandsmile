-- ===== VISIT & SMILE — STORAGE BUCKET POUR VISUELS RESEAUX SOCIAUX =====
-- A executer dans Supabase SQL Editor (une seule fois)

-- 1. Creer le bucket public 'social-posts'
insert into storage.buckets (id, name, public)
values ('social-posts', 'social-posts', true)
on conflict (id) do update set public = true;

-- 2. Policy : lecture publique (pour que n8n/Meta API puissent acceder aux images)
drop policy if exists "Public read access social-posts" on storage.objects;
create policy "Public read access social-posts"
on storage.objects for select
using (bucket_id = 'social-posts');

-- 3. Policy : upload autorise pour les utilisateurs authentifies
drop policy if exists "Authenticated upload social-posts" on storage.objects;
create policy "Authenticated upload social-posts"
on storage.objects for insert
to authenticated
with check (bucket_id = 'social-posts' and auth.uid()::text = (storage.foldername(name))[1]);

-- 4. Policy : suppression autorisee pour le proprietaire
drop policy if exists "Owner delete social-posts" on storage.objects;
create policy "Owner delete social-posts"
on storage.objects for delete
to authenticated
using (bucket_id = 'social-posts' and auth.uid()::text = (storage.foldername(name))[1]);

-- 5. Table pour tracker quelles images ont deja ete utilisees par l'agent
create table if not exists public.social_media_library (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade not null,
    file_path text not null,
    public_url text not null,
    file_name text,
    mime_type text,
    size_bytes bigint,
    description text,
    tags text[],
    used_count integer default 0,
    last_used_at timestamptz,
    created_at timestamptz default now()
);

alter table public.social_media_library enable row level security;

drop policy if exists "Owner manages media library" on public.social_media_library;
create policy "Owner manages media library"
on public.social_media_library for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- Index pour performance (recherche des images non utilisees recemment)
create index if not exists idx_media_library_user_used
on public.social_media_library(user_id, last_used_at nulls first, used_count);
