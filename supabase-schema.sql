-- 가계부 통장: 로그인 없이 쓰는 하나의 공용 가계부
-- 2026-10-21 프로젝트 wznfinrjqsejojvaunru 에 적용됨 (마이그레이션 gagyebu_shared_without_login).
-- 새 프로젝트에 다시 만들 때는 Supabase 대시보드 > SQL Editor 에 붙여 넣고 Run 하세요.
--
-- 주의: 로그인이 없으므로 페이지에 들어 있는 공개 키(publishable key)만 있으면
-- 누구나 이 표의 기록을 읽고, 고치고, 지울 수 있습니다.

-- 앞서 로그인 방식으로 만든 빈 테이블을 지우고 다시 만듭니다. (두 테이블 모두 비어 있음을 확인함)
drop table if exists public.entries;
drop table if exists public.settings;

create table public.entries (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('expense', 'income')),
  amount bigint not null check (amount > 0 and amount < 100000000000),
  category text not null check (char_length(category) between 1 and 20),
  memo text not null default '' check (char_length(memo) <= 60),
  date date not null,
  example boolean not null default false,
  created_at timestamptz not null default now()
);
create index entries_date_idx on public.entries (date);

-- 설정은 한 줄만 둡니다 (id = 1).
create table public.settings (
  id smallint primary key default 1 check (id = 1),
  budget bigint not null default 0 check (budget >= 0 and budget < 100000000000),
  seeded boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.entries enable row level security;
alter table public.settings enable row level security;

create policy "entries: public read" on public.entries for select to anon, authenticated using (true);
create policy "entries: public insert" on public.entries for insert to anon, authenticated with check (true);
create policy "entries: public update" on public.entries for update to anon, authenticated using (true) with check (true);
create policy "entries: public delete" on public.entries for delete to anon, authenticated using (true);

create policy "settings: public read" on public.settings for select to anon, authenticated using (true);
create policy "settings: public insert" on public.settings for insert to anon, authenticated with check (true);
create policy "settings: public update" on public.settings for update to anon, authenticated using (true) with check (true);

grant select, insert, update, delete on public.entries to anon, authenticated;
grant select, insert, update on public.settings to anon, authenticated;
