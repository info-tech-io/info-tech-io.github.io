# Stage 3: Documentation Hub Creation

**Child**: #4 - Documentation Federation Workflow
**Epic**: #2 - Rebuild GitHub Pages Federation
**Status**: ⏳ Pending (after Stage 1, 2)
**Estimated Duration**: 0.5 days

---

## 🎯 Stage Objective

Create unified Documentation Hub at `/docs/index.html` with navigation, search, and professional design for all product documentation.

---

## 📋 Tasks

### Task 1: Design Documentation Hub Interface

Create HTML template for `/docs/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Documentation Hub - InfoTech.io</title>
    <meta name="description" content="Comprehensive documentation for all InfoTech.io products">
    <link rel="icon" href="/favicons/favicon.ico">
    <style>
      :root {
        --primary-color: #1da1f2;
        --secondary-color: #14171a;
        --background: #ffffff;
        --surface: #f7f9fa;
        --text-primary: #14171a;
        --text-secondary: #657786;
        --border: #e1e8ed;
        --hover: #f5f8fa;
      }

      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        line-height: 1.6;
        color: var(--text-primary);
        background: var(--background);
      }

      header {
        background: var(--secondary-color);
        color: white;
        padding: 2rem 0;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      }

      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 2rem;
      }

      h1 {
        font-size: 2.5rem;
        margin-bottom: 0.5rem;
        font-weight: 700;
      }

      .subtitle {
        color: rgba(255,255,255,0.8);
        font-size: 1.1rem;
      }

      .search-container {
        margin: 3rem 0;
        text-align: center;
      }

      .search-box {
        width: 100%;
        max-width: 600px;
        padding: 1rem 1.5rem;
        font-size: 1rem;
        border: 2px solid var(--border);
        border-radius: 50px;
        outline: none;
        transition: border-color 0.3s;
      }

      .search-box:focus {
        border-color: var(--primary-color);
      }

      .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 2rem;
        margin: 3rem 0;
      }

      .product-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 2rem;
        transition: transform 0.3s, box-shadow 0.3s;
        cursor: pointer;
        text-decoration: none;
        color: inherit;
        display: block;
      }

      .product-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
      }

      .product-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
      }

      .product-title {
        font-size: 1.5rem;
        font-weight: 600;
        margin-bottom: 0.5rem;
        color: var(--secondary-color);
      }

      .product-description {
        color: var(--text-secondary);
        margin-bottom: 1rem;
      }

      .product-link {
        color: var(--primary-color);
        font-weight: 500;
        text-decoration: none;
      }

      .product-link:hover {
        text-decoration: underline;
      }

      .back-link {
        display: inline-block;
        margin: 2rem 0;
        color: var(--primary-color);
        text-decoration: none;
        font-weight: 500;
      }

      .back-link:hover {
        text-decoration: underline;
      }

      footer {
        background: var(--surface);
        padding: 2rem 0;
        margin-top: 4rem;
        border-top: 1px solid var(--border);
        text-align: center;
        color: var(--text-secondary);
      }

      @media (max-width: 768px) {
        h1 {
          font-size: 2rem;
        }

        .products-grid {
          grid-template-columns: 1fr;
        }
      }
    </style>
  </head>
  <body>
    <header>
      <div class="container">
        <h1>📚 Documentation Hub</h1>
        <p class="subtitle">Comprehensive documentation for all InfoTech.io products</p>
      </div>
    </header>

    <main class="container">
      <div class="search-container">
        <input
          type="text"
          class="search-box"
          id="searchBox"
          placeholder="🔍 Search documentation..."
          aria-label="Search documentation"
        >
      </div>

      <div class="products-grid">
        <!-- Quiz Engine -->
        <a href="/docs/quiz/" class="product-card" data-keywords="quiz assessment test examination evaluation">
          <div class="product-icon">🎯</div>
          <h2 class="product-title">Quiz Engine</h2>
          <p class="product-description">
            Interactive quiz and assessment platform for creating engaging educational content
          </p>
          <span class="product-link">View Documentation →</span>
        </a>

        <!-- Hugo Templates -->
        <a href="/docs/hugo-templates/" class="product-card" data-keywords="hugo templates framework static site builder">
          <div class="product-icon">🏗️</div>
          <h2 class="product-title">Hugo Templates Framework</h2>
          <p class="product-description">
            Powerful Hugo-based static site generation framework with federated build capabilities
          </p>
          <span class="product-link">View Documentation →</span>
        </a>

        <!-- Web Terminal -->
        <a href="/docs/web-terminal/" class="product-card" data-keywords="terminal console shell command line browser">
          <div class="product-icon">💻</div>
          <h2 class="product-title">Web Terminal</h2>
          <p class="product-description">
            Browser-based terminal emulator for interactive command-line experiences
          </p>
          <span class="product-link">View Documentation →</span>
        </a>

        <!-- InfoTech CLI -->
        <a href="/docs/info-tech-cli/" class="product-card" data-keywords="cli command line interface tool utility">
          <div class="product-icon">⚡</div>
          <h2 class="product-title">InfoTech CLI</h2>
          <p class="product-description">
            Command-line interface for managing InfoTech.io projects and workflows
          </p>
          <span class="product-link">View Documentation →</span>
        </a>
      </div>

      <a href="/" class="back-link">← Back to Main Site</a>
    </main>

    <footer>
      <div class="container">
        <p>© 2025 InfoTech.io - Open Source Educational Technology</p>
        <p>
          <a href="/about/" style="color: inherit; margin: 0 1rem;">About</a>
          <a href="/blog/" style="color: inherit; margin: 0 1rem;">Blog</a>
          <a href="https://github.com/info-tech-io" style="color: inherit; margin: 0 1rem;">GitHub</a>
        </p>
      </div>
    </footer>

    <script>
      // Simple client-side search
      const searchBox = document.getElementById('searchBox');
      const productCards = document.querySelectorAll('.product-card');

      searchBox.addEventListener('input', (e) => {
        const query = e.target.value.toLowerCase();

        productCards.forEach(card => {
          const title = card.querySelector('.product-title').textContent.toLowerCase();
          const description = card.querySelector('.product-description').textContent.toLowerCase();
          const keywords = card.dataset.keywords || '';

          const matches = title.includes(query) ||
                          description.includes(query) ||
                          keywords.includes(query);

          card.style.display = matches || query === '' ? 'block' : 'none';
        });
      });
    </script>
  </body>
</html>
```

---

### Task 2: Create Hub Generation Script

Create `scripts/generate-docs-hub.sh` in hub repository:

```bash
#!/bin/bash
set -e

# Generate Documentation Hub
# Usage: ./scripts/generate-docs-hub.sh <output-dir>

OUTPUT_DIR="${1:-.}"
DOCS_DIR="$OUTPUT_DIR/docs"

echo "🏠 Generating Documentation Hub..."

# Create docs directory
mkdir -p "$DOCS_DIR"

# Generate index.html
cat > "$DOCS_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
  <!-- [Full HTML template from Task 1] -->
</html>
EOF

# Verify generation
if [ -f "$DOCS_DIR/index.html" ]; then
    echo "✅ Documentation Hub generated successfully"
    echo "   Location: $DOCS_DIR/index.html"
    echo "   Size: $(wc -c < "$DOCS_DIR/index.html") bytes"
else
    echo "❌ Failed to generate Documentation Hub"
    exit 1
fi
```

Make script executable:
```bash
chmod +x scripts/generate-docs-hub.sh
```

---

### Task 3: Integrate Hub Generation into Workflow

Add hub generation step to workflow (update Task 6 in Stage 1):

```yaml
      - name: Create Documentation Hub
        run: |
          echo "🏠 Creating documentation hub..."

          # Use generate-docs-hub.sh script
          cd hub-repo
          ./scripts/generate-docs-hub.sh ../docs-build

          echo "✅ Documentation hub created"

      - name: Validate Documentation Hub
        run: |
          echo "🔍 Validating documentation hub..."

          # Check hub exists
          if [ ! -f "docs-build/docs/index.html" ]; then
            echo "❌ Documentation hub missing"
            exit 1
          fi

          # Check file size (should be >5KB)
          size=$(wc -c < "docs-build/docs/index.html")
          if [ $size -lt 5000 ]; then
            echo "❌ Documentation hub too small: $size bytes"
            exit 1
          fi

          echo "✅ Documentation hub validated: $size bytes"
```

---

### Task 4: Add Product Status Badges (Optional Enhancement)

Enhance hub with build status badges:

```html
<!-- Add to each product card -->
<div class="product-status">
  <img src="https://img.shields.io/badge/docs-passing-brightgreen" alt="Documentation status">
  <img src="https://img.shields.io/badge/version-v1.0.0-blue" alt="Version">
</div>
```

CSS for badges:
```css
.product-status {
  margin-top: 1rem;
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.product-status img {
  height: 20px;
}
```

---

### Task 5: Test Documentation Hub Locally

Test hub generation and rendering:

```bash
# Generate hub
./scripts/generate-docs-hub.sh ./test-output

# Start local server
cd test-output/docs
python3 -m http.server 8000

# Visit http://localhost:8000 in browser
# Test:
# - Visual appearance
# - All product links
# - Search functionality
# - Responsive design (mobile/desktop)
# - Back to main site link
```

---

## 🎯 Deliverable

**File**: `docs/index.html` (generated)
**Script**: `scripts/generate-docs-hub.sh`
**Size**: ~8KB HTML + styles + JS
**Functionality**: Professional documentation navigation hub

---

## ✅ Verification Criteria

- [ ] Documentation hub HTML template created
- [ ] Generation script created and executable
- [ ] Hub integrated into workflow
- [ ] Visual design professional and responsive
- [ ] All product links functional
- [ ] Search feature working
- [ ] Mobile-friendly responsive design
- [ ] Accessible (ARIA labels, semantic HTML)

---

## 🧪 Testing Plan

1. **Visual Testing**:
   - Desktop view (1920x1080)
   - Tablet view (768x1024)
   - Mobile view (375x667)
   - Dark mode compatibility

2. **Functional Testing**:
   - Click each product card
   - Test search with various queries
   - Verify back link to main site
   - Check footer links

3. **Performance Testing**:
   - Load time < 1 second
   - No external dependencies
   - Minimal CSS/JS (inline)

---

## 📝 Notes

- All styles and scripts inline (no external dependencies)
- Progressive enhancement approach
- Accessibility-first design
- SEO-optimized with proper meta tags

---

## 🎨 Design Principles

1. **Simplicity**: Clean, uncluttered interface
2. **Discoverability**: Easy product navigation
3. **Performance**: Fast load, minimal resources
4. **Accessibility**: WCAG 2.1 AA compliant
5. **Responsive**: Works on all devices

---

**Created**: 2025-10-26
**Status**: Ready to implement after Stage 1, 2
**Next**: Create hub template and generation script
