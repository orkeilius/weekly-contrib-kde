# Weekly Commits KDE
A widget to show your github contributions in the taskbar

> like [Weekly Commits](https://github.com/funinkina/weekly-commits) but for KDE

![](./docs/assets/exemple.webp)
 
### IA notice

This is based on an ia generated code with some manual ajustement (see initial commit)

Because I was too lazy to learn how to make plasmoid

## Install

**Requires Plasma 6.**

```bash
kpackagetool6 -t Plasma/Applet -i weekly-commit-kde.plasmoid
```

To remove:

```bash
kpackagetool6 -t Plasma/Applet -r com.github.weekly-commit-kde
```

## Configure

Right-click the widget → **Configure Weekly GitHub Contributions**:

- **GitHub username** — required.
- **Refresh interval** — how often it polls GitHub (default 30 min).

## Develop

To build and run, execute these command

```bash
zip -r weekly-commit-kde.plasmoid ./metadata.json ./contents/
kpackagetool6 -t Plasma/Applet -u weekly-commit-kde.plasmoid
systemctl restart --user plasma-plasmashell.service
```





