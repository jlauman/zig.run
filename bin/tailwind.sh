#!/usr/bin/env bash

# npm install tailwindcss postcss autoprefixer

if [ "$1" == "purge" ]; then
  export NODE_ENV=production 
fi

npx tailwindcss-cli build \
    ./web/doc/tailwind.css \
    -c tailwind.config.cjs \
    -o ./web/doc/index_tailwind.css

