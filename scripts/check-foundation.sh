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
need_file "OrbitApp/Repositories/Live/LiveAuthRepository.swift"
need_file "OrbitApp/Repositories/Live/LiveProfileRepository.swift"
need_file "OrbitApp/Models/Event.swift"
need_file "OrbitApp/Models/Profile.swift"
need_file "supabase/migrations/20241021000000_init.sql"
need_file "supabase/migrations/20261022000000_auth_profile_bootstrap.sql"
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

auth_sql="$root/supabase/migrations/20261022000000_auth_profile_bootstrap.sql"
for rule in \
  "grant update (full_name, campus)" \
  "grant insert (id, full_name, campus)" \
  "profiles_insert_self_student" \
  "id = auth.uid() and role = 'student'" \
  "organizer_id = auth.uid() and status = 'pending'" \
  "public.is_admin()"; do
  if grep -Fq "$rule" "$auth_sql"; then ok "auth policy $rule"
  else bad "auth migration missing $rule"
  fi
done

if grep -Eq "set role = 'admin'|role = 'admin'" "$root/supabase/seed.sql"; then
  bad "seed.sql must not bootstrap an administrator"
else
  ok "seed.sql does not bootstrap an administrator"
fi

if grep -Fq 'sessionChanges()' "$root/OrbitApp/Repositories/Live/LiveAuthRepository.swift" \
  && grep -Fq 'environment.isSignedIn' "$root/OrbitApp/App/AuthGate.swift"; then
  ok "auth session changes and protected app gate are wired"
else
  bad "auth session observation or protected app gate is missing"
fi

if grep -Fq 'password.count >= 8' "$root/OrbitApp/Auth/SignUpView.swift" \
  && grep -Fq 'accountAlreadyExists' "$root/OrbitApp/Auth/SignUpView.swift"; then
  ok "signup validates password and handles duplicate accounts"
else
  bad "signup validation or duplicate-account handling is missing"
fi

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

if grep -R --exclude-dir=.git --exclude-dir=DerivedData --exclude-dir=node_modules \
  --exclude='Secrets.xcconfig' --exclude='check-foundation.sh' \
  -E 'sb_publishable_[A-Za-z0-9_-]{20,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]+\.' "$root" >/dev/null; then
  bad "tracked tree looks like it contains a live anon/JWT key"
else
  ok "no live-looking keys in the working tree scan"
fi

developer_dir="${DEVELOPER_DIR:-}"
if [[ -z "$developer_dir" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  developer_dir="/Applications/Xcode.app/Contents/Developer"
fi
if command -v xcodebuild >/dev/null 2>&1 && DEVELOPER_DIR="$developer_dir" xcodebuild -version >/dev/null 2>&1; then
  echo "xcodebuild is available; run the app build separately for a selected destination"
else
  echo "skip compile: full Xcode / xcodebuild is not available on this machine"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "foundation checks failed"
  exit 1
fi

echo "foundation checks passed"
