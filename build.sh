#!/usr/bin/env bash
# =============================================================
# build.sh — Assembles all HTML pages from components + content
# Small Ship Antarctica Cruises
# Usage: bash build.sh
# =============================================================
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

HEADER="$ROOT/components/header.html"
FOOTER="$ROOT/components/footer.html"

# build_page <out> <title> <desc> <canonical> <extra-head> <active-nav> <content> [extra-css] [depth]
# depth: 0 = root (index.html), 1 = one level deep (about/index.html, etc.)
build_page() {
  local OUT="$1"
  local TITLE="$2"
  local DESC="$3"
  local CANONICAL="$4"
  local EXTRA_HEAD="$5"
  local ACTIVE_NAV="$6"
  local CONTENT="$7"
  local EXTRA_CSS="${8:-}"
  local DEPTH="${9:-0}"

  # Base prefix for relative paths
  local BASE=""
  local ROOT_HREF="./"
  if [ "$DEPTH" = "1" ]; then
    BASE="../"
    ROOT_HREF="../"
  fi

  # Temp header: inject active class, then convert absolute paths to relative
  local TMP_HEADER
  TMP_HEADER=$(mktemp)
  sed \
    -e "s|href=\"$ACTIVE_NAV\"|href=\"$ACTIVE_NAV\" class=\"active\"|g" \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$HEADER" > "$TMP_HEADER"

  # Temp footer: convert absolute paths to relative
  local TMP_FOOTER
  TMP_FOOTER=$(mktemp)
  sed \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$FOOTER" > "$TMP_FOOTER"

  # Temp content: convert absolute image/link paths to relative
  local TMP_CONTENT
  TMP_CONTENT=$(mktemp)
  sed \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    "$CONTENT" > "$TMP_CONTENT"

  {
    echo '<!DOCTYPE html>'
    echo '<html lang="en">'
    echo '<head>'
    echo '  <meta charset="UTF-8">'
    echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'
    echo "  <title>$TITLE</title>"
    echo "  <meta name=\"description\" content=\"$DESC\">"
    echo "  <link rel=\"canonical\" href=\"$CANONICAL\">"
    echo '  <!-- Open Graph -->'
    echo '  <meta property="og:type"        content="article">'
    echo "  <meta property=\"og:title\"       content=\"$TITLE\">"
    echo "  <meta property=\"og:description\" content=\"$DESC\">"
    echo "  <meta property=\"og:url\"         content=\"$CANONICAL\">"
    echo "  <meta property=\"og:site_name\"   content=\"Small Ship Antarctica Cruises\">"
    echo "  <link rel=\"icon\" href=\"${BASE}favicon.svg\" type=\"image/svg+xml\">"
    echo '  <!-- Preconnect for Google Fonts -->'
    echo '  <link rel="preconnect" href="https://fonts.googleapis.com">'
    echo '  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
    echo '  <link href="https://fonts.googleapis.com/css2?family=Josefin+Sans:wght@300;400;600;700&family=Barlow:wght@400;500;600&family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400;1,600&display=swap" rel="stylesheet">'
    echo '  <!-- Styles -->'
    echo "  <link rel=\"stylesheet\" href=\"${BASE}css/global.css\">"
    if [ -n "$EXTRA_CSS" ]; then
      echo "  <link rel=\"stylesheet\" href=\"${BASE}css/ranking.css\">"
    fi
    if [ -n "$EXTRA_HEAD" ]; then
      echo "$EXTRA_HEAD"
    fi
    echo '</head>'
    echo '<body>'
    cat "$TMP_HEADER"
    echo '<main>'
    cat "$TMP_CONTENT"
    echo '</main>'
    cat "$TMP_FOOTER"
    echo "  <script src=\"${BASE}js/nav.js\" defer></script>"
    echo '</body>'
    echo '</html>'
  } > "$OUT"

  rm -f "$TMP_HEADER" "$TMP_FOOTER" "$TMP_CONTENT"
  echo "  Built: $OUT"
}

# ---- JSON-LD for index.html ----
INDEX_JSONLD=$(cat <<'JSONLD'
  <!-- Structured Data -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "Best Small Ship Antarctica Cruises 2026: Top 10 Expedition Operators Ranked",
    "description": "Expert rankings of the best small ship Antarctica cruises for 2026. Compare IAATO-certified operators by time ashore, ship size, activities, and value.",
    "url": "https://small-ship-antarctica-cruises.com/",
    "datePublished": "2026-01-15",
    "dateModified": "2026-03-01",
    "author": {
      "@type": "Organization",
      "name": "Small Ship Antarctica Cruises",
      "url": "https://small-ship-antarctica-cruises.com/"
    },
    "publisher": {
      "@type": "Organization",
      "name": "Small Ship Antarctica Cruises",
      "url": "https://small-ship-antarctica-cruises.com/"
    },
    "mainEntityOfPage": {
      "@type": "WebPage",
      "@id": "https://small-ship-antarctica-cruises.com/"
    }
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Small Ship Antarctica Cruises",
    "url": "https://small-ship-antarctica-cruises.com/",
    "description": "Independent editorial rankings of the best small ship Antarctica cruise operators for 2026"
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": "Best Small Ship Antarctica Cruise Operators 2026",
    "numberOfItems": 10,
    "itemListElement": [
      {"@type": "ListItem", "position": 1, "name": "Poseidon Expeditions", "url": "https://poseidonexpeditions.com"},
      {"@type": "ListItem", "position": 2, "name": "Aurora Expeditions", "url": "https://aurora-expeditions.com"},
      {"@type": "ListItem", "position": 3, "name": "Quark Expeditions", "url": "https://quarkexpeditions.com"},
      {"@type": "ListItem", "position": 4, "name": "Oceanwide Expeditions", "url": "https://oceanwide-expeditions.com"},
      {"@type": "ListItem", "position": 5, "name": "Lindblad Expeditions with National Geographic", "url": "https://expeditions.com"},
      {"@type": "ListItem", "position": 6, "name": "Hurtigruten HX Expeditions", "url": "https://hx.com"},
      {"@type": "ListItem", "position": 7, "name": "Antarctica21", "url": "https://antarctica21.com"},
      {"@type": "ListItem", "position": 8, "name": "Albatros Expeditions", "url": "https://albatros-expeditions.com"},
      {"@type": "ListItem", "position": 9, "name": "Ponant", "url": "https://uk.ponant.com"},
      {"@type": "ListItem", "position": 10, "name": "Heritage Expeditions", "url": "https://heritage-expeditions.com"}
    ]
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [
      {
        "@type": "Question",
        "name": "What is a small ship Antarctica cruise?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "A small ship Antarctica cruise is an expedition voyage on a vessel carrying fewer than approximately 100 passengers. IAATO's 100-passenger simultaneous landing rule means all guests aboard a small ship go ashore together on every excursion — no group rotations, no waiting onboard."
        }
      },
      {
        "@type": "Question",
        "name": "What is IAATO and why does it matter?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "IAATO — the International Association of Antarctica Tour Operators — is the industry self-regulatory body founded in 1991. Its 100-passenger simultaneous landing rule limits shore landings to 100 passengers at any one site simultaneously. Ships carrying more than 100 passengers must rotate guests in shifts. All operators ranked on this site are active IAATO members."
        }
      },
      {
        "@type": "Question",
        "name": "How much does a small ship Antarctica cruise cost in 2026?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Classic Antarctic Peninsula voyages range from approximately $7,000 to $15,000 per person. Falklands and South Georgia itineraries cost $15,000 to $25,000. Antarctic Circle crossings range from $15,000 to $27,000. Fly-cruise options from approximately $6,000 with Antarctica21. Ultra-luxury Ponant from approximately $30,000."
        }
      },
      {
        "@type": "Question",
        "name": "What is the Drake Passage?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "The Drake Passage is the 800km body of water between Cape Horn and the South Shetland Islands. The crossing takes 48 hours each way and is known for rough seas. Antarctica21's fly-cruise format bypasses the Drake entirely with a 2-hour charter flight from Punta Arenas, Chile, to King George Island."
        }
      },
      {
        "@type": "Question",
        "name": "When is the best time for an Antarctica cruise?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "The Antarctic season runs November through March. November offers early season conditions with penguins nesting and lower prices. December and January are peak season with best weather and most wildlife activity. February sees peak humpback whale feeding. March offers late season pricing with orca sightings more common."
        }
      },
      {
        "@type": "Question",
        "name": "Which small ship Antarctica cruise operator is ranked number 1?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Poseidon Expeditions ranks number 1. The M/V Sea Spirit carries 114 passengers with all guests landing simultaneously. Poseidon documents an average of 2.5 hours of off-ship activity per day, has 26 years of polar experience since 1999, holds IAATO membership since 2011, and won the International Travel Awards Best Polar Expedition Operator for four consecutive years from 2022 to 2025. Peninsula voyages start from approximately $7,000 per person."
        }
      },
      {
        "@type": "Question",
        "name": "What activities are available on a small ship Antarctica cruise?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Included activities typically include Zodiac landings for all guests twice daily, Zodiac cruising, naturalist-guided shore walks, onboard lectures, and the Polar Plunge. Optional add-ons include sea kayaking offered by Poseidon Expeditions, Aurora Expeditions, and Quark Expeditions; overnight camping in Antarctica offered by Poseidon Expeditions for up to 40 guests per night; scuba diving from Aurora Expeditions; and helicopter flightseeing from Quark Expeditions' Ultramarine."
        }
      }
    ]
  }
  </script>
JSONLD
)

echo "Building pages..."

# --- index.html (depth=0) ---
build_page \
  "$ROOT/index.html" \
  "Best Small Ship Antarctica Cruises 2026 | Ranked" \
  "Compare the best small ship Antarctica cruise operators for 2026. Expert-ranked by time ashore, expedition team quality, ship size, activities, and price." \
  "https://small-ship-antarctica-cruises.com/" \
  "$INDEX_JSONLD" \
  "/" \
  "$ROOT/content/main-ranking.html" \
  "yes" \
  "0"

# --- about/index.html (depth=1) ---
mkdir -p "$ROOT/about"
build_page \
  "$ROOT/about/index.html" \
  "About Us | Small Ship Antarctica Cruises" \
  "Independent polar travel researchers ranking the best small ship Antarctica expedition cruise operators. No operator pays for placement. Rankings are editorial only." \
  "https://small-ship-antarctica-cruises.com/about/" \
  "" \
  "/about/" \
  "$ROOT/content/about.html" \
  "" \
  "1"

# --- editorial-policy/index.html (depth=1) ---
mkdir -p "$ROOT/editorial-policy"
build_page \
  "$ROOT/editorial-policy/index.html" \
  "Editorial Policy & Ranking Methodology | Small Ship Antarctica Cruises" \
  "How we select, evaluate, and rank small ship Antarctica cruise operators. Our 5-criteria methodology, data sources, update schedule, and corrections policy." \
  "https://small-ship-antarctica-cruises.com/editorial-policy/" \
  "" \
  "/editorial-policy/" \
  "$ROOT/content/editorial-policy.html" \
  "" \
  "1"

# --- how-to-choose/index.html (depth=1) ---
mkdir -p "$ROOT/how-to-choose"
build_page \
  "$ROOT/how-to-choose/index.html" \
  "How to Choose a Small Ship Antarctica Cruise | 2026 Guide" \
  "How to choose the right small ship Antarctica cruise operator, itinerary, and season. Ship size framework, voyage types, activity guide, and budget planning." \
  "https://small-ship-antarctica-cruises.com/how-to-choose/" \
  "" \
  "/how-to-choose/" \
  "$ROOT/content/how-to-choose.html" \
  "" \
  "1"

# --- faq/index.html (depth=1) ---
mkdir -p "$ROOT/faq"
build_page \
  "$ROOT/faq/index.html" \
  "Antarctica Cruise FAQ: 13 Questions Answered | Small Ship Guide" \
  "Answers to the most common questions about small ship Antarctica cruises: IAATO rules, Drake Passage, costs, activities, camping, wildlife, and more." \
  "https://small-ship-antarctica-cruises.com/faq/" \
  "" \
  "/faq/" \
  "$ROOT/content/faq.html" \
  "" \
  "1"

# --- contact/index.html (depth=1) ---
mkdir -p "$ROOT/contact"
build_page \
  "$ROOT/contact/index.html" \
  "Contact Us | Small Ship Antarctica Cruises" \
  "Questions or corrections about our small ship Antarctica cruise rankings? Contact our editorial team at info@small-ship-antarctica-cruises.com." \
  "https://small-ship-antarctica-cruises.com/contact/" \
  "" \
  "/contact/" \
  "$ROOT/content/contact.html" \
  "" \
  "1"

# --- cookie-policy/index.html (depth=1) ---
mkdir -p "$ROOT/cookie-policy"
build_page \
  "$ROOT/cookie-policy/index.html" \
  "Cookie Policy & Privacy Policy | Small Ship Antarctica Cruises" \
  "Our cookie and privacy policy. We collect no personal data. All outbound links are direct, non-affiliate editorial links." \
  "https://small-ship-antarctica-cruises.com/cookie-policy/" \
  "" \
  "/cookie-policy/" \
  "$ROOT/content/cookie-policy.html" \
  "" \
  "1"

echo ""
echo "Done! Files built:"
echo "  index.html"
echo "  about/index.html"
echo "  editorial-policy/index.html"
echo "  how-to-choose/index.html"
echo "  faq/index.html"
echo "  contact/index.html"
echo "  cookie-policy/index.html"
