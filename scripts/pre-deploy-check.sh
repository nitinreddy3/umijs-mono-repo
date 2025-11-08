#!/bin/bash

# Pre-deployment checklist script
# Runs checks before deploying to production

set -e

echo "🚀 Running pre-deployment checks..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "❌ node_modules not found. Run 'yarn install' first."
  exit 1
fi
echo "✅ Dependencies installed"

# Check if all configs exist
configs=(".umirc.ts" ".umirc.clark.ts" ".umirc.bruce.ts")
for config in "${configs[@]}"; do
  if [ ! -f "$config" ]; then
    echo "❌ Missing config: $config"
    exit 1
  fi
done
echo "✅ All UmiJS configs present"

# Check if tenant configs exist
tenant_configs=("config/tenants/clark.ts" "config/tenants/bruce.ts" "config/tenants/index.ts")
for config in "${tenant_configs[@]}"; do
  if [ ! -f "$config" ]; then
    echo "❌ Missing tenant config: $config"
    exit 1
  fi
done
echo "✅ All tenant configs present"

# Check TypeScript compilation
echo "Checking TypeScript..."
npx tsc --noEmit || {
  echo "❌ TypeScript compilation errors found"
  exit 1
}
echo "✅ TypeScript compilation successful"

# Try building all tenants
echo ""
echo "Building all tenants..."
yarn build || {
  echo "❌ Build failed"
  exit 1
}
echo "✅ Build successful"

# Verify build outputs
echo ""
node scripts/verify-build.js || {
  echo "❌ Build verification failed"
  exit 1
}

echo ""
echo "✅ All pre-deployment checks passed!"
echo "Ready to deploy! 🎉"

