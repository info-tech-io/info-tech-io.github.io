# InfoTech.io GitHub Pages Hub

This repository serves as the central hub for building and deploying the InfoTech.io organization website and all product documentation sites.

## Architecture

### Content Sources
- `info-tech/docs/` → Corporate site content
- `quiz/docs/` → Quiz Engine documentation
- `hugo-templates/docs/` → Hugo Templates documentation
- `web-terminal/docs/` → Web Terminal documentation
- `info-tech-cli/docs/` → InfoTech CLI documentation

### Build Process
1. Repository content changes trigger notifications to this hub
2. Hub receives `repository_dispatch` events
3. Automated workflows fetch content and build sites using `hugo-templates`
4. Generated sites are deployed to GitHub Pages

### Deployed Sites
- **Corporate Site**: https://info-tech-io.github.io/
- **Quiz Engine Docs**: https://info-tech-io.github.io/quiz/
- **Hugo Templates Docs**: https://info-tech-io.github.io/hugo/
- **Web Terminal Docs**: https://info-tech-io.github.io/terminal/
- **InfoTech CLI Docs**: https://info-tech-io.github.io/cli/

## Future Plans
- Organization rename: `info-tech-io` → `info-tech`
- Custom domain: `info-tech.io` with subdomains
- Production deployment on VPS with GitHub Pages as mirror

## Automation
This repository is fully automated. Content updates in source repositories automatically trigger rebuilds and deployments.

---

*Part of the [InfoTech.io](https://info-tech.io) ecosystem.*