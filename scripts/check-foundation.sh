#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

ok() { printf 'ok  %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }

need_file() {
  if [[ -f "$root/$1" ]]; then ok "file $1"
  else bad "missing $1"
  fi
}

echo "Orbit foundation checks"
echo "root: $root"

need_file "OrbitApp/App/OrbitApp.swift"
need_file "OrbitApp/App/AuthGate.swift"
need_file "OrbitApp/App/MainTabView.swift"
need_file "OrbitApp/App/AppTab.swift"
need_file "OrbitApp/App/AppConfig.swift"
need_file "OrbitApp/App/AppEnvironment.swift"
need_file "OrbitApp/DesignSystem/OrbitTokens.swift"
need_file "OrbitApp/DesignSystem/OrbitButton.swift"
need_file "OrbitApp/DesignSystem/OrbitPlaceholder.swift"
need_file "OrbitApp/DesignSystem/OrbitCard.swift"
need_file "OrbitApp/Repositories/AuthRepository.swift"
need_file "OrbitApp/Repositories/EventRepository.swift"
need_file "OrbitApp/Repositories/ProfileRepository.swift"
need_file "OrbitApp/Repositories/Live/SupabaseFactory.swift"
need_file "OrbitApp/Models/Event.swift"
need_file "OrbitApp/Models/Profile.swift"
need_file "supabase/migrations/20241021000000_init.sql"
need_file "supabase/seed.sql"
need_file "supabase/types/domain.ts"
need_file "Secrets.example.xcconfig"
need_file ".env.example"
need_file "SETUP.md"

if grep -q 'Secrets.xcconfig' "$root/.gitignore"; then
  ok ".gitignore lists Secrets.xcconfig"
else
  bad ".gitignore must list Secrets.xcconfig"
fi

for example in Secrets.example.xcconfig .env.example; do
  if grep -Eq 'SUPABASE_URL' "$root/$example" && grep -Eq 'SUPABASE_ANON_KEY' "$root/$example"; then
    ok "$example names SUPABASE_URL and SUPABASE_ANON_KEY"
  else
    bad "$example must name SUPABASE_URL and SUPABASE_ANON_KEY"
  fi
  if grep -Eq 'supabase\.co|sb_publishable_|eyJ[A-Za-z0-9_-]{20,}' "$root/$example"; then
    bad "$example must be variable names only (no project URL or key material)"
  else
    ok "$example has no URL or key material"
  fi
done

sql="$root/supabase/migrations/20241021000000_init.sql"
for table in profiles events event_registrations saved_events; do
  if grep -q "create table public.${table}" "$sql"; then ok "schema table ${table}"
  else bad "schema missing table ${table}"
  fi
  if grep -q "alter table public.${table} enable row level security" "$sql"; then ok "RLS on ${table}"
  else bad "RLS not enabled on ${table}"
  fi
done

for policy in profiles_select events_select events_insert events_update_admin registrations_insert_own saved_insert_own posters_owner_insert; do
  if grep -q "$policy" "$sql"; then ok "policy $policy"
  else bad "missing policy $policy"
  fi
done

for role in student organizer admin; do
  if grep -q "$role" "$sql"; then ok "role $role in schema"
  else bad "schema missing role $role"
  fi
done

if grep -R --exclude-dir=.git --exclude-dir=DerivedData --exclude='check-foundation.sh' \
  -E 'sb_publishable_|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]+\.' "$root" >/dev/null; then
  bad "tracked tree looks like it contains a live anon/JWT key"
else
  ok "no live-looking keys in the working tree scan"
fi

if command -v xcodebuild >/dev/null 2>&1 && xcodebuild -version >/dev/null 2>&1; then
  echo "xcodebuild is available; not compiling (needs a simulator destination on a full Xcode install)"
else
  echo "skip compile: full Xcode / xcodebuild is not available on this machine"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "foundation checks failed"
  exit 1
fi

echo "foundation checks passed"
